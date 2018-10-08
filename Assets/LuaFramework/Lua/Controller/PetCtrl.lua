require "Common/define"

require "3rd/pblua/login_pb"
require "3rd/pbc/protobuf"

local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

PetCtrl = {};
local this = PetCtrl;

local Sign;
local transform;
local gameObject;
local Openwindow;

--构建函数--
function PetCtrl.New()
	logWarn("PetCtrl.New--->>");
	return this;
end

function PetCtrl.Awake()
	logWarn("PetCtrl.Awake--->>");

	panelMgr:CreatePrefabPanel('Pet','Normal', this.OnCreate);
end

--启动事件--
function PetCtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform;
	Openwindow = gameObject:GetComponent('OpenWindow');
	Openwindow:Open('Normal');
	Sign = gameObject:GetComponent('LuaBehaviour');
	Sign:AddClick(SignPanel.btnbattle, this.Onbattle);
	Sign:AddClick(SignPanel.btnCreate, this.OnCreate);
	logWarn("Start lua--->>"..gameObject.name);
end

--单击事件--
function PetCtrl.Onbattle(go)
	soundMgr:PlayAudioClip('Audio/Button-5');
	CreatePrefab(CtrlNames.GetPet)
end

function PetCtrl.OnClose(go)
	soundMgr:PlayAudioClip('Audio/Button-1');
	Openwindow:Close();
	--this.Close()
end

function PetCtrl.net_sign(res)
	UserData_login(res)
	this.OnClose(go)
end

--测试发送SPROTO--
function PetCtrl.TestSendSproto()
	local name = SignPanel.Name:GetComponent('Text').text
	local pass = SignPanel.Pass:GetComponent('Text').text
	local buffer = {
		nickname = name,
		password = pass
	}
	networkMgr:SendSocketMsg("register",TableToStr(buffer));
end
--关闭事件--
function PetCtrl.Close()
	panelMgr:ClosePanel("Sign");
end