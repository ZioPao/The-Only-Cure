if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

local PlayerHandler = require("TOC/Handlers/PlayerHandler")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local StaticData = require("TOC/StaticData")


TestFramework.registerTestModule("PlayerHandler", "Setup", function()
    local Tests = {}
    function Tests.InitializePlayer()
        local pl = getPlayer()
        PlayerHandler.InitializePlayer(pl, true)
    end
    return Tests
end)

TestFramework.registerTestModule("PlayerHandler", "Perks", function()
    local Tests = {}

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

TestFramework.registerTestModule("PlayerHandler", "Cicatrization", function()
    local Tests = {}

    function Tests.SetCicatrizationTimeToOne()
        for i=1, #StaticData.LIMBS_STR do
            local limbName = StaticData.LIMBS_STR[i]
            ModDataHandler.GetInstance():setCicatrizationTime(limbName, 1)
            TestUtils.assert(ModDataHandler.GetInstance():getCicatrizationTime(limbName) == 1)
        end
        ModDataHandler.GetInstance():apply()
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("Hand_L"))
    end

    return Tests
end)


TestFramework.registerTestModule("AmputationHandler", "Top Left", function()
    local Tests = {}

    function Tests.CutLeftHand()
        local handler = AmputationHandler:new("Hand_L")
        handler:execute(true)
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("Hand_L"))
    end

    function Tests.CutLeftForearm()
        local handler = AmputationHandler:new("ForeArm_L")
        handler:execute(true)
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("ForeArm_L") and ModDataHandler.GetInstance():getIsCut("Hand_L"))
    end

    function Tests.CutLeftUpperarm()
        local handler = AmputationHandler:new("UpperArm_L")
        handler:execute(true)
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("UpperArm_L") and ModDataHandler.GetInstance():getIsCut("ForeArm_L") and ModDataHandler.GetInstance():getIsCut("Hand_L"))
    end

    return Tests
end)

TestFramework.registerTestModule("AmputationHandler", "Top Right", function()
    local Tests = {}

    function Tests.CutRightHand()
        local handler = AmputationHandler:new("Hand_R")
        handler:execute(true)
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("Hand_R"))
    end
    
    function Tests.CutRightForearm()
        local handler = AmputationHandler:new("ForeArm_R")
        handler:execute(true)
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("ForeArm_R") and ModDataHandler.GetInstance():getIsCut("Hand_R"))
    end
    
    function Tests.CutRightUpperarm()
        local handler = AmputationHandler:new("UpperArm_R")
        handler:execute(true)
        TestUtils.assert(ModDataHandler.GetInstance():getIsCut("UpperArm_R") and ModDataHandler.GetInstance():getIsCut("ForeArm_R") and ModDataHandler.GetInstance():getIsCut("Hand_R"))
    end

    return Tests
end)


--------------------------------------------------------------------------------------

if not getActivatedMods():contains("PerfTestFramework") or not isDebugEnabled() then return end
local PerfTest = require("PerfTest/main")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")

PerfTest.Init()
PerfTest.RegisterMethod("PlayerHandler", PlayerHandler, "UpdateCicatrization")
PerfTest.RegisterMethod("CachedDataHandler", CachedDataHandler, "CalculateHighestAmputatedLimbs")
PerfTest.RegisterMethod("ISHealthPanel", ISHealthPanel, "render")