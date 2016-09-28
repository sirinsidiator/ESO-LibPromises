-- This module exports some valid rejection reason factories, keyed by human-readable versions of their names.

local dummy = { dummy = "dummy" }

local exports = {}

exports["`nil`"] = function()
    return nil
end

exports["`false`"] = function()
    return false
end

exports["`0`"] = function()
    return 0
end

exports["a table"] = function()
    return {}
end

exports["an always-pending thenable"] = function()
    return { Then = function() end }
end

exports["a fulfilled promise"] = function()
    return resolved(dummy)
end

exports["a rejected promise"] = function()
    return rejected(dummy)
end

return exports