local transform;
local gameObject;

BattlePanel = {};
local this = BattlePanel;

--启动事件--
function BattlePanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;
	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function BattlePanel.InitPanel()
	this.btnBattle = transform:Find("battle").gameObject;
	this.Pet = transform:Find("Pet").gameObject;
	this.Name = transform:Find("Pet/Icon/Text").gameObject;
	this.Info = transform:Find("Headline").gameObject;
end



--单击事件--
function BattlePanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end

