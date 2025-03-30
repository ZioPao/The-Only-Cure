if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local DataController = require("TOC/Controllers/DataController")
local StaticData = require("TOC/StaticData")


TestFramework.registerTestModule("LocalPlayerController", "Setup", function()
    local Tests = {}
    function Tests.InitializePlayer()
        LocalPlayerController.InitializePlayer(true)
    end
    return Tests
end)

TestFramework.registerTestModule("LocalPlayerController", "Perks", function()
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

TestFramework.registerTestModule("LocalPlayerController", "Cicatrization", function()
    local Tests = {}

    function Tests.SetCicatrizationTimeToOne()
        for i=1, #StaticData.LIMBS_STR do
            local limbName = StaticData.LIMBS_STR[i]
            DataController.GetInstance():setCicatrizationTime(limbName, 1)
            TestUtils.assert(DataController.GetInstance():getCicatrizationTime(limbName) == 1)
        end
        DataController.GetInstance():apply()
        TestUtils.assert(DataController.GetInstance():getIsCut("Hand_L"))
    end

    return Tests
end)


TestFramework.registerTestModule("AmputationHandler", "Top Left", function()
    local Tests = {}

    function Tests.CutLeftHand()
        local handler = AmputationHandler:new("Hand_L")
        handler:execute(true)
        TestUtils.assert(DataController.GetInstance():getIsCut("Hand_L"))
    end

    function Tests.CutLeftForearm()
        local handler = AmputationHandler:new("ForeArm_L")
        handler:execute(true)
        TestUtils.assert(DataController.GetInstance():getIsCut("ForeArm_L") and DataController.GetInstance():getIsCut("Hand_L"))
    end

    function Tests.CutLeftUpperarm()
        local handler = AmputationHandler:new("UpperArm_L")
        handler:execute(true)
        TestUtils.assert(DataController.GetInstance():getIsCut("UpperArm_L") and DataController.GetInstance():getIsCut("ForeArm_L") and DataController.GetInstance():getIsCut("Hand_L"))
    end

    return Tests
end)

TestFramework.registerTestModule("AmputationHandler", "Top Right", function()
    local Tests = {}

    function Tests.CutRightHand()
        local handler = AmputationHandler:new("Hand_R")
        handler:execute(true)
        TestUtils.assert(DataController.GetInstance():getIsCut("Hand_R"))
    end

    function Tests.CutRightForearm()
        local handler = AmputationHandler:new("ForeArm_R")
        handler:execute(true)
        TestUtils.assert(DataController.GetInstance():getIsCut("ForeArm_R") and DataController.GetInstance():getIsCut("Hand_R"))
    end

    function Tests.CutRightUpperarm()
        local handler = AmputationHandler:new("UpperArm_R")
        handler:execute(true)
        TestUtils.assert(DataController.GetInstance():getIsCut("UpperArm_R") and DataController.GetInstance():getIsCut("ForeArm_R") and DataController.GetInstance():getIsCut("Hand_R"))
    end

    return Tests
end)

TestFramework.registerTestModule("TimedActions", "CauterizeAction", function()
    local Tests = {}
    local CauterizeAction = require("TOC/TimedActions/CauterizeAction")

    function Tests.CauterizeLeftHand()
        ISTimedActionQueue.add(CauterizeAction:new(getPlayer(), "Hand_L", getPlayer()))
    end

    function Tests.CauterizeLefForeArm()
        ISTimedActionQueue.add(CauterizeAction:new(getPlayer(), "ForeArm_L", getPlayer()))
    end

    function Tests.CauterizeLeftUpperArm()
        ISTimedActionQueue.add(CauterizeAction:new(getPlayer(), "UpperArm_L", getPlayer()))
    end

    function Tests.CauterizeRightHand()
        ISTimedActionQueue.add(CauterizeAction:new(getPlayer(), "Hand_R", getPlayer()))
    end

    function Tests.CauterizeRightForeArm()
        ISTimedActionQueue.add(CauterizeAction:new(getPlayer(), "ForeArm_R", getPlayer()))
    end

    function Tests.CauterizeRightUpperArm()
        ISTimedActionQueue.add(CauterizeAction:new(getPlayer(), "UpperArm_R", getPlayer()))
    end

    return Tests

end)

TestFramework.registerTestModule("Various", "Player", function()
    local Tests = {}


    function Tests.BleedTest()
        local pl = getPlayer()

        --pl:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setBleeding(true)
        pl:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setBleedingTime(20)
    end

    function Tests.Kill()
        getPlayer():Kill(getPlayer())
    end

    return Tests
end)


TestFramework.registerTestModule("Various", "Visuals", function()
    local Tests = {}

    function Tests.AddBloodLeftForearm()
        local playerObj = getPlayer()
        local limbName = "ForeArm_L"
        local fullType = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName


        local item = playerObj:getInventory():FindAndReturn(fullType)
        if instanceof(item, "Clothing") then

            ---@cast item Clothing

            print("Found limb to add blood onto")
            item:setBloodLevel(100)
            local coveredParts = BloodClothingType.getCoveredParts(item:getBloodClothingType())
            if coveredParts then
                for j=0,coveredParts:size()-1 do
                    item:setBlood(coveredParts:get(j), 100)
                    item:setDirt(coveredParts:get(j), 100)
                end
            end

        end

        playerObj:resetModelNextFrame()
    end

    return Tests
end)


--------------------------------------------------------------------------------------
if not getActivatedMods():contains("PerfTestFramework") or not isDebugEnabled() then return end
local PerfTest = require("PerfTest/main")       -- SHould be global anyway
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")

PerfTest.RegisterMethod("LocalPlayerController", LocalPlayerController, "InitializePlayer")
PerfTest.RegisterMethod("LocalPlayerController", LocalPlayerController, "UpdateAmputations")
PerfTest.RegisterMethod("CachedDataHandler", CachedDataHandler, "CalculateHighestAmputatedLimbs")
PerfTest.RegisterMethod("ISHealthPanel", ISHealthPanel, "render")

PerfTest.Init()