-- Issue #290 regression: a zombie bite on a limb that then gets amputated.
--
-- Reporter sequence (2.4.1): a zombie bites a limb, the limb is amputated, and
-- the bite persists on a limb that no longer exists. These specs pin down which
-- code path clears a bite and which one does not, on the real engine.
--
-- Runs in singleplayer / server context (isClient() == false). In an MP client
-- this file is skipped, like the other spec/client file.

if isClient() then
    return ZBSpec.run()
end

local DataController = require("TOC/Controllers/DataController")
local ClientDataController = require("TOC/Controllers/ClientDataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local ServerDamageSanitizer = require("TOC/Controllers/ServerDamageSanitizer")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")

local function username()
    return getPlayer():getUsername()
end

local function getDC()
    return DataController.GetInstance(username())
end

local function part(limbName)
    return getPlayer():getBodyDamage():getBodyPart(BodyPartType[limbName])
end

---Reset TOC state and the player's body so tests do not leak into each other.
local function reset()
    getPlayer():getBodyDamage():RestoreToFullHealth()
    ClientDataController.Request(username(), true)
    CachedDataHandler.Setup(username())
    LocalPlayerController.sanitizePollTick = 0
    LocalPlayerController.sanitizeLastRequestTick = {}
end

local function cut(limbName)
    reset()
    getDC():setCutLimb(limbName, false, false, false, 0)
end

describe("TOC bite on amputated limb (#290)", function()
    it("healArea clears a bite on the limb being amputated", function()
        cut("UpperArm_L")
        local target = part("UpperArm_L")
        target:SetBitten(true)
        assert.is_true(target:bitten())

        AmputationHandler:new(getPlayer(), getPlayer(), "UpperArm_L"):healArea()

        assert.is_false(target:bitten())
        reset()
    end)

    it("healArea does NOT clear a bite on a removed dependent limb (#290 repro)", function()
        cut("UpperArm_L") -- also marks ForeArm_L + Hand_L as cut
        assert.is_true(getDC():getIsCut("Hand_L"))

        local hand = part("Hand_L")
        hand:SetBitten(true)
        assert.is_true(hand:bitten())

        AmputationHandler:new(getPlayer(), getPlayer(), "UpperArm_L"):healArea()

        -- Documents the gap: healArea only restores the target + its adjacent
        -- part, so a bite on the implicitly-removed chain survives amputation.
        assert.is_true(hand:bitten())
        reset()
    end)

    it("ServerDamageSanitizer clears a bite on any cut limb", function()
        cut("UpperArm_L")
        local hand = part("Hand_L")
        hand:SetBitten(true)
        assert.is_true(hand:bitten())

        ServerDamageSanitizer.SanitizePlayer(getPlayer())

        assert.is_false(hand:bitten())
        assert.is_false(getDC():getIsInfected("Hand_L"))
        reset()
    end)

    it("PollCutLimbsForBites reacts to a bite on a cut limb (detect + request)", function()
        cut("Hand_L")
        assert.is_true(getDC():getIsAnyLimbCut())
        assert.is_true(getDC():getIsCut("Hand_L"))

        -- The poll is also driven by Events.OnPlayerUpdate. Detach it so the
        -- engine cannot consume the bite/scan before our deterministic call.
        Events.OnPlayerUpdate.Remove(LocalPlayerController.PollCutLimbsForBites)

        local hand = part("Hand_L")
        hand:SetBitten(true)
        assert.is_true(hand:bitten())

        local ok, err = pcall(function()
            LocalPlayerController.sanitizePollTick = LocalPlayerController.sanitizePollInterval - 1
            LocalPlayerController.sanitizeLastRequestTick = {}
            LocalPlayerController.PollCutLimbsForBites(getPlayer())
        end)

        Events.OnPlayerUpdate.Add(LocalPlayerController.PollCutLimbsForBites)

        assert.is_true(ok, tostring(err))
        -- Detection branch ran: local relief via HealArea.
        assert.is_false(hand:bitten())
        -- The per-limb throttle is stamped on the line before the request is
        -- sent; the actual client->server send is covered by the mocked unit
        -- spec and the MP relay specs.
        assert.eq(LocalPlayerController.sanitizePollTick,
            LocalPlayerController.sanitizeLastRequestTick["Hand_L"])
        reset()
    end)

    it("healInfection clears the virus when early, refuses when late or ignored", function()
        reset()
        local p = getPlayer()
        local bd = p:getBodyDamage()
        local stats = p:getStats()

        bd:setInfected(true)
        stats:set(CharacterStat.ZOMBIE_INFECTION, 5)
        AmputationHandler:new(p, p, "Hand_L"):healInfection(false)
        assert.is_false(bd:isInfected())
        assert.eq(0, stats:get(CharacterStat.ZOMBIE_INFECTION))

        bd:setInfected(true)
        stats:set(CharacterStat.ZOMBIE_INFECTION, 50)
        AmputationHandler:new(p, p, "Hand_L"):healInfection(false)
        assert.is_true(bd:isInfected())

        bd:setInfected(true)
        stats:set(CharacterStat.ZOMBIE_INFECTION, 5)
        AmputationHandler:new(p, p, "Hand_L"):healInfection(true)
        assert.is_true(bd:isInfected())

        reset()
    end)
end)

return ZBSpec.run()
