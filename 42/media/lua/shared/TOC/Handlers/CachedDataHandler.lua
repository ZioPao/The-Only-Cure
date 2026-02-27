-- B42 Overhaul necessary, separte server only functions from client/shared ones


local DataController = require("TOC/Controllers/DataController")
local StaticData = require("TOC/StaticData")
---------------------------

---@class CachedDataHandler
local CachedDataHandler = {}

CachedDataHandler.amputatedLimbs = {}
CachedDataHandler.highestAmputatedLimbs = {}
CachedDataHandler.handFeasibility = {}

---Reset everything cache related for that specific user
---@param username string
function CachedDataHandler.Setup(username)
    CachedDataHandler.amputatedLimbs[username] = {}
    -- username -> side
    CachedDataHandler.highestAmputatedLimbs[username] = {}

    -- per-username feasibility table
    CachedDataHandler.handFeasibility[username] = {}
end

---CLIENT ONLY
---@param patientUsername string
---@param cache table
function CachedDataHandler.ApplyFromServer(patientUsername, cache)

    CachedDataHandler.amputatedLimbs[patientUsername] = cache.amputatedLimbs or {}
    CachedDataHandler.highestAmputatedLimbs[patientUsername] = cache.highestAmputatedLimbs or {}
    CachedDataHandler.handFeasibility[patientUsername] = cache.handFeasibility or {}

    -- TOC_DEBUG.printTable(CachedDataHandler.amputatedLimbs[playerUsername])
    -- TOC_DEBUG.printTable(CachedDataHandler.highestAmputatedLimbs[playerUsername])
    -- TOC_DEBUG.printTable(CachedDataHandler.handFeasibility[playerUsername])
end

--CLIENT ONLY
function CachedDataHandler.RequestFromServer(patientUsername, recalculate)
    TOC_DEBUG.print("Requesting cache from server for player " .. tostring(patientUsername))
    local CommandsData = require("TOC/CommandsData")
    sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.SendCache,
    {patientUsername = patientUsername, recalculate = recalculate})
end

---SERVER ONLY
---Will calculate all the values that we need
function CachedDataHandler.CalculateCacheableValues(username)
    CachedDataHandler.CalculateHighestAmputatedLimbs(username)
    CachedDataHandler.CalculateHandFeasibility(username, "Hand_L")
    CachedDataHandler.CalculateHandFeasibility(username, "Hand_R")

    -- Recalculate hand feasibility for the given username.
    -- Only run the keybinding/UI parts on the local client for the local player.
    -- if username and isClient() and getPlayer() and getPlayer():getUsername() == username then
    --     CachedDataHandler.OverrideBothHandsFeasibility(username)
    -- else
    --     -- Still calculate the raw feasibility values on server/other contexts
    --     CachedDataHandler.CalculateHandFeasibility(username, "Hand_L")
    --     CachedDataHandler.CalculateHandFeasibility(username, "Hand_R")
    -- end
end

---SHARED
function CachedDataHandler.GetAll(username)
    return {
        amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(username),
        highestAmputatedLimbs = CachedDataHandler.GetHighestAmputatedLimbs(username),
        handFeasibility = {
            ["L"] = CachedDataHandler.GetHandFeasibility("L", username),
            ["R"] = CachedDataHandler.GetHandFeasibility("R", username)
        }
    }
end

--* Amputated Limbs caching *--


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

---SERVER SIDE ONLY
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


---SERVER SIDE ONLY
---@private
---@param username string
---@param limbName string
function CachedDataHandler.CalculateHandFeasibility(username, limbName)
    local CommonMethods = require("TOC/CommonMethods")
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

---SHARED
---@param side string Either "L" or "R"
---@param username string username to query
---@return boolean
function CachedDataHandler.GetHandFeasibility(side, username)
    if CachedDataHandler.handFeasibility[username] == nil then
        TOC_DEBUG.print("handFeasibility cache missing for " .. tostring(username))
        return false
    end

    return CachedDataHandler.handFeasibility[username][side]
end

---CLIENT ONLY
---@param username string
function CachedDataHandler.OverrideInteractionsKey(username)
    -- Resolve username to local player on client if omitted

    if CachedDataHandler.handFeasibility[username] == nil then
         return
    end

    local interactStr = "Interact"
    -- Only touch keybindings/UI when running on the local client and for that client username
    if CachedDataHandler.interactKey == nil or CachedDataHandler.interactKey == 0 then
        CachedDataHandler.interactKey = getCore():getKey(interactStr)
    end
    
    if not CachedDataHandler.GetBothHandsFeasibility(username) then
        TOC_DEBUG.print("Disabling interact key for local player")
        TOC_DEBUG.print("Cached current key for interact: " .. tostring(CachedDataHandler.interactKey))

        getCore():addKeyBinding(interactStr, CachedDataHandler.interactKey and CachedDataHandler.interactKey or Keyboard.KEY_NONE, 0, false, false, false)
        getCore():addKeyBinding(interactStr, Keyboard.KEY_NONE, 0, false, false, false)

    else
        getCore():addKeyBinding(interactStr, CachedDataHandler.interactKey, 0, false, false, false)

    end
end


---SHARED
---@param username string
---@return boolean
function CachedDataHandler.GetBothHandsFeasibility(username)
    -- Resolve username to local player on client if omitted
    if CachedDataHandler.handFeasibility[username] == nil then
        TOC_DEBUG.print("handFeasibility cache missing for " .. tostring(username))
        return false
    end

    return (CachedDataHandler.handFeasibility[username]["L"] or CachedDataHandler.handFeasibility[username]["R"]) or false
end

------------------

---SERVER ONLY
---@param player IsoPlayer Player that will receive cache
---@param patientUsername string username of player with cached values
---@param recalculate boolean
function CachedDataHandler.SendCache(player, patientUsername, recalculate)
    if recalculate then
        CachedDataHandler.CalculateCacheableValues(patientUsername)
    end
    local cache = CachedDataHandler.GetAll(patientUsername)
    local CommandsData = require("TOC/CommandsData")

    -- UGLY should be in ServerRelayCommands, but to not create circular dependencies we are keeping it here for now
    sendServerCommand(player, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveCache, {
        patientUsername = patientUsername, cache = cache})
end


if isServer() then
    Events.OnServerStarted.Add(function()
        TOC_DEBUG.print("Setting up CachedDataHandler events")
        Events.OnInitTocData.Add(CachedDataHandler.SendCache)
    end)
end
return CachedDataHandler