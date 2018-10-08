--require "Logic/CtrlManager"
require "Common/tools"

function Process(res)
	local msgAction = res["action"]
	local jsdata   	= res["data"]
	if msgAction == "login" then
		LoginCtrl.net_login(jsdata)
	elseif msgAction == "register" then
		SignCtrl.net_sign(jsdata)
	end
end