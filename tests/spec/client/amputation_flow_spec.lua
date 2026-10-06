-- Amputation end-to-end specs (singleplayer / server context).
--
-- Folds the old data-layer cascade spec into behaviour-driven tests that run
-- AmputationHandler:execute() against the real engine: modData cascade,
-- cicatrization, stump clothing, cache, OnAmputatedLimb, adjacent-part damage
-- and item drops.

if isClient() then
    -- MP client: this file registers no tests; the runner reports it as skipped.
    return ZBSpec.run()
end

local DataController = require("TOC/Controllers/DataController")
local ClientDataController = require("TOC/Controllers/ClientDataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local ItemsController = require("TOC/Controllers/ItemsController")
local StaticData = require("TOC/StaticData")

local CHAIN = { "Hand_L", "Hand_R", "ForeArm_L", "ForeArm_R", "UpperArm_L", "UpperArm_R" }

local function username()
    return getPlayer():getUsername()
end

local function getDC()
    return DataController.GetInstance(username())
end

local function part(limbName)
    return getPlayer():getBodyDamage():getBodyPart(BodyPartType[limbName])
end

---Reset TOC data and the player's body/inventory so tests do not leak.
local function reset()
    local p = getPlayer()
    p:getBodyDamage():RestoreToFullHealth()
    p:setPrimaryHandItem(nil)
    p:setSecondaryHandItem(nil)
    ItemsController.Player.DeleteAllOldAmputationItems(p)
    ClientDataController.Request(username(), true)
    CachedDataHandler.Setup(username())
    ampEvents = {}
end

local function cut(limbName)
    reset()
    getDC():setCutLimb(limbName, false, false, false, 0)
end

local function execute(limbName, damagePlayer)
    AmputationHandler:new(getPlayer(), getPlayer(), limbName):execute(damagePlayer)
end

local function surgeonFactor()
    return getPlayer():getPerkLevel(Perks.Doctor) * SandboxVars.TOC.SurgeonAbilityImportance
end

---Is an item with this full type currently worn by the player?
local function isWorn(player, fullType)
    local worn = player:getWornItems()
    for i = 1, worn:size() do
        local entry = worn:get(i - 1)
        if entry and entry:getItem() and entry:getItem():getFullType() == fullType then
            return true
        end
    end
    return false
end

---Record every OnAmputatedLimb event (target + dependencies).
ampEvents = {}
Events.OnAmputatedLimb.Add(function(_, limbName)
    table.insert(ampEvents, limbName)
end)

describe("TOC amputation data cascade (SP)", function()
    it("starts with a ready DataController and no amputations", function()
        reset()
        assert.is_not_nil(getDC())
        assert.is_true(getDC():getIsDataReady())
        assert.is_false(getDC():getIsAnyLimbCut())
        for _, limb in ipairs(CHAIN) do
            assert.is_false(getDC():getIsCut(limb))
        end
    end)

    it("cutting a hand flags it as cut", function()
        cut("Hand_L")
        assert.is_true(getDC():getIsCut("Hand_L"))
        assert.is_true(getDC():getIsAnyLimbCut())
        reset()
    end)

    it("cutting a forearm cascades to the hand", function()
        cut("ForeArm_L")
        assert.is_true(getDC():getIsCut("ForeArm_L"))
        assert.is_true(getDC():getIsCut("Hand_L"))
        assert.is_true(getDC():getIsVisible("ForeArm_L"))
        assert.is_false(getDC():getIsVisible("Hand_L"))
        reset()
    end)

    it("cutting an upper arm cascades through the chain", function()
        cut("UpperArm_R")
        assert.is_true(getDC():getIsCut("UpperArm_R"))
        assert.is_true(getDC():getIsCut("ForeArm_R"))
        assert.is_true(getDC():getIsCut("Hand_R"))
        reset()
    end)

    it("does not contaminate the opposite side", function()
        cut("Hand_L")
        assert.is_false(getDC():getIsCut("Hand_R"))
        assert.is_false(getDC():getIsCut("ForeArm_R"))
        assert.is_false(getDC():getIsCut("UpperArm_R"))
        reset()
    end)
end)

describe("TOC AmputationHandler:execute (SP)", function()
    it("amputates a hand end-to-end", function()
        reset()
        execute("Hand_L", false)

        assert.is_true(getDC():getIsCut("Hand_L"), "Hand_L should be cut")
        assert.is_true(getDC():getIsAnyLimbCut(), "isAnyLimbCut should be true")
        -- cicatrization time = base - surgeonFactor (not cicatrized/cauterized)
        assert.eq(StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM["Hand_L"] - surgeonFactor(),
            getDC():getCicatrizationTime("Hand_L"))
        -- stump clothing spawned and worn
        assert.is_true(isWorn(getPlayer(), StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. "Hand_L"),
            "stump clothing should be worn")
        -- cache: left hand unusable, right hand fine
        assert.is_false(CachedDataHandler.GetHandFeasibility("L", username()), "left hand should be unusable")
        assert.is_true(CachedDataHandler.GetHandFeasibility("R", username()), "right hand should be usable")
        -- OnAmputatedLimb fired once (hand has no dependencies)
        assert.eq(1, #ampEvents)
        assert.eq("Hand_L", ampEvents[1])
        reset()
    end)

    it("upper-arm amputation fires events for the whole removed chain", function()
        reset()
        execute("UpperArm_R", false)

        assert.is_true(getDC():getIsCut("UpperArm_R"))
        assert.is_true(getDC():getIsCut("ForeArm_R"))
        assert.is_true(getDC():getIsCut("Hand_R"))
        assert.eq(3, #ampEvents)
        assert.eq("UpperArm_R", CachedDataHandler.GetHighestAmputatedLimbs(username())["R"])
        assert.is_false(CachedDataHandler.GetHandFeasibility("R", username()))
        reset()
    end)

    it("does not touch the other side", function()
        reset()
        execute("Hand_L", false)
        assert.is_false(getDC():getIsCut("Hand_R"))
        assert.is_false(getDC():getIsCut("ForeArm_R"))
        assert.is_true(CachedDataHandler.GetHandFeasibility("R", username()))
        reset()
    end)

    it("damages the adjacent part with a deep wound and bleeding", function()
        reset()
        execute("Hand_L", true)

        local adjacent = part("ForeArm_L")
        assert.is_true(adjacent:deepWounded())
        assert.gt(adjacent:getBleedingTime(), 0)
        -- base damage 60 to a full-health part
        assert.lt(adjacent:getHealth(), 60)
        reset()
    end)

    it("a tourniquet halves the adjacent-part damage", function()
        reset()
        local p = getPlayer()
        local tourniquet = p:getInventory():AddItem("TOC.Surg_Arm_Tourniquet_L")
        assert.is_not_nil(tourniquet)
        p:setWornItem(tourniquet:getBodyLocation(), tourniquet)

        execute("Hand_L", true)

        -- base 60 halved to 30 => health ~70 (vs ~40 without)
        assert.gt(part("ForeArm_L"):getHealth(), 60)
        reset()
    end)

    it("drops ring items worn on the amputated hand", function()
        reset()
        local p = getPlayer()
        local ring = p:getInventory():AddItem("Base.Ring_Left_RingFinger_Silver")
        assert.is_not_nil(ring)
        p:setWornItem(ring:getBodyLocation(), ring)
        assert.is_true(isWorn(p, "Base.Ring_Left_RingFinger_Silver"))

        execute("Hand_L", false)

        assert.is_false(isWorn(p, "Base.Ring_Left_RingFinger_Silver"))
        reset()
    end)

    it("stump clothing survives a clothing change (#257)", function()
        reset()
        execute("ForeArm_L", false)

        local p = getPlayer()
        local stump = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. "ForeArm_L"
        assert.is_true(isWorn(p, stump), "stump should be worn after amputation")

        -- Change clothes: toggle an existing non-stump worn item, then rebuild the model.
        local target = nil
        local worn = p:getWornItems()
        for i = 1, worn:size() do
            local entry = worn:get(i - 1)
            local it = entry and entry:getItem()
            if it and it:getFullType() ~= stump and it:getBodyLocation() then
                target = it
                break
            end
        end
        assert.is_not_nil(target, "need a worn item to change")

        p:removeWornItem(target)
        p:setWornItem(target:getBodyLocation(), target)
        p:resetModelNextFrame()

        assert.is_true(isWorn(p, stump), "stump must survive a clothing change (#257)")
        assert.is_true(getDC():getIsCut("ForeArm_L"), "limb must stay cut")
        reset()
    end)
end)

return ZBSpec.run()
