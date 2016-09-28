local other = { other = "other" } -- a value we don't want to be strict equal to

local exports = {}

exports.fulfilled = {
    ["a synchronously-fulfilled custom thenable"] = function(value)
        return {
            Then = function(self, onFulfilled)
                onFulfilled(value)
            end
        }
    end,

    ["an asynchronously-fulfilled custom thenable"] = function(value)
        return {
            Then = function(self, onFulfilled)
                setTimeout(function()
                    onFulfilled(value)
                end, 0)
            end
        }
    end,

    ["a synchronously-fulfilled one-time thenable"] = function(value)
        local numberOfTimesThenRetrieved = 0
        return {
            Then = function(self, onFulfilled)
                if (numberOfTimesThenRetrieved == 0) then
                    numberOfTimesThenRetrieved = numberOfTimesThenRetrieved + 1
                    onFulfilled(value)
                end
            end
        }
    end,

    ["a thenable that tries to fulfill twice"] = function(value)
        return {
            Then = function(self, onFulfilled)
                onFulfilled(value)
                onFulfilled(other)
            end
        }
    end,

    ["a thenable that fulfills but then throws"] = function(value)
        return {
            Then = function(self, onFulfilled)
                onFulfilled(value)
                error(other)
            end
        }
    end,

    ["an already-fulfilled promise"] = function(value)
        return resolved(value)
    end,

    ["an eventually-fulfilled promise"] = function(value)
        local d = deferred()
        setTimeout(function()
            d.resolve(value)
        end, 50)
        return d.promise
    end
}

exports.rejected = {
    ["a synchronously-rejected custom thenable"] = function(reason)
        return {
            Then = function(self, onFulfilled, onRejected)
                onRejected(reason)
            end
        }
    end,

    ["an asynchronously-rejected custom thenable"] = function(reason)
        return {
            Then = function(self, onFulfilled, onRejected)
                setTimeout(function()
                    onRejected(reason)
                end, 0)
            end
        }
    end,

    ["a synchronously-rejected one-time thenable"] = function(reason)
        local numberOfTimesThenRetrieved = 0
        return {
            Then = function(self, onFulfilled, onRejected)
                if (numberOfTimesThenRetrieved == 0) then
                    numberOfTimesThenRetrieved = numberOfTimesThenRetrieved + 1
                    onRejected(reason)
                end
            end
        }
    end,

    ["a thenable that immediately throws in `then`"] = function(reason)
        return {
            Then = function()
                error(reason)
            end
        }
    end,

    ["an object with a throwing `then` accessor"] = function(reason)
        return setmetatable({}, {
            __index = function()
                error(reason)
            end
        })
    end,

    ["an already-rejected promise"] = function(reason)
        return rejected(reason)
    end,

    ["an eventually-rejected promise"] = function(reason)
        local d = deferred()
        setTimeout(function()
            d.reject(reason)
        end, 50)
        return d.promise
    end
}

return exports