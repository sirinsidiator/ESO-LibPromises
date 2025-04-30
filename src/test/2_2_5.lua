require 'setup/setup'

local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

describe("2.2.5 `onFulfilled` and `onRejected` must be called as functions (i.e. with no `this` value).", function()
    specify("fulfilled", function(done)
        resolved(dummy):Then(function(...)
            -- Lua does not have an equivalent for this test, so we just check if the argument count is 1 instead
            assert.equal(select("#", ...), 1)
            done()
        end)
    end)

    specify("rejected", function(done)
        rejected(dummy):Then(null, function(...)
            -- Lua does not have an equivalent for this test, so we just check if the argument count is 1 instead
            assert.equal(select("#", ...), 1)
            done()
        end)
    end)
end)
