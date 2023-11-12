if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

local PlayerHandler = require("TOC/Handlers/PlayerHandler")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")


TestFramework.registerTestModule("Functionality", "PlayerHandler", function()
    local Tests = {}
    function Tests.InitializePlayer()
        local pl = getPlayer()
        PlayerHandler.InitializePlayer(pl, true)
    end

    function Tests.SetMaxPerks()
        local pl = getPlayer()
        for _=0, 10 do
            pl:LevelPerk(Perks["Side_L"])
            pl:LevelPerk(Perks["Side_R"])
            pl:getXp():setXPToLevel(Perks["Side_L"], pl:getPerkLevel(Perks["Side_L"]))
            pl:getXp():setXPToLevel(Perks["Side_R"], pl:getPerkLevel(Perks["Side_R"]))
        end

        SyncXp(pl)
    end

    function Tests.ResetPerks()
        local pl = getPlayer()
        for _=0, 10 do
            pl:LoseLevel(Perks["Side_L"])
            pl:LoseLevel(Perks["Side_R"])
            pl:getXp():setXPToLevel(Perks["Side_L"], pl:getPerkLevel(Perks["Side_L"]))
            pl:getXp():setXPToLevel(Perks["Side_R"], pl:getPerkLevel(Perks["Side_R"]))
        end
        SyncXp(pl)
    end

    return Tests
end)


TestFramework.registerTestModule("Functionality", "Amputation", function()
    local Tests = {}

    function Tests.CutLeftHand()
        local handler = AmputationHandler:new("Hand_L")
        handler:execute()
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("Hand_L"))
    end

    function Tests.CutLeftForearm()
        local handler = AmputationHandler:new("ForeArm_L")
        handler:execute()
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("ForeArm_L") and ModDataHandler.GetInstance():getIsCut("Hand_L"))
    end

    function Tests.CutLeftUpperarm()
        local handler = AmputationHandler:new("UpperArm_L")
        handler:execute()
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("UpperArm_L") and ModDataHandler.GetInstance():getIsCut("ForeArm_L") and ModDataHandler.GetInstance():getIsCut("Hand_L"))
    end

    function Tests.CutRightHand()
        local handler = AmputationHandler:new("Hand_R")
        handler:execute()
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("Hand_R"))
    end

    function Tests.CutRightForearm()
        local handler = AmputationHandler:new("ForeArm_R")
        handler:execute()
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("ForeArm_R") and ModDataHandler.GetInstance():getIsCut("Hand_R"))
    end

    function Tests.CutRightUpperarm()
        local handler = AmputationHandler:new("UpperArm_R")
        handler:execute()
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("UpperArm_R") and ModDataHandler.GetInstance():getIsCut("ForeArm_R") and ModDataHandler.GetInstance():getIsCut("Hand_R"))
    end

    return Tests

end)