using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using WebSocketSharp;
using SocketIO;
using System.Threading;
using Newtonsoft.Json;

namespace LuaFramework
{
    public class NetworkManager : Manager
    {
        //private SocketClient socket;
        private SocketIOComponent socket;
        static readonly object m_lockObject = new object();
        static Queue<KeyValuePair<int, ByteBuffer>> mEvents = new Queue<KeyValuePair<int, ByteBuffer>>();


        //public string url = "ws://193.112.132.226:3001/socket.io/?EIO=4&transport=websocket";
        //public string url = "ws://127.0.0.1:3001/socket.io/?EIO=4&transport=websocket";
        public string url = "ws://118.24.169.185:3001/socket.io/?EIO=4&transport=websocket";
        public bool autoConnect = true;
        public int reconnectDelay = 5;
        public float ackExpirationTime = 1800f;
        public float pingInterval = 25f;
        public float pingTimeout = 60f;

        //public WebSocket socket { get { return ws; } }
        public string sid { get; set; }
        public bool IsConnected { get { return connected; } }

        private volatile bool connected;
        private volatile bool thPinging;
        private volatile bool thPong;
        private volatile bool wsConnected;

        private Thread socketThread;
        private Thread pingThread;
        private WebSocket ws;

        private Encoder encoder;
        private Decoder decoder;
        private Parser parser;

        private Dictionary<string, List<Action<SocketIOEvent>>> handlers;
        private List<Ack> ackList;

        private int packetId;

        private object eventQueueLock;
        private Queue<SocketIOEvent> eventQueue;

        private object ackQueueLock;
        private Queue<Packet> ackQueue;

        //SocketClient SocketClient {
        //get { 
        //  if (socket == null)
        //     socket = new SocketClient();
        // return socket;                    
        // }
        //   }
        void Awake()
        {
            Init();
        }
        public void Start()
        {
            if (autoConnect) { Connect(); }
        }
        public void Connect()
        {
            connected = true;
            socketThread = new Thread(RunSocketThread);
            socketThread.Start(ws);
            pingThread = new Thread(RunPingThread);
            pingThread.Start(ws);
        }
        public void On(string ev, Action<SocketIOEvent> callback)
        {
            if (!handlers.ContainsKey(ev))
            {
                handlers[ev] = new List<Action<SocketIOEvent>>();
            }
            handlers[ev].Add(callback);
        }
        private void RunSocketThread(object obj)
        {
            WebSocket webSocket = (WebSocket)obj;
            while (connected)
            {
                if (webSocket.IsConnected)
                {
                    Thread.Sleep(reconnectDelay);
                }
                else
                {
                    webSocket.Connect();
                }
            }
            webSocket.Close();
        }

        private void RunPingThread(object obj)
        {
            WebSocket webSocket = (WebSocket)obj;

            int timeoutMilis = Mathf.FloorToInt(pingTimeout * 1000);
            int intervalMilis = Mathf.FloorToInt(pingInterval * 1000);

            DateTime pingStart;

            while (connected)
            {
                if (!wsConnected)
                {
                    Thread.Sleep(reconnectDelay);
                }
                else
                {
                    thPinging = true;
                    thPong = false;

                    EmitPacket(new Packet(EnginePacketType.PING));
                    pingStart = DateTime.Now;

                    while (webSocket.IsConnected && thPinging && (DateTime.Now.Subtract(pingStart).TotalSeconds < timeoutMilis))
                    {
                        Thread.Sleep(200);
                    }

                    if (!thPong)
                    {
                        webSocket.Close();
                    }

                    Thread.Sleep(intervalMilis);
                }
            }
        }
        void Init()
        {
            //SocketClient.OnRegister();
            encoder = new Encoder();
            decoder = new Decoder();
            parser = new Parser();
            handlers = new Dictionary<string, List<Action<SocketIOEvent>>>();
            ackList = new List<Ack>();
            sid = null;
            packetId = 0;

            ws = new WebSocket(url);
            ws.OnOpen += OnOpen;
            ws.OnMessage += OnMessage;
            ws.OnError += OnError;
            ws.OnClose += OnClose;
            wsConnected = false;

            eventQueueLock = new object();
            eventQueue = new Queue<SocketIOEvent>();

            ackQueueLock = new object();
            ackQueue = new Queue<Packet>();

            connected = false;
        }

        public void OnInit()
        {
            CallMethod("Start");
        }

        public void Unload()
        {
            CallMethod("Unload");
        }
        private void OnOpen(object sender, EventArgs e)
        {
            EmitEvent("open");
        }
        private void OnError(object sender, ErrorEventArgs e)
        {
            EmitEvent("error");
        }

        private void OnClose(object sender, CloseEventArgs e)
        {
            EmitEvent("close");
        }
        private void EmitEvent(string type)
        {
            EmitEvent(new SocketIOEvent(type));
        }
        private void EmitEvent(SocketIOEvent ev)
        {
            if (!handlers.ContainsKey(ev.name)) { return; }
            foreach (Action<SocketIOEvent> handler in this.handlers[ev.name])
            {
                try
                {
                    handler(ev);
                }
                catch (Exception ex)
                {
#if SOCKET_IO_DEBUG
					debugMethod.Invoke(ex.ToString());
#endif
                }
            }
        }
        /// <summary>
        /// 执行Lua方法
        /// </summary>
        public object[] CallMethod(string func, params object[] args)
        {
            return Util.CallMethod("Network", func, args);
        }

        ///------------------------------------------------------------------------------------
        public static void AddEvent(int _event, ByteBuffer data)
        {
            lock (m_lockObject)
            {
                mEvents.Enqueue(new KeyValuePair<int, ByteBuffer>(_event, data));
            }
        }

        /// <summary>
        /// 交给Command，这里不想关心发给谁。
        /// </summary>
        void Update()
        {
            if (mEvents.Count > 0)
            {
                while (mEvents.Count > 0)
                {
                    KeyValuePair<int, ByteBuffer> _event = mEvents.Dequeue();
                    facade.SendMessageCommand(NotiConst.DISPATCH_MESSAGE, _event);
                }
            }
            lock (eventQueueLock)
            {
                while (eventQueue.Count > 0)
                {
                    EmitEvent(eventQueue.Dequeue());
                }
            }

            lock (ackQueueLock)
            {
                while (ackQueue.Count > 0)
                {
                    InvokeAck(ackQueue.Dequeue());
                }
            }

            if (wsConnected != ws.IsConnected)
            {
                wsConnected = ws.IsConnected;
                if (wsConnected)
                {
                    EmitEvent("connect");
                }
                else
                {
                    EmitEvent("disconnect");
                }
            }

            // GC expired acks
            if (ackList.Count == 0) { return; }
            if (DateTime.Now.Subtract(ackList[0].time).TotalSeconds < ackExpirationTime) { return; }
            ackList.RemoveAt(0);
        }

        /// <summary>
        /// 发送链接请求
        /// </summary>
        public void SendConnect()
        {
            //SocketClient.SendConnect();
        }


        /// <summary>
        /// 发送SOCKET消息
        /// </summary>
        public void SendMessage(string ev)
        {
            //SocketClient.SendMessage(buffer);
            //EmitPacket
        }

        /// <summary>
        /// 析构函数
        /// </summary>
        new void OnDestroy()
        {
            //SocketClient.OnRemove();
            Debug.Log("~NetworkManager was destroy");
        }
        private void OnMessage(object sender, MessageEventArgs e)
        {
#if SOCKET_IO_DEBUG
			debugMethod.Invoke("[SocketIO] Raw message: " + e.Data);
#endif
            Packet packet = decoder.Decode(e);

            switch (packet.enginePacketType)
            {
                case EnginePacketType.OPEN: HandleOpen(packet); break;
                case EnginePacketType.CLOSE: EmitEvent("close"); break;
                case EnginePacketType.PING: HandlePing(); break;
                case EnginePacketType.PONG: HandlePong(); break;
                case EnginePacketType.MESSAGE: HandleMessage(packet); break;
            }
        }
        private void HandleOpen(Packet packet)
        {
#if SOCKET_IO_DEBUG
			debugMethod.Invoke("[SocketIO] Socket.IO sid: " + packet.json["sid"].str);
#endif
            sid = packet.json["sid"].str;
            EmitEvent("open");
        }
        private void HandlePing()
        {
            EmitPacket(new Packet(EnginePacketType.PONG));
        }

        private void HandlePong()
        {
            thPong = true;
            thPinging = false;
        }
        private void EmitPacket(Packet packet)
        {
#if SOCKET_IO_DEBUG
			debugMethod.Invoke("[SocketIO] " + packet);
#endif

            try
            {
                ws.Send(encoder.Encode(packet));
            }
            catch (SocketIOException ex)
            {
#if SOCKET_IO_DEBUG
				debugMethod.Invoke(ex.ToString());
#endif
            }
        }
        private void HandleMessage(Packet packet)
        {
            if (packet.json == null) { return; }

            if (packet.socketPacketType == SocketPacketType.ACK)
            {
                for (int i = 0; i < ackList.Count; i++)
                {
                    if (ackList[i].packetId != packet.id) { continue; }
                    lock (ackQueueLock) { ackQueue.Enqueue(packet); }
                    return;
                }

#if SOCKET_IO_DEBUG
				debugMethod.Invoke("[SocketIO] Ack received for invalid Action: " + packet.id);
#endif
            }

            if (packet.socketPacketType == SocketPacketType.EVENT)
            {
                SocketIOEvent e = parser.Parse(packet.json);
                lock (eventQueueLock) { eventQueue.Enqueue(e); }
            }
        }
        public void Emit(string ev)
        {
            EmitMessage(-1, string.Format("[\"{0}\"]", ev));
        }

        public void Emit(string ev, Action<JSONObject> action)
        {
            EmitMessage(++packetId, string.Format("[\"{0}\"]", ev));
            ackList.Add(new Ack(packetId, action));
        }

        public void Emit(string ev, JSONObject data)
        {
            EmitMessage(-1, string.Format("[\"{0}\",{1}]", ev, data));
        }

        public void Emit(string ev, string data, Action<JSONObject> action)
        {
            EmitMessage(++packetId, string.Format("[\"{0}\",{1}]", ev, data));
            ackList.Add(new Ack(packetId, action));
        }
        private void EmitMessage(int id, string raw)
        {
            EmitPacket(new Packet(EnginePacketType.MESSAGE, SocketPacketType.EVENT, 0, "/", id, new JSONObject(raw)));
        }

        private void EmitClose()
        {
            EmitPacket(new Packet(EnginePacketType.MESSAGE, SocketPacketType.DISCONNECT, 0, "/", -1, new JSONObject("")));
            EmitPacket(new Packet(EnginePacketType.CLOSE));
        }
        private void InvokeAck(Packet packet)
        {
            Ack ack;
            for (int i = 0; i < ackList.Count; i++)
            {
                if (ackList[i].packetId != packet.id) { continue; }
                ack = ackList[i];
                ackList.RemoveAt(i);
                ack.Invoke(packet.json);
                return;
            }
        }
        /// <summary>
        /// 发送SOCKET.IO消息
        /// </summary>
        public void SendSocketMsg(string ev, string data)
        {
            if (data == "")
            {
                Emit(ev, OnServerListenerCallback);
            }
            else
            {
                Emit(ev, data, OnServerListenerCallback);
            }
            

        }
        public void OnServerListenerCallback(JSONObject json)
        {
            //string str = json.ToString().Replace("\\", "");
            //str = str.Trim().TrimStart("[\"".ToCharArray());
            //str = str.Trim().TrimEnd("\"]".ToCharArray());
            CallMethod("OnServerListenerCallback", json.ToString());
            //var Object = JsonConvert.DeserializeObject<CharacterListItem>(str);
            //Debug.Log(string.Format("OnServerListenerCallback data: {0}", json));
        }
        public IEnumerator WaitForSeconds(float i)
        {
            yield return new WaitForSeconds(i);
            CallMethod("WaitForSeconds");
        }

    }
}