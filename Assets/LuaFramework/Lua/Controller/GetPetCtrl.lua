require "Common/define"

require "3rd/pblua/login_pb"
require "3rd/pbc/protobuf"

local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

GetPetCtrl = {};
local this = GetPetCtrl;

local GetPet;
local transform;
local gameObject;
local Openwindow;

--构建函数--
function GetPetCtrl.New()
	logWarn("GetPetCtrl.New--->>");
	return this;
end

function GetPetCtrl.Awake()
	logWarn("GetPetCtrl.Awake--->>");

	panelMgr:CreatePrefabPanel('GetPet','Normal', this.OnCreate);
end

--启动事件--
function GetPetCtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform;
	Openwindow = gameObject:GetComponent('OpenWindow');
	Openwindow:Open('Normal');
	GetPet = gameObject:GetComponent('LuaBehaviour');
	GetPet:AddClick(GetPetPanel.btnClose, this.OnClose);
	GetPet:AddClick(GetPetPanel.btnGet, this.OnGet);
	logWarn("Start lua--->>"..gameObject.name);
end

--单击事件--
function GetPetCtrl.OnGet(go)
	soundMgr:PlayAudioClip('Audio/Button-3');
    this.TestSendSproto();
end

function GetPetCtrl.OnClose(go)
	soundMgr:PlayAudioClip('Audio/Button-1');
	Openwindow:Close();
	--this.Close()
end

function GetPetCtrl.net_bind(res)
	if res["code"] and res["code"] == 0 then
		this.OnClose(go)
		networkMgr:SendSocketMsg("get account","");
    end
	UserData_login(res)
end

--测试发送SPROTO--
function GetPetCtrl.TestSendSproto()
	local name = GetPetPanel.Name:GetComponent('Text').text
	local buffer = {
		name = name
	}
	networkMgr:SendSocketMsg("bind pet",TableToStr(buffer));
end
--关闭事件--
function GetPetCtrl.Close()
	panelMgr:ClosePanel("GetPet");
end