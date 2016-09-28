require 'setup/mockups'
require 'LibStub/LibStub'
require 'LibPromises/LibPromises'

require 'setup/adapter'
require 'helpers/testThreeCases'

function specify(desc, test)
    it(desc, function(done)
        async()
        test(done)
        resolveTimeouts()
    end)
end