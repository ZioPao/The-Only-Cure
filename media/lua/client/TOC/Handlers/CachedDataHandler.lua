local StaticData = require("TOC/StaticData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local CommonMethods = require("TOC/CommonMethods")
---------------------------

---@class CachedDataHandler
local CachedDataHandler = {}

---Reset everything cache related for that specific user
---@param username string
function CachedDataHandler.Reset(username)
    CachedDataHandler.amputatedLimbs[username] = {}
    CachedDataHandler.highestAmputatedLimbs[username] = {}
end

--* Amputated Limbs caching *--
CachedDataHandler.amputatedLimbs = {}

---Calculate the currently amputated limbs for a certain player
---@param username string
function CachedDataHandler.CalculateAmputatedLimbs(username)
    TOC_DEBUG.print("[CachedDataHandler] Calculating amputated limbs for " .. username)
    CachedDataHandler.amputatedLimbs[username] = {}
    local modDataHandler = ModDataHandler.GetInstance(username)

    -- TODO If the data hasn't arrived, this won't work
    for i=1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        if modDataHandler:getIsCut(limbName) then
            CachedDataHandler.AddAmputatedLimb(username, limbName)
        end
    end
end



---Add an amputated limb to the cached list for that user
---@param username string
---@param limbName string
function CachedDataHandler.AddAmputatedLimb(username, limbName)
    TOC_DEBUG.print("added " .. limbName .. " to known amputated limbs for " .. username)

    -- Add it to the generic list
    CachedDataHandler.amputatedLimbs[username][limbName] = limbName
end

---Returns a table containing the cached amputated limbs
---@param username string
---@return table
function CachedDataHandler.GetAmputatedLimbs(username)
    return CachedDataHandler.amputatedLimbs[username]
end

--* Highest amputated limb per side caching *--
CachedDataHandler.highestAmputatedLimbs = {}

---Calcualate the highest point of amputations achieved by the player
---@param username string
function CachedDataHandler.CalculateHighestAmputatedLimbs(username)
    TOC_DEBUG.print("[CachedDataHandler] Triggered CalculateHighestAmputatedLimbs")
    local modDataHandler = ModDataHandler.GetInstance(username)
    if modDataHandler == nil then
        TOC_DEBUG.print("ModDataHandler not found for " .. username)
        return
    end

    if CachedDataHandler.amputatedLimbs == nil or CachedDataHandler.amputatedLimbs[username] == nil then
        --- This function gets ran pretty early, we need to account for the Bob stuff
        -- if username == "Bob" then
        --     TOC_DEBUG.print("skip, Bob is default char")
        --     return
        -- end

        TOC_DEBUG.print("Amputated limbs weren't calculated. Trying to calculate them now for " .. username)
        CachedDataHandler.CalculateAmputatedLimbs(username)
    end

    local amputatedLimbs = CachedDataHandler.amputatedLimbs[username]
    CachedDataHandler.highestAmputatedLimbs[username] = {}
    --TOC_DEBUG.print("Searching highest amputations for " .. username)

    for k, _ in pairs(amputatedLimbs) do
        local limbName = k
        local index = CommonMethods.GetSide(limbName)
        if modDataHandler:getIsCut(limbName) and modDataHandler:getIsVisible(limbName) then
            TOC_DEBUG.print("found high amputation " .. limbName)
            CachedDataHandler.highestAmputatedLimbs[username][index] = limbName
        end
    end
end


---Get the cached highest point of amputation for each side
---@param username string
---@return table
function CachedDataHandler.GetHighestAmputatedLimbs(username)
    return CachedDataHandler.highestAmputatedLimbs[username]
end



return CachedDataHandler