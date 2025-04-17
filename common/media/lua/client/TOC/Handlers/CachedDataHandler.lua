local DataController = require("TOC/Controllers/DataController")

local StaticData = require("TOC/StaticData")
local CommonMethods = require("TOC/CommonMethods")
---------------------------

---@class CachedDataHandler
local CachedDataHandler = {}

---Reset everything cache related for that specific user
---@param username string
function CachedDataHandler.Setup(username)
    CachedDataHandler.amputatedLimbs[username] = {}
    -- username -> side
    CachedDataHandler.highestAmputatedLimbs[username] = {}


    -- Local only, doesn't matter for Health Panel
    CachedDataHandler.handFeasibility = {}
end

---Will calculate all the values that we need
function CachedDataHandler.CalculateCacheableValues(username)
    CachedDataHandler.CalculateHighestAmputatedLimbs(username)
    if getPlayer():getUsername() == username then
        CachedDataHandler.CalculateBothHandsFeasibility()
    end
end



--* Amputated Limbs caching *--
CachedDataHandler.amputatedLimbs = {}

---Calculate the currently amputated limbs for a certain player
---@param username string
function CachedDataHandler.CalculateAmputatedLimbs(username)
    TOC_DEBUG.print("Calculating amputated limbs for " .. username)
    CachedDataHandler.amputatedLimbs[username] = {}
    local dcInst = DataController.GetInstance(username)

    for i=1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        if dcInst:getIsCut(limbName) then
            CachedDataHandler.AddAmputatedLimb(username, limbName)
        end
    end
end



---Add an amputated limb to the cached list for that user
---@param username string
---@param limbName string
function CachedDataHandler.AddAmputatedLimb(username, limbName)
    TOC_DEBUG.print("Added " .. limbName .. " to known amputated limbs for " .. username)

    -- Add it to the generic list
    if CachedDataHandler.amputatedLimbs[username] == nil then
        CachedDataHandler.amputatedLimbs[username] = {}
    end
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
    TOC_DEBUG.print("Triggered CalculateHighestAmputatedLimbs")
    local dcInst = DataController.GetInstance(username)
    if dcInst == nil then
        TOC_DEBUG.print("DataController not found for " .. username)
        return
    end

    CachedDataHandler.CalculateAmputatedLimbs(username)

    local amputatedLimbs = CachedDataHandler.amputatedLimbs[username]
    CachedDataHandler.highestAmputatedLimbs[username] = {}
    --TOC_DEBUG.print("Searching highest amputations for " .. username)

    for k, _ in pairs(amputatedLimbs) do
        local limbName = k
        local side = CommonMethods.GetSide(limbName)
        if dcInst:getIsCut(limbName) and dcInst:getIsVisible(limbName) then
            TOC_DEBUG.print("Added Highest Amputation: " .. limbName)
            CachedDataHandler.highestAmputatedLimbs[username][side] = limbName
        end
    end
end


---Get the cached highest point of amputation for each side
---@param username string
---@return table<string, string>
function CachedDataHandler.GetHighestAmputatedLimbs(username)
    return CachedDataHandler.highestAmputatedLimbs[username]
end





--* Hand feasibility caching *--
CachedDataHandler.handFeasibility = {}

---@param limbName string
function CachedDataHandler.CalculateHandFeasibility(limbName)
    local dcInst = DataController.GetInstance()
    local side = CommonMethods.GetSide(limbName)

    -- TODO if we re run this too early, it might break everything after a forced re-init

    CachedDataHandler.handFeasibility[side] = not dcInst:getIsCut(limbName) or dcInst:getIsProstEquipped(limbName)
    TOC_DEBUG.print("Calculated hand feasibility: " .. tostring(side))
end

---@param side string Either "L" or "R"
---@return boolean
function CachedDataHandler.GetHandFeasibility(side)

    -- FIX horrendous workaround, but with a forced init we run the caching too early and it breaks this, setting it to nil.
    if CachedDataHandler.handFeasibility[side] == nil then
        CachedDataHandler.CalculateBothHandsFeasibility()
    end

    return CachedDataHandler.handFeasibility[side]
end


function CachedDataHandler.CalculateBothHandsFeasibility()
    CachedDataHandler.CalculateHandFeasibility("Hand_L")
    CachedDataHandler.CalculateHandFeasibility("Hand_R")
    local interactStr = "Interact"

    if CachedDataHandler.interactKey == nil or CachedDataHandler.interactKey == 0 then
        CachedDataHandler.interactKey = getCore():getKey(interactStr)
    end



    if not CachedDataHandler.GetBothHandsFeasibility() then
        TOC_DEBUG.print("Disabling interact key")
        TOC_DEBUG.print("Cached current key for interact: " .. tostring(CachedDataHandler.interactKey))
        getCore():addKeyBinding(interactStr, Keyboard.KEY_NONE)
    else
        TOC_DEBUG.print("Re-enabling interact key")
        TOC_DEBUG.print("Cached current key for interact: " .. tostring(CachedDataHandler.interactKey))

        getCore():addKeyBinding(interactStr, CachedDataHandler.interactKey)
    end
end

function CachedDataHandler.GetBothHandsFeasibility()
    return CachedDataHandler.handFeasibility["L"] or CachedDataHandler.handFeasibility["R"]
end

return CachedDataHandler