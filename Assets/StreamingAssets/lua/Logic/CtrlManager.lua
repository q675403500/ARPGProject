require "Common/define"
require "Controller/loginCtrl"
require "Controller/SignCtrl"
require "Controller/MessageCtrl"
require "Controller/GetPetCtrl"
require "Controller/PetCtrl"
require "Controller/BattleCtrl"

CtrlManager = {};
local this = CtrlManager;
local ctrlList = {};	--控制器列表--

function CtrlManager.Init()
	logWarn("CtrlManager.Init----->>>");
	ctrlList[CtrlNames.Login] = LoginCtrl.New();
	ctrlList[CtrlNames.Sign] = SignCtrl.New();
	ctrlList[CtrlNames.Message] = MessageCtrl.New();
	ctrlList[CtrlNames.GetPet] = GetPetCtrl.New();
	ctrlList[CtrlNames.Pet] = PetCtrl.New();
	ctrlList[CtrlNames.Battle] = BattleCtrl.New();

	return this;
end

--添加控制器--
function CtrlManager.AddCtrl(ctrlName, ctrlObj)
	ctrlList[ctrlName] = ctrlObj;
end

--获取控制器--
function CtrlManager.GetCtrl(ctrlName)
	return ctrlList[ctrlName];
end

--移除控制器--
function CtrlManager.RemoveCtrl(ctrlName)
	ctrlList[ctrlName] = nil;
end

--关闭控制器--
function CtrlManager.Close()
	logWarn('CtrlManager.Close---->>>');
end