require "Common/define"

require "3rd/pblua/login_pb"
require "3rd/pbc/protobuf"

local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

SignCtrl = {};
local this = SignCtrl;

local Sign;
local transform;
local gameObject;
local Openwindow;

--构建函数--
function SignCtrl.New()
	logWarn("SignCtrl.New--->>");
	return this;
end

function SignCtrl.Awake()
	logWarn("SignCtrl.Awake--->>");

	panelMgr:CreatePrefabPanel('Sign','Normal', this.OnCreate);
end

--启动事件--
function SignCtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform;
	Openwindow = gameObject:GetComponent('OpenWindow');
	Openwindow:Open('Normal');
	Sign = gameObject:GetComponent('LuaBehaviour');
	Sign:AddClick(SignPanel.btnSign, this.OnSign);
	Sign:AddClick(SignPanel.btnClose, this.OnClose);
	logWarn("Start lua--->>"..gameObject.name);
end

--单击事件--
function SignCtrl.OnSign(go)
	soundMgr:PlayAudioClip('Audio/Button-3');
    this.TestSendSproto();
end

function SignCtrl.OnClose(go)
	soundMgr:PlayAudioClip('Audio/Button-1');
	Openwindow:Close();
	--this.Close()
end

function SignCtrl.net_sign(res)
	UserData_login(res)
	if res["code"] and res["code"] == 0 then
		this.OnClose(go)
    end
end

--测试发送SPROTO--
function SignCtrl.TestSendSproto()
	local name = SignPanel.Name:GetComponent('Text').text
	local pass = SignPanel.Pass:GetComponent('Text').text
	local buffer = {
		nickname = name,
		password = pass
	}
	networkMgr:SendSocketMsg("register",TableToStr(buffer));
end
--关闭事件--
function SignCtrl.Close()
	panelMgr:ClosePanel("Sign");
end