require 'setup/setup'

local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

describe("2.1.2.1: When fulfilled, a promise: must not transition to any other state.", function()
    testFulfilled(dummy, function(promise, done)
        local onFulfilledCalled = false

        promise:Then(function()
            onFulfilledCalled = true
        end, function()
            assert.equal(onFulfilledCalled, false)
            done()
        end)

        setTimeout(done, 100)
    end)

    specify("trying to fulfill then immediately reject", function(done)
        local d = deferred()
        local onFulfilledCalled = false

        d.promise:Then(function()
            onFulfilledCalled = true
        end, function()
            assert.equal(onFulfilledCalled, false)
            done()
        end)

        d.resolve(dummy)
        d.reject(dummy)
        setTimeout(done, 100)
    end)

    specify("trying to fulfill then reject, delayed", function(done)
        local d = deferred()
        local onFulfilledCalled = false

        d.promise:Then(function()
            onFulfilledCalled = true
        end, function()
            assert.equal(onFulfilledCalled, false)
            done()
        end)

        setTimeout(function()
            d.resolve(dummy)
            d.reject(dummy)
        end, 50)
        setTimeout(done, 100)
    end)

    specify("trying to fulfill immediately then reject delayed", function(done)
        local d = deferred()
        local onFulfilledCalled = false

        d.promise:Then(function()
            onFulfilledCalled = true
        end, function()
            assert.equal(onFulfilledCalled, false)
            done()
        end)

        d.resolve(dummy)
        setTimeout(function()
            d.reject(dummy)
        end, 50)
        setTimeout(done, 100)
    end)
end)