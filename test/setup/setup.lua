package.path = package.path .. ';../src/LibPromises/?.lua'
package.path = package.path .. ';../src/LibStub/?.lua'
require 'setup/mockups'
require 'LibStub'
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