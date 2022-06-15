function zo_mixin(object, ...)
    for i = 1, select("#", ...) do
        local source = select(i, ...)
        for k,v in pairs(source) do
            object[k] = v
        end
    end
end

require 'esoui/baseobject'
local uv = require('luv')

local function EmitMessage(text)
    if(text == "") then
        text = "[Empty String]"
    end

    print(text)
end

local function EmitTable(t, indent, tableHistory)
    indent          = indent or "."
    tableHistory    = tableHistory or {}

    for k, v in pairs(t) do
        local vType = type(v)

        EmitMessage(indent.."("..vType.."): "..tostring(k).." = "..tostring(v))

        if(vType == "table") then
            if(tableHistory[v]) then
                EmitMessage(indent.."Avoiding cycle on table...")
            else
                tableHistory[v] = true
                EmitTable(v, indent.."  ", tableHistory)
            end
        end
    end
end

function d(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if(type(value) == "table") then
            EmitTable(value)
        else
            EmitMessage(tostring(value))
        end
    end
end

function df(formatter, ...)
    return d(formatter:format(...))
end

function setTimeout(func, timeout)
    local timer = uv.new_timer()
    timer:start(timeout, 0, function()
        timer:close()
        func()
    end)
    return timer
end

local ZO_CallLaterId = 1
local timers = {}
function zo_callLater(func, ms)
    local id = ZO_CallLaterId
    local name = "CallLaterFunction"..id
    ZO_CallLaterId = ZO_CallLaterId + 1

    timers[name] = setTimeout(function()
        timers[name] = nil
        func(id)
    end, ms)
    return id
end

function zo_removeCallLater(id)
    local name = "CallLaterFunction"..id
    if timers[name] then
        timers[name]:close()
        timers[name] = nil
    end
end

local isRunning = false
function resolveTimeouts()
    if(isRunning) then return end
    isRunning = true
    uv.run()
    timers = {}
    isRunning = false
end
