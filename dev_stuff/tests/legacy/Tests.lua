if not getActivatedMods():contains("\\TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local AsyncTest = require("TestFramework/AsyncTest")

local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
local CommandsData = require("TOC/CommandsData")

-- ============================================================
--  Shared helpers
-- ============================================================

local function getUsername()
    return getPlayer():getUsername()
end

--- Returns the existing DataController instance for the local player.
local function getDC()
    return DataController.GetInstance(getUsername())
end

--- SP: synchronous — ClientDataController.Request calls ServerDataController.Initialize directly.
--- MP: async — sends relay command; caller must wait for DC ready before using the instance.
local function requestReset()
    local ClientDataController = require("TOC/Controllers/ClientDataController")
    ClientDataController.Request(getUsername(), true)
    CachedDataHandler.Setup(getUsername())
end

--- MP helper: returns an AsyncTest that resets state and waits for DC to be ready.
local function asyncResetAndWait()
    return AsyncTest:new()
        :next(function()
            requestReset()
        end)
        :repeatUntil(function()
            local dc = DataController.GetInstance(getUsername())
            return dc ~= nil and dc:getIsDataReady()
        end, 5000)
end

--- MP helper: sends RelayExecuteAmputationAction and waits for the DC to reflect the cut.
local function asyncAmpMP(limbName)
    local pl = getPlayer()
    return asyncResetAndWait()
        :next(function()
            sendClientCommand(CommandsData.modules.TOC_RELAY,
                CommandsData.server.Relay.RelayExecuteAmputationAction,
                {patientNum = pl:getOnlineID(), limbName = limbName})
        end)
        :repeatUntil(function()
            return getDC():getIsCut(limbName) == true
        end, 10000)
end


-- ============================================================
--  CommonMethods — pure utility functions (SP + MP)
-- ============================================================

TestFramework.registerTestModule("TOC", "CommonMethods", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    TestFramework.addCodeCoverage(Tests, CommonMethods, "CommonMethods")

    function Tests.GetSide_Left()
        TestUtils.assert(CommonMethods.GetSide("Hand_L") == "L")
        TestUtils.assert(CommonMethods.GetSide("ForeArm_L") == "L")
        TestUtils.assert(CommonMethods.GetSide("UpperArm_L") == "L")
    end

    function Tests.GetSide_Right()
        TestUtils.assert(CommonMethods.GetSide("Hand_R") == "R")
        TestUtils.assert(CommonMethods.GetSide("ForeArm_R") == "R")
        TestUtils.assert(CommonMethods.GetSide("UpperArm_R") == "R")
    end

    function Tests.GetSideFull_Valid()
        TestUtils.assert(CommonMethods.GetSideFull("L") == "Left")
        TestUtils.assert(CommonMethods.GetSideFull("R") == "Right")
    end

    function Tests.GetSideFull_Invalid()
        TestUtils.assertNil(CommonMethods.GetSideFull("X"))
    end

    function Tests.Normalize_Standard()
        TestUtils.assert(CommonMethods.Normalize(50, 0, 100) == 0.5)
        TestUtils.assert(CommonMethods.Normalize(0, 0, 100) == 0)
        TestUtils.assert(CommonMethods.Normalize(100, 0, 100) == 1)
    end

    function Tests.Normalize_ZeroRange()
        -- When min == max, must return 1 to avoid division by zero
        TestUtils.assert(CommonMethods.Normalize(5, 5, 5) == 1)
    end

    return Tests
end)


-- ============================================================
--  StaticData — table integrity (SP + MP)
-- ============================================================

TestFramework.registerTestModule("TOC", "StaticData", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.AllSixLimbsPresent()
        TestUtils.assertTable(StaticData.LIMBS_STR)
        TestUtils.assert(#StaticData.LIMBS_STR == 6)
        local expected = { "Hand_L", "Hand_R", "ForeArm_L", "ForeArm_R", "UpperArm_L", "UpperArm_R" }
        for _, name in ipairs(expected) do
            TestUtils.assertString(StaticData.LIMBS_IND_STR[name])
        end
    end

    function Tests.DependenciesChain_Hand_HasNone()
        TestUtils.assert(#StaticData.LIMBS_DEPENDENCIES_IND_STR["Hand_L"] == 0)
        TestUtils.assert(#StaticData.LIMBS_DEPENDENCIES_IND_STR["Hand_R"] == 0)
    end

    function Tests.DependenciesChain_ForeArm_HasHand()
        TestUtils.assert(#StaticData.LIMBS_DEPENDENCIES_IND_STR["ForeArm_L"] == 1)
        TestUtils.assert(StaticData.LIMBS_DEPENDENCIES_IND_STR["ForeArm_L"][1] == "Hand_L")
        TestUtils.assert(StaticData.LIMBS_DEPENDENCIES_IND_STR["ForeArm_R"][1] == "Hand_R")
    end

    function Tests.DependenciesChain_UpperArm_HasTwo()
        TestUtils.assert(#StaticData.LIMBS_DEPENDENCIES_IND_STR["UpperArm_L"] == 2)
        TestUtils.assert(#StaticData.LIMBS_DEPENDENCIES_IND_STR["UpperArm_R"] == 2)
    end

    function Tests.AdjacentMappings()
        TestUtils.assert(StaticData.LIMBS_ADJACENT_IND_STR["Hand_L"] == "ForeArm_L")
        TestUtils.assert(StaticData.LIMBS_ADJACENT_IND_STR["Hand_R"] == "ForeArm_R")
        TestUtils.assert(StaticData.LIMBS_ADJACENT_IND_STR["ForeArm_L"] == "UpperArm_L")
        TestUtils.assert(StaticData.LIMBS_ADJACENT_IND_STR["ForeArm_R"] == "UpperArm_R")
        TestUtils.assert(StaticData.LIMBS_ADJACENT_IND_STR["UpperArm_L"] == "Torso_Upper")
        TestUtils.assert(StaticData.LIMBS_ADJACENT_IND_STR["UpperArm_R"] == "Torso_Upper")
    end

    function Tests.AmpGroupMappings_AllArmsAreTop()
        TestUtils.assert(StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["Hand_L"] == "Top_L")
        TestUtils.assert(StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["ForeArm_L"] == "Top_L")
        TestUtils.assert(StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["UpperArm_L"] == "Top_L")
        TestUtils.assert(StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["Hand_R"] == "Top_R")
        TestUtils.assert(StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["ForeArm_R"] == "Top_R")
    end

    return Tests
end)


-- ============================================================
--  LocalPlayerController — Setup & Perks (SP + MP)
-- ============================================================

TestFramework.registerTestModule("LocalPlayerController", "Setup", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.InitializePlayer()
        LocalPlayerController.InitializePlayer(true)
    end

    return Tests
end)

TestFramework.registerTestModule("LocalPlayerController", "Perks", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.SetMaxPerks()
        local pl = getPlayer()
        for _ = 0, 10 do
            pl:LevelPerk(Perks["Side_L"])
            pl:LevelPerk(Perks["Side_R"])
            pl:getXp():setXPToLevel(Perks["Side_L"], pl:getPerkLevel(Perks["Side_L"]))
            pl:getXp():setXPToLevel(Perks["Side_R"], pl:getPerkLevel(Perks["Side_R"]))
        end
        SyncXp(pl)
        TestUtils.assert(pl:getPerkLevel(Perks["Side_L"]) == 10)
        TestUtils.assert(pl:getPerkLevel(Perks["Side_R"]) == 10)
    end

    function Tests.ResetPerks()
        local pl = getPlayer()
        for _ = 0, 10 do
            pl:LoseLevel(Perks["Side_L"])
            pl:LoseLevel(Perks["Side_R"])
            pl:getXp():setXPToLevel(Perks["Side_L"], pl:getPerkLevel(Perks["Side_L"]))
            pl:getXp():setXPToLevel(Perks["Side_R"], pl:getPerkLevel(Perks["Side_R"]))
        end
        SyncXp(pl)
        TestUtils.assert(pl:getPerkLevel(Perks["Side_L"]) == 0)
        TestUtils.assert(pl:getPerkLevel(Perks["Side_R"]) == 0)
    end

    return Tests
end)


-- ============================================================
--  DataController — getters / setters  [SP only]
--  Direct setters bypass the server relay; only valid when
--  server and client share the same Lua state.
-- ============================================================

if not isClient() then
TestFramework.registerTestModule("DataController", "Setters and Getters", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    TestFramework.addCodeCoverage(Tests, DataController, "DataController")

    function Tests._setup()
        requestReset()
    end

    function Tests.DefaultAllLimbsNotCut()
        local dc = getDC()
        for i = 1, #StaticData.LIMBS_STR do
            local limbName = StaticData.LIMBS_STR[i]
            TestUtils.assertBoolean(dc:getIsCut(limbName))
            TestUtils.assert(dc:getIsCut(limbName) == false)
        end
    end

    function Tests.DefaultFlagsAreFalse()
        local dc = getDC()
        TestUtils.assert(dc:getIsAnyLimbCut() == false)
        TestUtils.assert(dc:getIsIgnoredPartInfected() == false)
        TestUtils.assert(dc:getIsDataReady() == true)
    end

    function Tests.SetGetIsCut()
        local dc = getDC()
        dc:setIsCut("Hand_L", true)
        TestUtils.assert(dc:getIsCut("Hand_L") == true)
        dc:setIsCut("Hand_L", false)
        TestUtils.assert(dc:getIsCut("Hand_L") == false)
    end

    function Tests.SetGetIsCauterized()
        local dc = getDC()
        dc:setIsCauterized("ForeArm_R", true)
        TestUtils.assert(dc:getIsCauterized("ForeArm_R") == true)
        dc:setIsCauterized("ForeArm_R", false)
        TestUtils.assert(dc:getIsCauterized("ForeArm_R") == false)
    end

    function Tests.SetGetIsCicatrized()
        local dc = getDC()
        dc:setIsCicatrized("UpperArm_L", true)
        TestUtils.assert(dc:getIsCicatrized("UpperArm_L") == true)
        dc:setIsCicatrized("UpperArm_L", false)
        TestUtils.assert(dc:getIsCicatrized("UpperArm_L") == false)
    end

    function Tests.SetGetCicatrizationTime()
        local dc = getDC()
        dc:setCicatrizationTime("Hand_R", 77)
        TestUtils.assertNumber(dc:getCicatrizationTime("Hand_R"))
        TestUtils.assert(dc:getCicatrizationTime("Hand_R") == 77)
    end

    function Tests.SetGetWoundDirtyness()
        local dc = getDC()
        dc:setWoundDirtyness("ForeArm_L", 0.5)
        TestUtils.assertNumber(dc:getWoundDirtyness("ForeArm_L"))
        TestUtils.assert(dc:getWoundDirtyness("ForeArm_L") == 0.5)
    end

    function Tests.SetGetIsAnyLimbCut()
        local dc = getDC()
        dc:setIsAnyLimbCut(true)
        TestUtils.assert(dc:getIsAnyLimbCut() == true)
        dc:setIsAnyLimbCut(false)
        TestUtils.assert(dc:getIsAnyLimbCut() == false)
    end

    function Tests.SetGetIsIgnoredPartInfected()
        local dc = getDC()
        dc:setIsIgnoredPartInfected(true)
        TestUtils.assert(dc:getIsIgnoredPartInfected() == true)
        dc:setIsIgnoredPartInfected(false)
        TestUtils.assert(dc:getIsIgnoredPartInfected() == false)
    end

    function Tests.SetGetProstEquipped()
        local dc = getDC()
        dc:setIsProstEquipped("Top_L", true)
        TestUtils.assert(dc:getIsProstEquipped("Hand_L") == true)
        dc:setIsProstEquipped("Top_L", false)
        TestUtils.assert(dc:getIsProstEquipped("Hand_L") == false)
    end

    function Tests.DecreaseCicatrizationTime()
        local dc = getDC()
        dc:setCicatrizationTime("Hand_L", 10)
        dc:decreaseCicatrizationTime("Hand_L")
        TestUtils.assert(dc:getCicatrizationTime("Hand_L") == 9)
    end

    return Tests
end)


TestFramework.registerTestModule("DataController", "setCutLimb cascade", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests._setup()
        requestReset()
    end

    function Tests.Hand_NoDependencies()
        local dc = getDC()
        dc:setCutLimb("Hand_L", false, false, false, 0)
        TestUtils.assert(dc:getIsCut("Hand_L") == true)
        TestUtils.assert(dc:getIsVisible("Hand_L") == true)
        TestUtils.assert(dc:getIsAnyLimbCut() == true)
        TestUtils.assert(dc:getIsCut("Hand_R") == false)
        TestUtils.assert(dc:getIsCut("ForeArm_L") == false)
    end

    function Tests.ForeArm_AlsoCutsHand()
        local dc = getDC()
        dc:setCutLimb("ForeArm_L", false, false, false, 0)
        TestUtils.assert(dc:getIsCut("ForeArm_L") == true)
        TestUtils.assert(dc:getIsCut("Hand_L") == true)
        TestUtils.assert(dc:getIsVisible("ForeArm_L") == true)
        TestUtils.assert(dc:getIsVisible("Hand_L") == false)
    end

    function Tests.UpperArm_CutsAllThree()
        local dc = getDC()
        dc:setCutLimb("UpperArm_L", false, false, false, 0)
        TestUtils.assert(dc:getIsCut("UpperArm_L") == true)
        TestUtils.assert(dc:getIsCut("ForeArm_L") == true)
        TestUtils.assert(dc:getIsCut("Hand_L") == true)
        TestUtils.assert(dc:getIsVisible("UpperArm_L") == true)
        TestUtils.assert(dc:getIsVisible("ForeArm_L") == false)
        TestUtils.assert(dc:getIsVisible("Hand_L") == false)
    end

    function Tests.NoCrossSideContamination()
        local dc = getDC()
        dc:setCutLimb("Hand_L", false, false, false, 0)
        TestUtils.assert(dc:getIsCut("Hand_R") == false)
        TestUtils.assert(dc:getIsCut("ForeArm_R") == false)
        TestUtils.assert(dc:getIsCut("UpperArm_R") == false)
    end

    return Tests
end)
end -- if not isClient()


-- ============================================================
--  CachedDataHandler — cache operations (SP + MP)
--  These tests only manipulate the local cache, not DC state.
-- ============================================================

TestFramework.registerTestModule("CachedDataHandler", "Cache operations", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    TestFramework.addCodeCoverage(Tests, CachedDataHandler, "CachedDataHandler")

    function Tests._setup()
        requestReset()
    end

    function Tests.SetupCreatesEmptyCache()
        local amputated = CachedDataHandler.GetAmputatedLimbs(getUsername())
        TestUtils.assertTable(amputated)
        local count = 0
        for _ in pairs(amputated) do count = count + 1 end
        TestUtils.assert(count == 0)
    end

    function Tests.AddAmputatedLimb()
        local username = getUsername()
        CachedDataHandler.AddAmputatedLimb(username, "Hand_L")
        local amputated = CachedDataHandler.GetAmputatedLimbs(username)
        TestUtils.assertTable(amputated)
        TestUtils.assert(amputated["Hand_L"] == "Hand_L")
    end

    function Tests.GetAll_ReturnsCorrectStructure()
        CachedDataHandler.CalculateCacheableValues(getUsername())
        local all = CachedDataHandler.GetAll(getUsername())
        TestUtils.assertTable(all)
        TestUtils.assertTable(all.amputatedLimbs)
        TestUtils.assertTable(all.highestAmputatedLimbs)
        TestUtils.assertTable(all.handFeasibility)
        TestUtils.assertBoolean(all.handFeasibility["L"])
        TestUtils.assertBoolean(all.handFeasibility["R"])
    end

    return Tests
end)


-- ============================================================
--  CachedDataHandler — feasibility / highest  [SP only]
-- ============================================================

if not isClient() then
TestFramework.registerTestModule("CachedDataHandler", "Hand feasibility", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests._setup()
        requestReset()
    end

    function Tests.BothHandsFeasible_NoAmputations()
        CachedDataHandler.CalculateCacheableValues(getUsername())
        TestUtils.assert(CachedDataHandler.GetHandFeasibility("L", getUsername()) == true)
        TestUtils.assert(CachedDataHandler.GetHandFeasibility("R", getUsername()) == true)
        TestUtils.assert(CachedDataHandler.GetBothHandsFeasibility(getUsername()) == true)
    end

    function Tests.LeftNotFeasible_WhenHandL_Cut()
        getDC():setCutLimb("Hand_L", false, false, false, 0)
        CachedDataHandler.CalculateCacheableValues(getUsername())
        TestUtils.assert(CachedDataHandler.GetHandFeasibility("L", getUsername()) == false)
        TestUtils.assert(CachedDataHandler.GetHandFeasibility("R", getUsername()) == true)
        TestUtils.assert(CachedDataHandler.GetBothHandsFeasibility(getUsername()) == true)
    end

    function Tests.BothNotFeasible_WhenBothHandsCut()
        getDC():setCutLimb("Hand_L", false, false, false, 0)
        getDC():setCutLimb("Hand_R", false, false, false, 0)
        CachedDataHandler.CalculateCacheableValues(getUsername())
        TestUtils.assert(CachedDataHandler.GetHandFeasibility("L", getUsername()) == false)
        TestUtils.assert(CachedDataHandler.GetHandFeasibility("R", getUsername()) == false)
        TestUtils.assert(CachedDataHandler.GetBothHandsFeasibility(getUsername()) == false)
    end

    function Tests.FeasibleAgain_WhenProstEquipped()
        getDC():setCutLimb("Hand_L", false, false, false, 0)
        getDC():setIsProstEquipped("Top_L", true)
        CachedDataHandler.CalculateCacheableValues(getUsername())
        TestUtils.assert(CachedDataHandler.GetHandFeasibility("L", getUsername()) == true)
    end

    return Tests
end)


TestFramework.registerTestModule("CachedDataHandler", "Highest amputated limbs", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests._setup()
        requestReset()
    end

    function Tests.HighestIsHand_WhenOnlyHandCut()
        getDC():setCutLimb("Hand_L", false, false, false, 0)
        CachedDataHandler.CalculateHighestAmputatedLimbs(getUsername())
        local highest = CachedDataHandler.GetHighestAmputatedLimbs(getUsername())
        TestUtils.assertTable(highest)
        TestUtils.assert(highest["L"] == "Hand_L")
        TestUtils.assertNil(highest["R"])
    end

    function Tests.HighestIsForeArm_WhenForeArmCut()
        getDC():setCutLimb("ForeArm_L", false, false, false, 0)
        CachedDataHandler.CalculateHighestAmputatedLimbs(getUsername())
        local highest = CachedDataHandler.GetHighestAmputatedLimbs(getUsername())
        TestUtils.assert(highest["L"] == "ForeArm_L")
    end

    function Tests.NoHighest_WhenNoAmputations()
        CachedDataHandler.CalculateHighestAmputatedLimbs(getUsername())
        local highest = CachedDataHandler.GetHighestAmputatedLimbs(getUsername())
        TestUtils.assertNil(highest["L"])
        TestUtils.assertNil(highest["R"])
    end

    return Tests
end)
end -- if not isClient()


-- ============================================================
--  AmputationHandler — execute()  [SP only]
-- ============================================================

if not isClient() then
TestFramework.registerTestModule("AmputationHandler", "Left side", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    TestFramework.addCodeCoverage(Tests, AmputationHandler, "AmputationHandler")

    function Tests._setup()
        requestReset()
    end

    function Tests.CutLeftHand()
        AmputationHandler:new(getPlayer(), getPlayer(), "Hand_L"):execute(false)
        TestUtils.assert(getDC():getIsCut("Hand_L") == true)
        TestUtils.assert(getDC():getIsAnyLimbCut() == true)
    end

    function Tests.CutLeftForeArm_CascadesToHand()
        AmputationHandler:new(getPlayer(), getPlayer(), "ForeArm_L"):execute(false)
        TestUtils.assert(getDC():getIsCut("ForeArm_L") == true)
        TestUtils.assert(getDC():getIsCut("Hand_L") == true)
        TestUtils.assert(getDC():getIsVisible("ForeArm_L") == true)
        TestUtils.assert(getDC():getIsVisible("Hand_L") == false)
    end

    function Tests.CutLeftUpperArm_CascadesToAll()
        AmputationHandler:new(getPlayer(), getPlayer(), "UpperArm_L"):execute(false)
        TestUtils.assert(getDC():getIsCut("UpperArm_L") == true)
        TestUtils.assert(getDC():getIsCut("ForeArm_L") == true)
        TestUtils.assert(getDC():getIsCut("Hand_L") == true)
    end

    return Tests
end)

TestFramework.registerTestModule("AmputationHandler", "Right side", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests._setup()
        requestReset()
    end

    function Tests.CutRightHand()
        AmputationHandler:new(getPlayer(), getPlayer(), "Hand_R"):execute(false)
        TestUtils.assert(getDC():getIsCut("Hand_R") == true)
    end

    function Tests.CutRightForeArm_CascadesToHand()
        AmputationHandler:new(getPlayer(), getPlayer(), "ForeArm_R"):execute(false)
        TestUtils.assert(getDC():getIsCut("ForeArm_R") == true)
        TestUtils.assert(getDC():getIsCut("Hand_R") == true)
    end

    function Tests.CutRightUpperArm_CascadesToAll()
        AmputationHandler:new(getPlayer(), getPlayer(), "UpperArm_R"):execute(false)
        TestUtils.assert(getDC():getIsCut("UpperArm_R") == true)
        TestUtils.assert(getDC():getIsCut("ForeArm_R") == true)
        TestUtils.assert(getDC():getIsCut("Hand_R") == true)
    end

    return Tests
end)

TestFramework.registerTestModule("AmputationHandler", "Cross-side isolation", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests._setup()
        requestReset()
    end

    function Tests.LeftCutDoesNotAffectRight()
        AmputationHandler:new(getPlayer(), getPlayer(), "Hand_L"):execute(false)
        TestUtils.assert(getDC():getIsCut("Hand_R") == false)
        TestUtils.assert(getDC():getIsCut("ForeArm_R") == false)
        TestUtils.assert(getDC():getIsCut("UpperArm_R") == false)
    end

    function Tests.RightCutDoesNotAffectLeft()
        AmputationHandler:new(getPlayer(), getPlayer(), "Hand_R"):execute(false)
        TestUtils.assert(getDC():getIsCut("Hand_L") == false)
        TestUtils.assert(getDC():getIsCut("ForeArm_L") == false)
        TestUtils.assert(getDC():getIsCut("UpperArm_L") == false)
    end

    function Tests.CacheIsUpdatedAfterExecute()
        AmputationHandler:new(getPlayer(), getPlayer(), "Hand_L"):execute(false)
        local amputated = CachedDataHandler.GetAmputatedLimbs(getUsername())
        TestUtils.assertTable(amputated)
        TestUtils.assert(amputated["Hand_L"] ~= nil)
    end

    return Tests
end)
end -- if not isClient()


-- ============================================================
--  AmputationHandler (MP) — via server relay  [MP only]
--  Uses sendClientCommand → RelayExecuteAmputationAction then
--  waits for the DC update to arrive back on the client.
-- ============================================================

if isClient() then
TestFramework.registerTestModule("AmputationHandler (MP)", "Left side", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.CutLeftHand()
        return asyncAmpMP("Hand_L")
            :next(function()
                TestUtils.assert(getDC():getIsCut("Hand_L") == true)
                TestUtils.assert(getDC():getIsAnyLimbCut() == true)
            end)
            :finally(function() requestReset() end)
    end

    function Tests.CutLeftForeArm_CascadesToHand()
        return asyncAmpMP("ForeArm_L")
            :next(function()
                TestUtils.assert(getDC():getIsCut("ForeArm_L") == true)
                TestUtils.assert(getDC():getIsCut("Hand_L") == true)
                TestUtils.assert(getDC():getIsVisible("ForeArm_L") == true)
                TestUtils.assert(getDC():getIsVisible("Hand_L") == false)
            end)
            :finally(function() requestReset() end)
    end

    function Tests.CutLeftUpperArm_CascadesToAll()
        return asyncAmpMP("UpperArm_L")
            :next(function()
                TestUtils.assert(getDC():getIsCut("UpperArm_L") == true)
                TestUtils.assert(getDC():getIsCut("ForeArm_L") == true)
                TestUtils.assert(getDC():getIsCut("Hand_L") == true)
            end)
            :finally(function() requestReset() end)
    end

    return Tests
end)

TestFramework.registerTestModule("AmputationHandler (MP)", "Right side", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.CutRightHand()
        return asyncAmpMP("Hand_R")
            :next(function()
                TestUtils.assert(getDC():getIsCut("Hand_R") == true)
            end)
            :finally(function() requestReset() end)
    end

    function Tests.CutRightForeArm_CascadesToHand()
        return asyncAmpMP("ForeArm_R")
            :next(function()
                TestUtils.assert(getDC():getIsCut("ForeArm_R") == true)
                TestUtils.assert(getDC():getIsCut("Hand_R") == true)
            end)
            :finally(function() requestReset() end)
    end

    function Tests.CutRightUpperArm_CascadesToAll()
        return asyncAmpMP("UpperArm_R")
            :next(function()
                TestUtils.assert(getDC():getIsCut("UpperArm_R") == true)
                TestUtils.assert(getDC():getIsCut("ForeArm_R") == true)
                TestUtils.assert(getDC():getIsCut("Hand_R") == true)
            end)
            :finally(function() requestReset() end)
    end

    return Tests
end)

TestFramework.registerTestModule("AmputationHandler (MP)", "Cross-side isolation", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.LeftCutDoesNotAffectRight()
        return asyncAmpMP("Hand_L")
            :next(function()
                TestUtils.assert(getDC():getIsCut("Hand_R") == false)
                TestUtils.assert(getDC():getIsCut("ForeArm_R") == false)
                TestUtils.assert(getDC():getIsCut("UpperArm_R") == false)
            end)
            :finally(function() requestReset() end)
    end

    function Tests.RightCutDoesNotAffectLeft()
        return asyncAmpMP("Hand_R")
            :next(function()
                TestUtils.assert(getDC():getIsCut("Hand_L") == false)
                TestUtils.assert(getDC():getIsCut("ForeArm_L") == false)
                TestUtils.assert(getDC():getIsCut("UpperArm_L") == false)
            end)
            :finally(function() requestReset() end)
    end

    function Tests.CacheIsUpdatedAfterRelay()
        return asyncAmpMP("Hand_L")
            :next(function()
                local amputated = CachedDataHandler.GetAmputatedLimbs(getUsername())
                TestUtils.assertTable(amputated)
                TestUtils.assert(amputated["Hand_L"] ~= nil)
            end)
            :finally(function() requestReset() end)
    end

    return Tests
end)
end -- if isClient()


-- ============================================================
--  TourniquetController — worn-item detection (SP + MP)
-- ============================================================

TestFramework.registerTestModule("TourniquetController", "Item detection", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")
    local TourniquetController = require("TOC/Controllers/TourniquetController")

    TestFramework.addCodeCoverage(Tests, TourniquetController, "TourniquetController")

    local function mockPlayerWithTourniquet(fullType)
        local wornItem = { getItem = function() return { getFullType = function() return fullType end } end }
        return {
            getWornItems = function()
                return {
                    size = function() return 1 end,
                    get  = function(_, _i) return wornItem end,
                }
            end
        }
    end

    local function mockPlayerNoItems()
        return {
            getWornItems = function()
                return { size = function() return 0 end }
            end
        }
    end

    function Tests.IsItemTourniquet_Left_True()
        TestUtils.assert(TourniquetController.IsItemTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_L") == true)
    end

    function Tests.IsItemTourniquet_Right_True()
        TestUtils.assert(TourniquetController.IsItemTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_R") == true)
    end

    function Tests.IsItemTourniquet_Unrelated_False()
        TestUtils.assert(TourniquetController.IsItemTourniquet("Base.BandageDirty") == false)
        TestUtils.assert(TourniquetController.IsItemTourniquet("Base.Saw") == false)
    end

    function Tests.CheckTourniquetOnLimb_NoItems_False()
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(mockPlayerNoItems(), "Hand_L") == false)
    end

    function Tests.CheckTourniquetOnLimb_CorrectSide_True()
        local pl = mockPlayerWithTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_L")
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_L")     == true)
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(pl, "ForeArm_L")  == true)
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(pl, "UpperArm_L") == true)
    end

    function Tests.CheckTourniquetOnLimb_WrongSide_False()
        local pl = mockPlayerWithTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_R")
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_L") == false)
    end

    function Tests.CheckTourniquetOnLimb_RightSide_True()
        local pl = mockPlayerWithTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_R")
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_R")    == true)
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(pl, "UpperArm_R") == true)
    end

    function Tests.CheckTourniquetOnLimb_NonTourniquetItem_False()
        local pl = mockPlayerWithTourniquet("Base.BandageDirty")
        TestUtils.assert(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_L") == false)
    end

    return Tests
end)


-- ============================================================
--  LocalPlayerController — utility methods (SP + MP)
-- ============================================================

TestFramework.registerTestModule("LocalPlayerController", "CanItemBeEquipped", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    local function mockItem(bodyLoc)
        return { getBodyLocation = function() return bodyLoc end }
    end

    function Tests.WristItem_Blocked_WhenForeArmCut()
        TestUtils.assert(LocalPlayerController.CanItemBeEquipped(mockItem("LeftWrist"), "ForeArm_L") == false)
    end

    function Tests.RingFingerItem_Blocked_WhenHandCut()
        TestUtils.assert(LocalPlayerController.CanItemBeEquipped(mockItem("Left_RingFinger"), "Hand_L") == false)
    end

    function Tests.MiddleFingerItem_Blocked_WhenHandCut()
        TestUtils.assert(LocalPlayerController.CanItemBeEquipped(mockItem("Left_MiddleFinger"), "Hand_L") == false)
    end

    function Tests.UnrelatedBodyLoc_AlwaysEquippable()
        TestUtils.assert(LocalPlayerController.CanItemBeEquipped(mockItem("Hat"), "Hand_L") == true)
    end

    function Tests.RightWrist_Blocked_WhenForeArmR_Cut()
        TestUtils.assert(LocalPlayerController.CanItemBeEquipped(mockItem("RightWrist"), "ForeArm_R") == false)
    end

    return Tests
end)

TestFramework.registerTestModule("LocalPlayerController", "HandleSetCicatrization", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.MarksCicatrizedAndResetsTime()
        local pl = getPlayer()
        return asyncAmpMP("Hand_R")
            :next(function()
                local dc = getDC()
                TestUtils.assert(dc:getIsCicatrized("Hand_R") == false)
                TestUtils.assert(dc:getCicatrizationTime("Hand_R") > 0)

                LocalPlayerController.HandleSetCicatrization(dc, pl, "Hand_R")

                TestUtils.assert(dc:getIsCicatrized("Hand_R") == true)
                TestUtils.assert(dc:getCicatrizationTime("Hand_R") == 0)
            end)
            :finally(function() requestReset() end)
    end

    return Tests
end)


-- ============================================================
--  LocalPlayerController — Cicatrization loop  [SP only]
-- ============================================================

if not isClient() then
TestFramework.registerTestModule("LocalPlayerController", "Cicatrization loop", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.SetAllCicatrizationTimesToOne()
        for i = 1, #StaticData.LIMBS_STR do
            local limbName = StaticData.LIMBS_STR[i]
            getDC():setCicatrizationTime(limbName, 1)
            TestUtils.assert(getDC():getCicatrizationTime(limbName) == 1)
        end
    end

    function Tests.RunCicatrizationLoop()
        LocalPlayerController.UpdateAmputations()
    end

    return Tests
end)
end -- if not isClient()


-- ============================================================
--  TimedActions — async tests  [SP only for Cauterize setup]
-- ============================================================

if not isClient() then
TestFramework.registerTestModule("TimedActions", "CauterizeAction", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")
    local CauterizeAction = require("TOC/TimedActions/CauterizeAction")

    local function queueCauterize(limbName)
        local pl = getPlayer()
        return AsyncTest:new()
            :next(function()
                requestReset()
                getDC():setCutLimb(limbName, false, false, false, 0)
                getDC():setCicatrizationTime(limbName, 50)
                ISTimedActionQueue.add(CauterizeAction:new(pl, limbName, pl))
            end)
            :repeatUntil(function()
                return #ISTimedActionQueue.getTimedActionQueue(pl).queue == 0
            end, 10000)
            :next(function()
                TestUtils.assert(getDC():getIsCauterized(limbName) == true)
                TestUtils.assert(getDC():getIsCicatrized(limbName) == true)
                TestUtils.assert(getDC():getCicatrizationTime(limbName) == 0)
            end)
    end

    function Tests.CauterizeLeftHand()      return queueCauterize("Hand_L")     end
    function Tests.CauterizeLeftForeArm()   return queueCauterize("ForeArm_L")  end
    function Tests.CauterizeLeftUpperArm()  return queueCauterize("UpperArm_L") end
    function Tests.CauterizeRightHand()     return queueCauterize("Hand_R")     end
    function Tests.CauterizeRightForeArm()  return queueCauterize("ForeArm_R")  end
    function Tests.CauterizeRightUpperArm() return queueCauterize("UpperArm_R") end

    return Tests
end)
end -- if not isClient()

TestFramework.registerTestModule("TimedActions", "CutLimbAction", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")
    local CutLimbAction = require("TOC/TimedActions/CutLimbAction")

    local function queueCut(limbName)
        local pl = getPlayer()
        return AsyncTest:new()
            :next(function()
                requestReset()
                local saw = pl:getInventory():FindAndReturn("Base.Saw")
                    or pl:getInventory():AddItem("Base.Saw")
                if not saw then TestUtils.fail("Could not obtain Base.Saw") end
                ISTimedActionQueue.add(CutLimbAction:new(pl, pl, limbName, saw))
            end)
            :repeatUntil(function()
                return #ISTimedActionQueue.getTimedActionQueue(pl).queue == 0
            end, 15000)
            :next(function()
                TestUtils.assert(getDC():getIsCut(limbName) == true)
            end)
            :finally(function()
                requestReset()
            end)
    end

    function Tests.CutLeftHand()     return queueCut("Hand_L")    end
    function Tests.CutRightHand()    return queueCut("Hand_R")    end
    function Tests.CutLeftForeArm()  return queueCut("ForeArm_L") end
    function Tests.CutRightForeArm() return queueCut("ForeArm_R") end

    return Tests
end)


-- ============================================================
--  Various — player state helpers (SP + MP)
-- ============================================================

TestFramework.registerTestModule("Various", "Player", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.BleedTest()
        getPlayer():getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setBleedingTime(20)
    end

    function Tests.Kill()
        getPlayer():Kill(getPlayer())
    end

    return Tests
end)

TestFramework.registerTestModule("Various", "Visuals", function()
    local Tests = TestUtils.newTestModule("client/TOC/Tests.lua")

    function Tests.AddBloodLeftForearm()
        local playerObj = getPlayer()
        local fullType = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. "ForeArm_L"
        local item = playerObj:getInventory():FindAndReturn(fullType)
        if instanceof(item, "Clothing") then
            ---@cast item Clothing
            item:setBloodLevel(100)
            local coveredParts = BloodClothingType.getCoveredParts(item:getBloodClothingType())
            if coveredParts then
                for j = 0, coveredParts:size() - 1 do
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
local PerfTest = require("PerfTest/main")

PerfTest.RegisterMethod("LocalPlayerController", LocalPlayerController, "InitializePlayer")
PerfTest.RegisterMethod("LocalPlayerController", LocalPlayerController, "UpdateAmputations")
PerfTest.RegisterMethod("CachedDataHandler", CachedDataHandler, "CalculateHighestAmputatedLimbs")
PerfTest.RegisterMethod("ISHealthPanel", ISHealthPanel, "render")

PerfTest.Init()
