local transform;
local gameObject;

PetPanel = {};
local this = PetPanel;

--启动事件--
function PetPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;
	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function PetPanel.InitPanel()
	this.btnbattle = transform:Find("battle").gameObject;
	this.btnCreate = transform:Find("PetList/pet1/Create").gameObject;
	this.PetIcon = transform:Find("PetList/pet1/Icon").gameObject;
	this.PetName = transform:Find("PetList/pet1/Icon/Text").gameObject;
	this.PetBg = transform:Find("PetList/pet1/Icon/Bg").gameObject;
	this.Select = transform:Find("Headline").gameObject;
	this.PetInfo = transform:Find("PetInfo").gameObject;
end

--单击事件--
function PetPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

