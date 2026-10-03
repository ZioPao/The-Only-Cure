-- Singleplayer / server-context integration specs.
-- Skipped on a multiplayer client (where amputations must go through the relay).
if isClient() then
    return ZBSpec.run()
end

local DataController = require("TOC/Controllers/DataController")
local ClientDataController = require("TOC/Controllers/ClientDataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")

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
    AmputationHandler:new(getPlayer(), getPlayer(), limbName):execute(false)
end

describe("TOC amputation (SP)", function()
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

    it("updates the amputated-limb cache", function()
        cut("Hand_L")
        local amputated = CachedDataHandler.GetAmputatedLimbs(username())
        assert.is_table(amputated)
        assert.is_not_nil(amputated["Hand_L"])
        reset()
    end)
end)

return ZBSpec.run()
