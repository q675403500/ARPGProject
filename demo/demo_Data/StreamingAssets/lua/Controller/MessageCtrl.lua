
MessageCtrl = {};
local this = MessageCtrl;

local message;
local transform;
local gameObject;
local Openwindow;

--构建函数--
function MessageCtrl.New()
	logWarn("MessageCtrl.New--->>");
	return this;
end

function MessageCtrl.Awake()
	logWarn("MessageCtrl.Awake--->>");
	--traceobj(res)
	panelMgr:CreatePrefabPanel('Message','Tip', this.OnCreate);
end

--启动事件--
function MessageCtrl.OnCreate(obj)
	gameObject = obj;
	Openwindow = gameObject:GetComponent('OpenWindow');
	Openwindow:Open('Tip');
	message = gameObject:GetComponent('LuaBehaviour');
	message:AddClick(MessagePanel.btnClose, this.OnClose);
	MessagePanel.txtHead:GetComponent('Text').text = tostring(UserData_GetCode());
	MessagePanel.txtNotice:GetComponent('Text').text = tostring(UserData_Getmsg());
	logWarn("Start lua--->>"..gameObject.name);
end

--关闭事件--
function MessageCtrl.OnClose()
	soundMgr:PlayAudioClip('Audio/Button-1');
	Openwindow:Close();
	--panelMgr:ClosePanel(CtrlNames.Message);
end