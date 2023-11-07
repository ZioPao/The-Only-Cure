if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

local PlayerHandler = require("TOC_PlayerHandler")



TestFramework.registerTestModule("Functionality", "Amputation", function()
    local Tests = {}

    function Tests.InitializePlayer()
        -- TODO This breaks the Test Framework mod for some reason.
        local pl = getPlayer()
        PlayerHandler.InitializePlayer(_, pl, true)
        return true
    end

    function Tests.CutLeftHand()
        PlayerHandler.ForceCutLimb("Hand_L")
        return PlayerHandler.modDataHandler:getIsCut("Hand_L")
    end

    function Tests.CutLeftForearm()
        PlayerHandler.ForceCutLimb("ForeArm_L")
        return PlayerHandler.modDataHandler:getIsCut("ForeArm_L") and PlayerHandler.modDataHandler:getIsCut("Hand_L")
    end

    function Tests.CutLeftUpperarm()
        PlayerHandler.ForceCutLimb("UpperArm_L")
        return PlayerHandler.modDataHandler:getIsCut("UpperArm_L") and PlayerHandler.modDataHandler:getIsCut("ForeArm_L") and PlayerHandler.modDataHandler:getIsCut("Hand_L")
    end

    function Tests.CutRightHand()
        PlayerHandler.ForceCutLimb("Hand_R")
        return PlayerHandler.modDataHandler:getIsCut("Hand_R")
    end

    function Tests.CutRightForearm()
        PlayerHandler.ForceCutLimb("ForeArm_R")
        return PlayerHandler.modDataHandler:getIsCut("ForeArm_R") and PlayerHandler.modDataHandler:getIsCut("Hand_R")
    end

    function Tests.CutRightUpperarm()
        PlayerHandler.ForceCutLimb("UpperArm_R")
        return PlayerHandler.modDataHandler:getIsCut("UpperArm_R") and PlayerHandler.modDataHandler:getIsCut("ForeArm_R") and PlayerHandler.modDataHandler:getIsCut("Hand_R")
    end

    return Tests

end)