local Promise = LibPromises

function resolved(value)
    local p = Promise:New()
    p:Resolve(value)
    return p
end

function rejected(value)
    local p = Promise:New()
    p:Reject(value)
    return p
end

function deferred()
    local p = Promise:New()
    return {
        promise = p,
        resolve = function(value) return p:Resolve(value) end,
        reject = function(reason) return p:Reject(reason) end,
    }
end
