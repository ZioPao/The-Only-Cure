local StaticData = require("TOC/StaticData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local CommonMethods = require("TOC/CommonMethods")

---@class CachedDataHandler
local CachedDataHandler = {}



--* Amputated Limbs caching *--
CachedDataHandler.amputatedLimbs = {}

function CachedDataHandler.CalculateAmputatedLimbs(username)
    local modDataHandler = ModDataHandler.GetInstance(username)
    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        if modDataHandler:getIsCut(limbName) then
            CachedDataHandler.AddAmputatedLimb(username, limbName)
        end
    end
end

function CachedDataHandler.AddAmputatedLimb(username, limbName)
    TOC_DEBUG.print("added " .. limbName .. " to known amputated limbs for " .. username)
    table.insert(CachedDataHandler.amputatedLimbs[username], limbName)
end

function CachedDataHandler.GetAmputatedLimbs(username)
    return CachedDataHandler.amputatedLimbs[username]
end


--* Highest amputated limb per side caching *--
CachedDataHandler.highestAmputatedLimbs = {}


function CachedDataHandler.CalculateHighestAmputatedLimbs(username)
    if CachedDataHandler.amputatedLimbs == nil or CachedDataHandler.amputatedLimbs[username] == nil then
        TOC_DEBUG.print("Amputated limbs weren't calculated. Trying to calculate them now for " .. username)
        CachedDataHandler.CalculateAmputatedLimbs(username)
        return
    end

    local amputatedLimbs = CachedDataHandler.amputatedLimbs[username]
    CachedDataHandler.highestAmputatedLimbs[username] = {}
    TOC_DEBUG.print("Searching highest amputations for " .. username)
    local modDataHandler = ModDataHandler.GetInstance(username)
    if modDataHandler == nil then
        TOC_DEBUG.print("ModDataHandler not found for " .. username)
        return
    end

    for i=1, #amputatedLimbs do
        local limbName = amputatedLimbs[i]
        local index = CommonMethods.GetSide(limbName)
        if modDataHandler:getIsCut(limbName) and modDataHandler:getIsVisible(limbName) then
            TOC_DEBUG.print("found high amputation " .. limbName)
            CachedDataHandler.highestAmputatedLimbs[username][index] = limbName
        end
    end
end

function CachedDataHandler.GetHighestAmputatedLimbs(username)
    return CachedDataHandler.highestAmputatedLimbs[username]
end



return CachedDataHandler