if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

local PlayerHandler = require("Handlers/TOC_PlayerHandler")
local AmputationHandler = require("Handlers/TOC_AmputationHandler")


TestFramework.registerTestModule("Functionality", "PlayerHandler", function()
    local Tests = {}
    function Tests.InitializePlayer()
        local pl = getPlayer()
        PlayerHandler.InitializePlayer(_, pl, true)
    end

    return Tests
end)


TestFramework.registerTestModule("Functionality", "Amputation", function()
    local Tests = {}

    function Tests.CutLeftHand()
        local handler = AmputationHandler:new("Hand_L")
        handler:execute()
        TestUtils.assert(PlayerHandler.modDataHandler:getIsCut("Hand_L"))
    end

    function Tests.CutLeftForearm()
        local handler = AmputationHandler:new("ForeArm_L")
        handler:execute()
        TestUtils.assert(PlayerHandler.modDataHandler:getIsCut("ForeArm_L") and PlayerHandler.modDataHandler:getIsCut("Hand_L"))
    end

    function Tests.CutLeftUpperarm()
        local handler = AmputationHandler:new("UpperArm_L")
        handler:execute()
        TestUtils.assert(PlayerHandler.modDataHandler:getIsCut("UpperArm_L") and PlayerHandler.modDataHandler:getIsCut("ForeArm_L") and PlayerHandler.modDataHandler:getIsCut("Hand_L"))
    end

    function Tests.CutRightHand()
        local handler = AmputationHandler:new("Hand_R")
        handler:execute()
        TestUtils.assert(PlayerHandler.modDataHandler:getIsCut("Hand_R"))
    end

    function Tests.CutRightForearm()
        local handler = AmputationHandler:new("ForeArm_R")
        handler:execute()
        TestUtils.assert(PlayerHandler.modDataHandler:getIsCut("ForeArm_R") and PlayerHandler.modDataHandler:getIsCut("Hand_R"))
    end

    function Tests.CutRightUpperarm()
        local handler = AmputationHandler:new("UpperArm_R")
        handler:execute()
        TestUtils.assert(PlayerHandler.modDataHandler:getIsCut("UpperArm_R") and PlayerHandler.modDataHandler:getIsCut("ForeArm_R") and PlayerHandler.modDataHandler:getIsCut("Hand_R"))
    end

    return Tests

end)