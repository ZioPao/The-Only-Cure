require("TOC/Debug")
local StaticData = require("TOC/StaticData")
--------------------------------------------
-- #279: a zombie bite can land on the vanilla BodyPart of an already-amputated
-- limb (prostheses are only modData + items, never a damage target). The owning
-- client detects it and asks the server to clear it.
---@class ServerDamageSanitizer
local ServerDamageSanitizer = {}

---Clear bite/infection state on the cut limbs of one player.
---@param playerObj IsoPlayer
function ServerDamageSanitizer.SanitizePlayer(playerObj)
    -- SP shares one Lua state (mutation applies); only refuse a pure client.
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
                dcInst:setIsInfected(limbName, false)
            end
        end
    end
end

return ServerDamageSanitizer
