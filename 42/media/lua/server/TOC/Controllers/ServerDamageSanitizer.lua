require("TOC/Debug")
local StaticData = require("TOC/StaticData")
--------------------------------------------
-- DRAFT SPIKE for #279 (server-authoritative, MP only).
--
-- Problem: a zombie bite can roll on the vanilla BodyPart of an already-amputated
-- limb (amputation is modData + stump clothing; a prosthesis is only a
-- toc:armprost_* item BodyLocation, never a damage target). The client-only
-- LocalPlayerController.HandleDamage heal may be overwritten by the
-- server-authoritative BodyDamage in B42.13+, so the bite persists on a limb
-- that no longer exists and CutLimbInteractionHandler:isValid correctly refuses
-- to re-cut the same limbName.
--
-- This sweep clears bite/infection state on cut limbs server-side, using the same
-- syncBodyPart primitive AmputationHandler already relies on. Hourly cadence is
-- plenty fast against the Knox mortality clock; an opportunistic per-hit hook
-- (e.g. from UpdateDataControllerFromClient) can be added later if needed.
--
-- TODO(playtest): confirm no interference with healInfection's <20 curability
-- window and with ignored-part (Torso_Upper etc.) infections, which must NOT be
-- cleared here.
---@class ServerDamageSanitizer
local ServerDamageSanitizer = {}

---Clear bite/infection state on the cut limbs of one player. No-ops welcome:
---runs hourly for everyone online, so it must be cheap when there is nothing to do.
---@param playerObj IsoPlayer
function ServerDamageSanitizer.SanitizePlayer(playerObj)
    if not playerObj or not isServer() then return end

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

---Hourly fallback sweep over online players. Each player is isolated with pcall
---so one bad BodyPart never aborts the rest.
local function SanitizeAllOnlinePlayers()
    if not isServer() then return end
    local players = getOnlinePlayers()
    if not players then return end
    for i = 0, players:size() - 1 do
        local ok, err = pcall(ServerDamageSanitizer.SanitizePlayer, players:get(i))
        if not ok then TOC_DEBUG.print("ServerDamageSanitizer error: " .. tostring(err)) end
    end
end

Events.EveryHours.Add(SanitizeAllOnlinePlayers)

return ServerDamageSanitizer
