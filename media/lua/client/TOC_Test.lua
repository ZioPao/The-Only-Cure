-- TODO TestFramework stuff here

if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

TestFramework.registerTestModule("Functionality", "Cut Left Hand", function()
    local Tests = {}

    function Tests.CutLeftHand()

    end

end)