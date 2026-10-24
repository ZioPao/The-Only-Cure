local t = require("harness.testkit")
local H = require("harness.init")

local ExpActions = require("TOC/ExpActions")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")

local Mocks = H.Mocks

---Build a fake timed action carrying a character + TOC flags.
local function fakeAction(player, opts)
    opts = opts or {}
    return {
        character = player,
        skipTOC = opts.skipTOC,
        noExp = opts.noExp,
    }
end

t.describe("ExpActions: IterateTOCXp", function()
    local function prepare(username, cutLimbs)
        local dc = H.initPlayer(username)
        local pl = Mocks.makePlayer({ username = username })
        Mocks.state.player = pl
        for _, limb in ipairs(cutLimbs or {}) do
            dc:setCutLimb(limb, false, false, false, 0)
        end
        CachedDataHandler.CalculateAmputatedLimbs(username)
        return dc, pl
    end

    t.it("returns nothing when the action opts out", function()
        local _, pl = prepare("Exp", { "Hand_L" })
        local calls = 0
        ExpActions.IterateTOCXp(fakeAction(pl, { noExp = true }), function() calls = calls + 1 end)
        ExpActions.IterateTOCXp(fakeAction(pl, { skipTOC = true }), function() calls = calls + 1 end)
        t.assertEquals(0, calls)
    end)

    t.it("returns nothing when no limb is cut", function()
        local _, pl = prepare("Exp", {})
        local calls = 0
        ExpActions.IterateTOCXp(fakeAction(pl), function() calls = calls + 1 end)
        t.assertEquals(0, calls)
    end)

    t.it("awards Side_L for a cut left hand", function()
        prepare("Exp", { "Hand_L" })
        local seen = {}
        local pl = Mocks.state.player
        ExpActions.IterateTOCXp(fakeAction(pl), function(_, perk) seen[perk] = true end)
        t.assertTrue(seen["Side_L"])
    end)

    t.it("does not award the opposite side", function()
        prepare("Exp", { "Hand_L" })
        local seen = {}
        local pl = Mocks.state.player
        ExpActions.IterateTOCXp(fakeAction(pl), function(_, perk) seen[perk] = true end)
        t.assertNil(seen["Side_R"])
    end)

    t.it("awards ProstFamiliarity when a prosthesis is equipped", function()
        local dc, pl = prepare("Exp", { "Hand_L" })
        dc:setIsProstEquipped("Top_L", true)
        local seen = {}
        ExpActions.IterateTOCXp(fakeAction(pl), function(_, perk) seen[perk] = true end)
        t.assertTrue(seen["ProstFamiliarity"])
    end)

    t.it("skips a perk already at level 10", function()
        local _, pl = prepare("Exp", { "Hand_L" })
        pl.perkLevels["Side_L"] = 10
        local seen = {}
        ExpActions.IterateTOCXp(fakeAction(pl), function(_, perk) seen[perk] = true end)
        t.assertNil(seen["Side_L"])
    end)

    t.it("awards both sides when both hands are cut", function()
        prepare("Exp", { "Hand_L", "Hand_R" })
        local seen = {}
        local pl = Mocks.state.player
        ExpActions.IterateTOCXp(fakeAction(pl), function(_, perk) seen[perk] = true end)
        t.assertTrue(seen["Side_L"])
        t.assertTrue(seen["Side_R"])
    end)
end)

t.describe("ExpActions: WrapUpdate", function()
    t.it("calls the original update and injects XP", function()
        local dc = H.initPlayer("Wrap")
        local pl = Mocks.makePlayer({ username = "Wrap" })
        Mocks.state.player = pl
        dc:setCutLimb("Hand_L", false, false, false, 0)
        CachedDataHandler.CalculateAmputatedLimbs("Wrap")

        local originalCalls = 0
        local cls = {
            Type = "TestAction",
            update = function() originalCalls = originalCalls + 1 end,
        }

        ExpActions.WrapUpdate(cls)

        -- The wrapped action runs as an instance carrying a character.
        local action = { character = pl }
        setmetatable(action, { __index = cls })
        action:update()

        t.assertEquals(1, originalCalls)
    end)

    t.it("ignores nil classes", function()
        ExpActions.WrapUpdate(nil)
    end)
end)
