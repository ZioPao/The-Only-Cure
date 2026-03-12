local DataController = require("TOC/Controllers/DataController")
local CommandsData = require("TOC/CommandsData")
local StaticData = require("TOC/StaticData")

---Owns the client-side async data load cycle.
---In SP: initializes DC directly via ServerDataController (no relay command, no double-init).
---In MP client: creates a placeholder DC and requests data from server via relay command.
---@class ClientDataController
local ClientDataController = {}

---Request DC data for a username.
---SP path: calls ServerDataController.Initialize directly — synchronous, no relay.
---MP path: creates placeholder DC shell, sends relay command to server.
---@param username string
---@param isForced boolean?
---@param playerObj IsoPlayer?
function ClientDataController.Request(username, isForced, playerObj)
    TOC_DEBUG.print("ClientDataController.Request for " .. username)

    if not isClient() then
        -- SP: server scripts are in the same Lua state, initialize directly
        local ServerDataController = require("TOC/Controllers/ServerDataController")
        ServerDataController.Initialize(username, isForced, playerObj)
    else
        -- MP client: create placeholder shell, server will respond with data
        DataController:new(username, isForced)
        sendClientCommand(CommandsData.modules.TOC_RELAY,
            CommandsData.server.Relay.RelayRequestDataController,
            {username = username, isForced = isForced})
    end
end

---Called when server data arrives via OnReceiveGlobalModData.
---Fills the DC instance with received data and fires WhenReady callbacks.
---@param key string  ModData key e.g. "TOC_Bob"
---@param data tocModDataType
function ClientDataController.OnDataReceived(key, data)
    -- During startup the game can return Bob as the player username, skip it
    if key == "TOC_Bob" then return end
    if not luautils.stringStarts(key, StaticData.MOD_NAME .. "_") then return end

    TOC_DEBUG.print("ClientDataController.OnDataReceived for " .. key)
    local username = key:sub(#StaticData.MOD_NAME + 2)  -- strip "TOC_" prefix
    local handler = DataController.GetInstance(username)

    if not handler then
        TOC_DEBUG.print("No DC instance found for " .. username .. ", ignoring")
        return
    end

    if data == nil or data == false or data.limbs == nil then
        TOC_DEBUG.print("data/data.limbs is nil — new character or something is wrong")
        return
    end

    -- Populate DC and fire WhenReady callbacks
    handler:save(data)

    triggerEvent("OnReceivedTocData", username)

    -- Activate TOC override for the health panel
    SetHealthPanelTOC()
end

Events.OnReceiveGlobalModData.Add(ClientDataController.OnDataReceived)

return ClientDataController
