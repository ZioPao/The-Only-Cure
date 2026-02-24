local DataController = require("TOC/Controllers/DataController")
local StaticData = require("TOC/StaticData")
---------------------------

---@class CachedDataHandler
local CachedDataHandler = {}

---Reset everything cache related for that specific user
---@param username string
function CachedDataHandler.Setup(username)
    CachedDataHandler.amputatedLimbs[username] = {}
    -- username -> side
    CachedDataHandler.highestAmputatedLimbs[username] = {}

    -- per-username feasibility table
    CachedDataHandler.handFeasibility[username] = {}
end

---Will calculate all the values that we need
function CachedDataHandler.CalculateCacheableValues(username)
    CachedDataHandler.CalculateHighestAmputatedLimbs(username)

    -- Recalculate hand feasibility for the given username.
    -- Only run the keybinding/UI parts on the local client for the local player.
    if username and isClient() and getPlayer() and getPlayer():getUsername() == username then
        CachedDataHandler.OverrideBothHandsFeasibility(username)
    else
        -- Still calculate the raw feasibility values on server/other contexts
        CachedDataHandler.CalculateHandFeasibility(username, "Hand_L")
        CachedDataHandler.CalculateHandFeasibility(username, "Hand_R")
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

---Calculate the highest point of amputations achieved by the player
---@param username string
function CachedDataHandler.CalculateHighestAmputatedLimbs(username)
    TOC_DEBUG.print("Triggered CalculateHighestAmputatedLimbs for " .. tostring(username))
    local dcInst = DataController.GetInstance(username)
    if dcInst == nil then
        TOC_DEBUG.print("DataController not found for " .. tostring(username))
        return
    end

    CachedDataHandler.CalculateAmputatedLimbs(username)

    local amputatedLimbs = CachedDataHandler.amputatedLimbs[username] or {}
    CachedDataHandler.highestAmputatedLimbs[username] = {}
    local CommonMethods = require("TOC/CommonMethods")

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

---@param username string
---@param limbName string
function CachedDataHandler.CalculateHandFeasibility(username, limbName)
    local CommonMethods = require("TOC/CommonMethods")

    -- Resolve username to local player on client if omitted
    if username == nil then
        if isClient() and getPlayer() then
            username = getPlayer():getUsername()
        else
            TOC_DEBUG.print("CalculateHandFeasibility called without username on server/invalid context")
            return
        end
    end

    local dcInst = DataController.GetInstance(username)
    if dcInst == nil then
        TOC_DEBUG.print("DataController not found for CalculateHandFeasibility for " .. tostring(username))
        return
    end

    local side = CommonMethods.GetSide(limbName)

    CachedDataHandler.handFeasibility[username] = CachedDataHandler.handFeasibility[username] or {}
    CachedDataHandler.handFeasibility[username][side] = not dcInst:getIsCut(limbName) or dcInst:getIsProstEquipped(limbName)
    TOC_DEBUG.print("Calculated hand feasibility for " .. tostring(username) .. " side: " .. tostring(side))
end

---@param side string Either "L" or "R"
---@param username string (optional) username to query; defaults to local player on client
---@return boolean
function CachedDataHandler.GetHandFeasibility(side, username)

    -- Resolve username to local player on client if omitted
    if username == nil then
        if isClient() and getPlayer() then
            username = getPlayer():getUsername()
        else
            TOC_DEBUG.print("GetHandFeasibility called without username on server/invalid context")
            return false
        end
    end

    CachedDataHandler.handFeasibility[username] = CachedDataHandler.handFeasibility[username] or {}

    -- If missing, recalculate for that user
    if CachedDataHandler.handFeasibility[username][side] == nil then
        CachedDataHandler.OverrideBothHandsFeasibility(username)
    end

    return CachedDataHandler.handFeasibility[username][side]
end

function CachedDataHandler.OverrideBothHandsFeasibility(username)
    -- Resolve username to local player on client if omitted
    if username == nil then
        if isClient() and getPlayer() then
            username = getPlayer():getUsername()
        else
            TOC_DEBUG.print("OverrideBothHandsFeasibility called without username on server/invalid context")
            return
        end
    end

    CachedDataHandler.CalculateHandFeasibility(username, "Hand_L")
    CachedDataHandler.CalculateHandFeasibility(username, "Hand_R")
    local interactStr = "Interact"

    -- Only touch keybindings/UI when running on the local client and for that client username
    if isClient() and getPlayer() and getPlayer():getUsername() == username then

        if CachedDataHandler.interactKey == nil or CachedDataHandler.interactKey == 0 then
            CachedDataHandler.interactKey = getCore():getKey(interactStr)
        end

        if not CachedDataHandler.GetBothHandsFeasibility(username) then
            TOC_DEBUG.print("Disabling interact key for local player")
            TOC_DEBUG.print("Cached current key for interact: " .. tostring(CachedDataHandler.interactKey))

            if StaticData.COMPAT_42 then
                getCore():addKeyBinding(interactStr, Keyboard.KEY_NONE, 0, false, false, false)
            else
                getCore():addKeyBinding(interactStr, CachedDataHandler.interactKey and CachedDataHandler.interactKey or Keyboard.KEY_NONE)
                getCore():addKeyBinding(interactStr, Keyboard.KEY_NONE)
            end
        else
            -- Restore cached key for local player
            TOC_DEBUG.print("Re-enabling interact key for local player")
            TOC_DEBUG.print("Cached current key for interact: " .. tostring(CachedDataHandler.interactKey))

            if StaticData.COMPAT_42 then
                getCore():addKeyBinding(interactStr, CachedDataHandler.interactKey, 0, false, false, false)
            else
                getCore():addKeyBinding(interactStr, CachedDataHandler.interactKey)
            end
        end
    end
end

function CachedDataHandler.GetBothHandsFeasibility(username)
    -- Resolve username to local player on client if omitted
    if username == nil then
        if isClient() and getPlayer() then
            username = getPlayer():getUsername()
        else
            TOC_DEBUG.print("GetBothHandsFeasibility called without username on server/invalid context")
            return false
        end
    end

    CachedDataHandler.handFeasibility[username] = CachedDataHandler.handFeasibility[username] or {}
    return (CachedDataHandler.handFeasibility[username]["L"] or CachedDataHandler.handFeasibility[username]["R"]) or false
end

return CachedDataHandler