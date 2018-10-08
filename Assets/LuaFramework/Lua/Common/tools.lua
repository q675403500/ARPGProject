local string_find = string.find
local string_sub = string.sub
local table_insert = table.insert
local json = require "cjson"
local __coupdate_timer = {}
local __coupdate_toadd = {}
local __pool = {}
local action_pool = {}

function ToStringEx(value)
    if type(value)=='table' then
       return TableToStr(value)
    elseif type(value)=='string' then
		return "\""..value.."\""
		--return value
    else
       return tostring(value)
    end
end

function TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..ToStringEx(key)..":"..ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e"..":"..ToStringEx(value)
                else
                    retstr = retstr..signal..key..":"..ToStringEx(value)
                end
            end
        end

        i = i+1
	end
	retstr = retstr.."}"
	return retstr
end

function StrToTable(str)
    local t = type(str)
    local _action = ""
    local _data = nil
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
	end
    --data["action"] = string.split(str,"\"")[2]
    local sc = json.decode(str)
    if sc[1] and type(sc[1]) == "string" then
        _action = sc[1]
    end
    if sc[2] and (type(sc[2]) ~= "nil" and type(sc[2]) ~= "") then
        _data = json.decode(sc[2])
    end
    return {action = _action,data = _data}
end

--打印树形对象
function traceObj(value)
    if value == nil then
        print(desciption, " +traceObj = nil")
        return
    end

    if type(nesting) ~= "number" then nesting = 5 end

    local lookupTable = {}
    local result = {}

    local filterString = filterString or false

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    --local traceback = string.split(debug.traceback("", 2), "\n")
    --trace("dump from: " .. string.trim(traceback[3]))

    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            if filterString == false then
                result[#result +1 ] = string.format("%s[%s]%s = %s,", indent, _v(desciption), spc, _v(value))
            end
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s},", indent)
            end        end
    end
    _dump(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string_find(input, delimiter, pos, true) end do
        table_insert(arr, string_sub(input, pos, st - 1))
        pos = sp + 1
    end
    table_insert(arr, string_sub(input, pos))
    return arr
end

-- 等待秒数，并在Update执行完毕后resume
-- 等同于Unity侧的yield return new WaitForSeconds
function waitforseconds(seconds)
	assert(type(seconds) == "number" and seconds >= 0)
	local co = coroutine.running() or error ("coroutine.waitforsenconds must be run in coroutine")
	local timer = GetCoTimer()
	local action = __GetAction(co, timer)
	
	--timer:Init(seconds, __Action, action, true)
 	timer:Start()
	action_map[co] = action
 	return coroutine.yield()
end

-- 获取CoUpdate定时器
function GetCoTimer( delay, func, obj, one_shot, use_frame, unscaled)
	assert(not __coupdate_timer[timer] and not __coupdate_toadd[timer])
	local timer = InnerGetTimer( delay, func, obj, one_shot, use_frame, unscaled)
	__coupdate_toadd[timer] = true
	return timer
end

-- 获取定时器
function InnerGetTimer( delay, func, obj, one_shot, use_frame, unscaled)
	local timer = nil
	if #__pool > 0 then
		timer = table.remove(__pool)
		if delay and func then
			timer:Init(delay, func, obj, one_shot, use_frame, unscaled)
		end
	else
		timer = Timer.New(delay, func, obj, one_shot, use_frame, unscaled)
	end
	return timer
end

function __GetAction(co, timer, func, args, result)
	local action = nil
	if #action_pool > 0 then
		action = table.remove(action_pool)
	else
		action = {false, false, false, false, false}
	end
	action.co = co and co or false
	action.timer = timer and timer or false
	action.func = func and func or false
	action.args = args and args or false
	action.result = result and result or false
	return action
end