require("TOC/Debug")
local StaticData = require("TOC/StaticData")
--------------------------------------------
-- On-demand sanitizer for #279. There is deliberately NO global sweep here: the
-- server never enumerates players (see review notes). Detection runs on each
-- client (LocalPlayerController.PollCutLimbsForBites, local-player-only) and the
-- server acts solely when asked, for the asking player, via RequestSanitizeCutLimb.
--
-- Problem: a zombie bite can roll on the vanilla BodyPart of an already-amputated
-- limb (amputation is modData + stump clothing; a prosthesis is only a
-- toc:armprost_* item BodyLocation, never a damage target). Zombie-hit BodyDamage
-- is server-simulated (AddRandomDamageFromZombie early-returns on clients; the
-- server pushes full state back via PlayerDamage packet), and client Lua can never
-- push BodyDamage back (syncBodyPart is a no-op outside the server), so the bite
-- persists on a limb that no longer exists while CutLimbInteractionHandler:isValid
-- correctly refuses to re-cut the same limbName.
--
-- This clears bite/infection state on cut limbs using the same syncBodyPart
-- primitive AmputationHandler already relies on.
--
-- TODO(playtest): confirm no interference with healInfection's <20 curability
-- window and with ignored-part (Torso_Upper etc.) infections, which must NOT be
-- cleared here (this loop only visits the 6 arm limbs, never ignored parts).
---@class ServerDamageSanitizer
local ServerDamageSanitizer = {}

---Clear bite/infection state on the cut limbs of one player. Idempotent:
---re-running on clean state is a cheap no-op loop, safe under double execution
---(e.g. listen-server host) and repeated client requests.
---@param playerObj IsoPlayer
function ServerDamageSanitizer.SanitizePlayer(playerObj)
    -- Refuse pure-client context only. SP (neither client nor server) shares one
    -- Lua state, so direct mutation applies and syncBodyPart harmlessly no-ops.
    if not playerObj or (isClient() and not isServer()) then return end

    local DataController = require("TOC/Controllers/DataController")
    local dcInst = DataController.GetInstance(playerObj:getUsername())
    if not dcInst or not dcInst:getIsDataReady() then return end
    if not dcInst:getIsAnyLimbCut() then return end

    local bd = playerObj:getBodyDamage()
    if not bd then return end

    for i = 1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        if dcInst:getIsCut(limbName) then
            local bptEnum = StaticData.LIMBS_TO_BODYLOCS_IND_BPT[limbName]
            local part = bptEnum and bd:getBodyPart(bptEnum) or nil
            if part and (part:bitten() or part:IsInfected()) then
                TOC_DEBUG.print("ServerDamageSanitizer: clearing bite on missing limb - " .. limbName)
                part:SetBitten(false)
                if part.setBiteTime then part:setBiteTime(0) end
                part:SetInfected(false)
                if part.setInfected then part:setInfected(false) end
                if part.setInfectionTime then part:setInfectionTime(0) end
                syncBodyPart(part, 0xFFFFFFFFFFF)
                dcInst:setIsInfected(limbName, false)
            elseif part and dcInst:getIsInfected(limbName) and not part:HasInjury() then
                -- Wound visual already clean but the modData flag stayed stale.
                dcInst:setIsInfected(limbName, false)
            end
        end
    end
end

return ServerDamageSanitizer
