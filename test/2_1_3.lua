require 'setup/setup'

local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

describe("2.1.3.1: When rejected, a promise: must not transition to any other state.", function()
    testRejected(dummy, function(promise, done)
        local onRejectedCalled = false

        promise:Then(function()
            assert.equal(onRejectedCalled, false)
            done()
        end, function()
            onRejectedCalled = true
        end)

        setTimeout(done, 100)
    end)

    specify("trying to reject then immediately fulfill", function(done)
        local d = deferred()
        local onRejectedCalled = false

        d.promise:Then(function()
            assert.equal(onRejectedCalled, false)
            done()
        end, function()
            onRejectedCalled = true
        end)

        d.reject(dummy)
        d.resolve(dummy)
        setTimeout(done, 100)
    end)

    specify("trying to reject then fulfill, delayed", function (done)
        local d = deferred()
        local onRejectedCalled = false

        d.promise:Then(function()
            assert.equal(onRejectedCalled, false)
            done()
        end, function()
            onRejectedCalled = true
        end)

        setTimeout(function()
            d.reject(dummy)
            d.resolve(dummy)
        end, 50)
        setTimeout(done, 100)
    end)

    specify("trying to reject immediately then fulfill delayed", function(done)
        local d = deferred()
        local onRejectedCalled = false

        d.promise:Then(function()
            assert.equal(onRejectedCalled, false)
            done()
        end, function()
            onRejectedCalled = true
        end)

        d.reject(dummy)
        setTimeout(function()
            d.resolve(dummy)
        end, 50)
        setTimeout(done, 100)
    end)
end)
