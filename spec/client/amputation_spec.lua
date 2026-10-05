-- Singleplayer / server-context integration specs.
-- Runs in the real engine state (modData, BodyPartType, events) but stays on
-- the data layer, since the visual/model side of amputation needs a fully
-- rendered world (getVisual() is nil in the headless test instance).

if isClient() then
    -- Singleplayer/server-context specs: no tests run on the MP client; the
    -- runner reports the file as skipped rather than passed.
    return ZBSpec.run()
end

local DataController = require("TOC/Controllers/DataController")
local ClientDataController = require("TOC/Controllers/ClientDataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")

local function username()
    return getPlayer():getUsername()
end

local function getDC()
    return DataController.GetInstance(username())
end

---Reset TOC state for the local player (SP: synchronous).
local function reset()
    ClientDataController.Request(username(), true)
    CachedDataHandler.Setup(username())
end

local function cut(limbName)
    reset()
    getDC():setCutLimb(limbName, false, false, false, 0)
end

describe("TOC amputation data (SP)", function()
    it("starts with a ready DataController and no amputations", function()
        reset()
        assert.is_not_nil(getDC())
        assert.is_true(getDC():getIsDataReady())
        assert.is_false(getDC():getIsAnyLimbCut())
        for _, limb in ipairs({ "Hand_L", "Hand_R", "ForeArm_L", "ForeArm_R", "UpperArm_L", "UpperArm_R" }) do
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

    it("updates hand feasibility in the cache", function()
        cut("Hand_L")
        CachedDataHandler.CalculateCacheableValues(username())
        assert.is_false(CachedDataHandler.GetHandFeasibility("L", username()))
        assert.is_true(CachedDataHandler.GetHandFeasibility("R", username()))
        assert.is_true(CachedDataHandler.GetBothHandsFeasibility(username()))
        reset()
    end)
end)

-- Full AmputationHandler:execute() exercises the item/visual path
-- (SpawnAmputationItem -> clothingItem:getVisual()), which needs a rendered
-- world and is nil in the headless test instance. The cascade + cache logic is
-- covered by the data-layer specs above and by the mocked unit specs.
-- Enable this once the harness runs against a fully loaded save.
describe("TOC amputation handler (SP)", function()
    pending("AmputationHandler:execute() cuts a hand end-to-end", function()
        local AmputationHandler = require("TOC/Handlers/AmputationHandler")
        reset()
        local p = getPlayer()
        AmputationHandler:new(p, p, "Hand_L"):execute(false)
        assert.is_true(getDC():getIsCut("Hand_L"))
        reset()
    end)
end)

return ZBSpec.run()
