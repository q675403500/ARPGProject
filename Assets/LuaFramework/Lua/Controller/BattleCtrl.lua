require "Common/define"

require "3rd/pblua/login_pb"
require "3rd/pbc/protobuf"

local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

BattleCtrl = {};
local this = BattleCtrl;

local Battle;
local transform;
local gameObject;
local Openwindow;

--构建函数--
function BattleCtrl.New()
	logWarn("BattleCtrl.New--->>");
	return this;
end

function BattleCtrl.Awake()
	logWarn("BattleCtrl.Awake--->>");

	panelMgr:CreatePrefabPanel('Battle','Normal', this.OnCreate);
end

--启动事件--
function BattleCtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform;
	Openwindow = gameObject:GetComponent('OpenWindow');
	Openwindow:Open('Normal');
	Battle = gameObject:GetComponent('LuaBehaviour');
	Battle:AddClick(BattlePanel.btnBattle, this.OnBattle);

	logWarn("Start lua--->>"..gameObject.name);
	BattleCtrl.BattleInfo(UserData_GetFight(),1)
end

--单击事件--
function BattleCtrl.OnBattle(go)
	soundMgr:PlayAudioClip('Audio/Button-1');
	networkMgr:SendSocketMsg("get account","");
    Openwindow:Close();
end

function BattleCtrl.net_bind(res)
	if res["code"] and res["code"] == 0 then
		this.OnClose(go)
		networkMgr:SendSocketMsg("get account","");
    end
	UserData_login(res)
end

function BattleCtrl.BattleInfo(info,num)
	if num == 1 then
		BattlePanel.Name:GetComponent('Text').text = UserData_GetPet()
	end
	if not info[num] then
		BattlePanel.btnBattle:SetActive(true);
		return
	end
	coroutine.start(function()
		coroutine.wait(3)
		BattlePanel.Info:GetComponent('Text').text = info[num]
		num = num + 1
		BattleCtrl.BattleInfo(info,num)
	end)
end

--测试发送SPROTO--
function BattleCtrl.TestSendSproto()
	local name = GetPetPanel.Name:GetComponent('Text').text
	local buffer = {
		name = name
	}
	networkMgr:SendSocketMsg("bind pet",TableToStr(buffer));
end
--关闭事件--
function BattleCtrl.Close()
	panelMgr:ClosePanel("Battle");
end