require "Common/define"
require "3rd/pblua/login_pb"
require "3rd/pbc/protobuf"

local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

LoginCtrl = {};
local this = LoginCtrl;

local Login;
local transform;
local gameObject;

--构建函数--
function LoginCtrl.New()
	logWarn("LoginCtrl.New--->>");
	return this;
end

function LoginCtrl.Awake()
	logWarn("LoginCtrl.Awake--->>");

	panelMgr:CreatePrefabPanel('Login','Normal', this.OnCreate);
end

--启动事件--
function LoginCtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform;
	Login = gameObject:GetComponent('LuaBehaviour');
	Login:AddClick(LoginPanel.btnLogin, this.OnLogin);
	Login:AddClick(LoginPanel.btnCreatenew, this.OnCreatenew);
	logWarn("Start lua--->>"..gameObject.name);
end

--单击事件--
function LoginCtrl.OnLogin(go)
	soundMgr:PlayAudioClip('Audio/Button-3');
    this.TestSendSproto();
end

function LoginCtrl.OnCreatenew(go)
	soundMgr:PlayAudioClip('Audio/Button-5');
	CreatePrefab(CtrlNames.Sign)
end

--测试发送SPROTO--
function LoginCtrl.TestSendSproto()
	local name = LoginPanel.Name:GetComponent('Text').text
	local pass = LoginPanel.Pass:GetComponent('Text').text
	local buffer = {
		nickname = name,
		password = pass
	}
	networkMgr:SendSocketMsg("login",TableToStr(buffer));
end
function LoginCtrl.net_login(res)
	UserData_login(res)
end
--关闭事件--
function LoginCtrl.Close()
	panelMgr:ClosePanel(CtrlNames.Login);
end