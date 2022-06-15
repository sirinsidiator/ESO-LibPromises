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
                done()
            end)
            LibPromises:SetUnhandledRejectionHandler(handler)

            rejected(dummy)
            assert.spy(handler).was.called()
        end)

        specify("on error in a rejected promise with no follow up handlers", function(done)
            local handler
            handler = spy.new(function(p)
                assert.equal("test", string.sub(p.value, -4))
                assert.spy(handler).was.called()
                done()
            end)
            LibPromises:SetUnhandledRejectionHandler(handler)

            local promise = LibPromises:New()
            promise:Then(nil, function(e)
                error("test")
            end)
            promise:Reject(dummy)
        end)

        specify("on error in a rejected promise unless there is a follow up handler", function(done)
            local handler = spy.new(function(p) end)
            LibPromises:SetUnhandledRejectionHandler(handler)

            local promise = LibPromises:New()
            promise:Then(nil, function(e)
                error("test")
            end):Then(nil, function(e)
                assert.equal("test", string.sub(e, -4))
                assert.spy(handler).was_not.called()
                done()
            end)
            promise:Reject(dummy)
        end)
    end)
end)
