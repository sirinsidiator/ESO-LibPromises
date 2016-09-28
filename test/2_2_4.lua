require 'setup/setup'

local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

describe("2.2.4: `onFulfilled` or `onRejected` must not be called until the execution context stack contains only platform code.", function()
    describe("`then` returns before the promise becomes fulfilled or rejected", function()
        testFulfilled(dummy, function(promise, done)
            local thenHasReturned = false

            promise:Then(function()
                assert.equal(thenHasReturned, true)
                done()
            end)

            thenHasReturned = true
        end)
        testRejected(dummy, function(promise, done)
            local thenHasReturned = false

            promise:Then(nil, function()
                assert.equal(thenHasReturned, true)
                done()
            end)

            thenHasReturned = true
        end)
    end)

    describe("Clean-stack execution ordering tests (fulfillment case)", function()
        specify("when `onFulfilled` is added immediately before the promise is fulfilled", function(done)
            local d = deferred()
            local onFulfilledCalled = false

            d.promise:Then(function()
                onFulfilledCalled = true
                done()
            end)

            d.resolve(dummy)

            assert.equal(onFulfilledCalled, false)
        end)

        specify("when `onFulfilled` is added immediately after the promise is fulfilled", function(done)
            local d = deferred()
            local onFulfilledCalled = false

            d.resolve(dummy)

            d.promise:Then(function()
                onFulfilledCalled = true
                done()
            end)

            assert.equal(onFulfilledCalled, false)
        end)

        specify("when one `onFulfilled` is added inside another `onFulfilled`", function(done)
            local promise = resolved()
            local firstOnFulfilledFinished = false

            promise:Then(function()
                promise:Then(function()
                    assert.equal(firstOnFulfilledFinished, true)
                    done()
                end)
                firstOnFulfilledFinished = true
            end)
        end)

        specify("when `onFulfilled` is added inside an `onRejected`", function(done)
            local promise = rejected()
            local promise2 = resolved()
            local firstOnRejectedFinished = false

            promise:Then(nil, function()
                promise2:Then(function()
                    assert.equal(firstOnRejectedFinished, true)
                    done()
                end)
                firstOnRejectedFinished = true
            end)
        end)

        specify("when the promise is fulfilled asynchronously", function(done)
            local d = deferred()
            local firstStackFinished = false

            setTimeout(function()
                d.resolve(dummy)
                firstStackFinished = true
            end, 0)

            d.promise:Then(function()
                assert.equal(firstStackFinished, true)
                done()
            end)
        end)
    end)

    describe("Clean-stack execution ordering tests (rejection case)", function()
        specify("when `onRejected` is added immediately before the promise is rejected", function(done)
            local d = deferred()
            local onRejectedCalled = false

            d.promise:Then(nil, function()
                onRejectedCalled = true
                done()
            end)

            d.reject(dummy)

            assert.equal(onRejectedCalled, false)
        end)

        specify("when `onRejected` is added immediately after the promise is rejected", function(done)
            local d = deferred()
            local onRejectedCalled = false

            d.reject(dummy)

            d.promise:Then(nil, function()
                onRejectedCalled = true
                done()
            end)

            assert.equal(onRejectedCalled, false)
        end)

        specify("when `onRejected` is added inside an `onFulfilled`", function(done)
            local promise = resolved()
            local promise2 = rejected()
            local firstOnFulfilledFinished = false

            promise:Then(function()
                promise2:Then(nil, function()
                    assert.equal(firstOnFulfilledFinished, true)
                    done()
                end)
                firstOnFulfilledFinished = true
            end)
        end)

        specify("when one `onRejected` is added inside another `onRejected`", function(done)
            local promise = rejected()
            local firstOnRejectedFinished = false

            promise:Then(nil, function()
                promise:Then(nil, function()
                    assert.equal(firstOnRejectedFinished, true)
                    done()
                end)
                firstOnRejectedFinished = true
            end)
        end)

        specify("when the promise is rejected asynchronously", function(done)
            local d = deferred()
            local firstStackFinished = false

            setTimeout(function()
                d.reject(dummy)
                firstStackFinished = true
            end, 0)

            d.promise:Then(nil, function()
                assert.equal(firstStackFinished, true)
                done()
            end)
        end)
    end)
end)
