local code          = nil
local msg           = nil

function UserData_init()
    code          = nil
    msg           = nil
end

function UserData_login(res)
    if res["code"] and res["code"] ~= nil then
        code = res["code"]
    end
    if res["msg"] and res["msg"] ~= nil then
        msg = res["msg"]
    end
	CreatePrefab(CtrlNames.Message)
end

function UserData_GetCode()
    return code or nil
end

function UserData_Getmsg()
    return msg or nil
end