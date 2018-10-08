local transform;
local gameObject;

GetPetPanel = {};
local this = GetPetPanel;

--启动事件--
function GetPetPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;
	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function GetPetPanel.InitPanel()
	this.btnClose = transform:Find("Close").gameObject;
	this.btnGet = transform:Find("Get").gameObject;
	this.Name = transform:Find("Petname/name/Text").gameObject;
end

--单击事件--
function GetPetPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

