package.path = package.path .. ';../src/?.lua'
require 'setup/mockups'
require 'LibPromises'

require 'setup/adapter'
require 'helpers/testThreeCases'

function specify(desc, test)
    it(desc, function(done)
        async()
        local handler = spy.new(function(p) end)
        LibPromises:SetUnhandledRejectionHandler(nil)
        test(done)
        resolveTimeouts()
        assert.spy(handler).was_not.called()
        LibPromises:SetUnhandledRejectionHandler(nil)
    end)
end