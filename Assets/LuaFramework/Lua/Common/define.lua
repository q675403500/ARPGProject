
CtrlNames = {
	Login = "LoginCtrl",
	Sign  = "SignCtrl",
	Message = "MessageCtrl",
	GetPet = "GetPetCtrl",
	Pet = "PetCtrl",
	Battle = "BattleCtrl",
}

PanelNames = {
	"LoginPanel",
	"SignPanel",
	"MessagePanel",
	"GetPetPanel",
	"PetPanel",
	"BattlePanel",
}

--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}
--当前使用的协议类型--
TestProtoType = ProtocalType.BINARY;

Util = LuaFramework.Util;
AppConst = LuaFramework.AppConst;
LuaHelper = LuaFramework.LuaHelper;
ByteBuffer = LuaFramework.ByteBuffer;

resMgr = LuaHelper.GetResManager();
panelMgr = LuaHelper.GetPanelManager();
soundMgr = LuaHelper.GetSoundManager();
networkMgr = LuaHelper.GetNetManager();
util = LuaHelper.GetUtilManager();


WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject;