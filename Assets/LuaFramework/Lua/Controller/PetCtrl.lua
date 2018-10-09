require "Common/define"

require "3rd/pblua/login_pb"
require "3rd/pbc/protobuf"

local sproto = require "3rd/sproto/sproto"
local core = require "sproto.core"
local print_r = require "3rd/sproto/print_r"

PetCtrl = {};
local this = PetCtrl;

local Pet;
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
	Pet = gameObject:GetComponent('LuaBehaviour');
	Pet:AddClick(PetPanel.btnbattle, this.Onbattle);
	Pet:AddClick(PetPanel.btnCreate, this.OnCreatePet);
	Pet:AddClick(PetPanel.PetIcon, this.OnSelect);
	logWarn("Start lua--->>"..gameObject.name);
	networkMgr:SendSocketMsg("get account","");
end

--单击事件--
function PetCtrl.Onbattle(go)
	soundMgr:PlayAudioClip('Audio/Button-5');
	if UserData_GetPet() == nil then
		local info = {
			["code"] = "Notice",
			["msg"] = "请选择宠物！"
		}
		UserData_login(info)
	else
		local buffer = {
			pid = UserData_GetPetList()["data"]["pid"]
		}
		networkMgr:SendSocketMsg("match fight",TableToStr(buffer));
	end
	--CreatePrefab(CtrlNames.GetPet)
end

function PetCtrl.OnCreatePet(go)
	soundMgr:PlayAudioClip('Audio/Button-5');
	CreatePrefab(CtrlNames.GetPet)
end

function PetCtrl.OnClose(go)
	soundMgr:PlayAudioClip('Audio/Button-1');
	Openwindow:Close();
	--this.Close()
end

function PetCtrl.OnSelect(go)
	soundMgr:PlayAudioClip('Audio/Button-3');
	PetPanel.Select:GetComponent('Text').text = PetPanel.PetName:GetComponent('Text').text
	UserData_SetPet(PetPanel.Select:GetComponent('Text').text)
	local info = ""
	for i,v in pairs(UserData_GetPetList()["data"]) do
		if i == "_id" or i == "name" or i == "uid" or i == "type" then
			
		else
			info = info..i..":"..v.."\n"
		end
	end
	PetPanel.PetInfo:GetComponent('Text').text = info
	--this.Close()
end

function PetCtrl.SetPetInfo(Pets)
	PetPanel.btnCreate:SetActive(false);
	PetPanel.PetIcon:SetActive(true);
	PetPanel.PetName:GetComponent('Text').text = tostring(Pets["data"]["name"]);
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