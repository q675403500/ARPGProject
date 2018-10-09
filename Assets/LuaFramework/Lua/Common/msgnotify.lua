--require "Logic/CtrlManager"
require "Common/tools"

function Process(res)
	local msgAction = res["action"]
	local jsdata   	= res["data"]
	if msgAction == "login" then
		LoginCtrl.net_login(jsdata)
	elseif msgAction == "register" then
		SignCtrl.net_sign(jsdata)
	elseif msgAction == "get account" then
		UserData_SetPlayerInfo(jsdata)
	elseif msgAction == "get pet" then
		--PetCtrl.SetPetInfo(jsdata)
		UserData_SetPetList(jsdata)
	elseif msgAction == "bind pet" then
		GetPetCtrl.net_bind(jsdata)
	elseif msgAction == "match fight" then
		UserData_MatchFight(jsdata)
	end
end