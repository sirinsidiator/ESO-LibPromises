require 'setup/setup'
local Promise = LibPromises

local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

describe("Custom: A promise for ESO", function()
    specify("should survive metatable pollution", function(done)
        local DummyClass = ZO_InitializingObject:Subclass()
        getmetatable(DummyClass).__call = function() end

        local Base = ZO_InitializingObject:Subclass()
        local Other = Base:Subclass()
        function Other:New(...)
            return Base.New(self, ...)
        end
        function Other:A()
            return self:B():Then(self.C)
        end
        function Other:B()
            local promise = LibPromises:New()
            setTimeout(function()
                promise:Resolve(self)
            end, 0)
            return promise
        end
        function Other:C()
            local promise = LibPromises:New()
            promise:Resolve(self)
            return promise
        end

        local obj = Other:New()
        obj:A():Then(function() 
            ZO_InitializingObject.__call = nil
            done()
        end)
    end)

    describe("has to report unhandled promise rejections", function()
        specify("when it is rejected", function(done)
            local handler = spy.new(function(p)
                assert.equal(dummy, p.value)
            end)
            LibPromises:SetUnhandledRejectionHandler(handler)

            rejected(dummy)
            assert.spy(handler).was_not.called()

            setTimeout(function()
                assert.spy(handler).was.called(1)
                LibPromises:SetUnhandledRejectionHandler(nil)
                done()
            end, 10)
        end)

        specify("on error in a rejected promise with no follow up handlers", function(done)
            local handler, value
            handler = spy.new(function(p)
                value = p.value
            end)
            LibPromises:SetUnhandledRejectionHandler(handler)

            local promise = LibPromises:New()
            promise:Then(nil, function(e)
                error("test")
            end)
            promise:Reject(dummy)

            setTimeout(function()
                assert.spy(handler).was.called(1)
                assert.equal("string", type(value))
                assert.equal("test", string.sub(value, -4))
                LibPromises:SetUnhandledRejectionHandler(nil)
                done()
            end, 10)
        end)

        specify("on error in a rejected promise unless there is a follow up handler", function(done)
            local handler = spy.new(function(p) end)
            LibPromises:SetUnhandledRejectionHandler(handler)

            local value
            local promise = LibPromises:New()
            promise:Then(nil, function(e)
                error("test")
            end):Then(nil, function(e)
                value = e
            end)
            promise:Reject(dummy)

            setTimeout(function()
                assert.spy(handler).was_not.called()
                assert.equal("string", type(value))
                assert.equal("test", string.sub(value, -4))
                LibPromises:SetUnhandledRejectionHandler(nil)
                done()
            end, 10)
        end)
    end)
end)
