-- TODO TestFramework stuff here

if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

local PlayerHandler = require("TOC_PlayerHandler")

TestFramework.registerTestModule("Functionality", "Setup", function()

    local Tests = {}
    function Tests.InitializePlayer()
        local pl = getPlayer()
        PlayerHandler.InitializePlayer(nil, pl)
        return true
    end

    return Tests
end)

TestFramework.registerTestModule("Functionality", "Amputation", function()
    local Tests = {}

    function Tests.CutLeftHand()
        PlayerHandler.ForceCutLimb("Hand_L")
        return PlayerHandler.modDataHandler:getIsCut("Hand_L")
    end

    function Tests.CutLeftForearm()
        PlayerHandler.ForceCutLimb("ForeArm_L")
        return PlayerHandler.modDataHandler:getIsCut("ForeArm_L") and PlayerHandler.modDataHandler:getIsCut("Hand_L")
    end

    return Tests

end)