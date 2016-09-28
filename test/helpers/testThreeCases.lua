function testFulfilled(value, test)
    specify("already-fulfilled", function(done)
        test(resolved(value), done)
    end)

    specify("immediately-fulfilled", function(done)
        local d = deferred()
        test(d.promise, done)
        d.resolve(value)
    end)

    specify("eventually-fulfilled", function(done)
        local d = deferred()
        test(d.promise, done)
        setTimeout(function()
            d.resolve(value)
        end, 50)
    end)
end

function testRejected(reason, test)
    specify("already-rejected", function(done)
        test(rejected(reason), done)
    end)

    specify("immediately-rejected", function(done)
        local d = deferred()
        test(d.promise, done)
        d.reject(reason)
    end)

    specify("eventually-rejected", function(done)
        local d = deferred()
        test(d.promise, done)
        setTimeout(function ()
            d.reject(reason)
        end, 50)
    end)
end
