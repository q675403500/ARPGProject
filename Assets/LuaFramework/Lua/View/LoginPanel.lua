local transform;
local gameObject;

LoginPanel = {};
local this = LoginPanel;

--启动事件--
function LoginPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;
	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function LoginPanel.InitPanel()
	this.btnLogin = transform:Find("Login").gameObject;
	this.btnCreatenew = transform:Find("Createnew").gameObject;
	this.Name = transform:Find("Username/name/Text").gameObject;
	this.Pass = transform:Find("Password/pass/Text").gameObject;
end

--单击事件--
function LoginPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

