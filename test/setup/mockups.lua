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
end
zo_callLater = setTimeout

function resolveTimeouts()
    uv.run()
end
