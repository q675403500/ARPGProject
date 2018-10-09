local transform;
local gameObject;

SignPanel = {};
local this = SignPanel;

--启动事件--
function SignPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;
	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function SignPanel.InitPanel()
	this.btnSign = transform:Find("Sign").gameObject;
	this.btnClose = transform:Find("Close").gameObject;
	this.Name = transform:Find("Username/name/Text").gameObject;
	this.Pass = transform:Find("Password/pass/Text").gameObject;
end

--单击事件--
function SignPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

