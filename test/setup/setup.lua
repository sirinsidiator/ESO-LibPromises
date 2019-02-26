package.path = package.path .. ';../src/?.lua'
require 'setup/mockups'
require 'LibPromises'

require 'setup/adapter'
require 'helpers/testThreeCases'

function specify(desc, test)
    it(desc, function(done)
        async()
        test(done)
        resolveTimeouts()
    end)
end