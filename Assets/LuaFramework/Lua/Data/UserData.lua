local code          = nil
local msg           = nil
local playerInfo    = {}
local GetPet        = nil
local PetList       = {}
local BattleInfo    = {}

function UserData_init()
    code          = nil
    msg           = nil
    playerInfo    = {}
    GetPet        = nil
    PetList       = {}
    BattleInfo    = {}
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

function UserData_SetPlayerInfo(res)

    if res["code"] and res["code"] == 0 then
 
        if res["_id"] and res["_id"] ~= nil then
            playerInfo._id = res["_id"]
        end
        if res["uid"] and res["uid"] ~= nil then
            playerInfo.uid = res["uid"]
        end
        if res["nickname"] and res["nickname"] ~= nil then
            playerInfo.nickname = res["nickname"]
        end
        if res["data"]["pets"] and res["data"]["pets"] ~= nil then
         
            playerInfo.pets = res["data"]["pets"]
            local buffer = {
                pid = res["data"]["pets"][1]
            }
            networkMgr:SendSocketMsg("get pet",TableToStr(buffer));
        end
    else
        UserData_login(res)
    end
end

function UserData_GetPlayerInfo()
    return playerInfo or nil
end

function UserData_SetPet(str)
    GetPet = str
end

function UserData_GetPet()
    return GetPet or nil
end

function UserData_SetPetList(List)
    PetList = List
    PetCtrl.SetPetInfo(List)
end

function UserData_GetPetList()
    return PetList or nil
end

function UserData_MatchFight(res)
    if res["code"] == 0 then
        --BattleCtrl.BattleInfo(res)
        BattleInfo    = res["data"]["fightLogs"]
        CreatePrefab(CtrlNames.Battle)
    else
        --UserData_login(res[data][fightLogs],1)
        UserData_login(res)
    end
end

function UserData_GetFight()
    return BattleInfo
end