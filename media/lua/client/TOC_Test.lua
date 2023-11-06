-- TODO TestFramework stuff here

if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

TestFramework.registerTestModule("Functionality", "Cut Left Hand", function()
    local Tests = {}
    local PlayerHandler = require("TOC_PlayerHandler")

    function Tests.CutLeftHand()
        local pl = getPlayer()
        PlayerHandler.InitializePlayer(nil, pl)
        PlayerHandler.ForceCutLimb("Hand_L")
    end

    return Tests

end)