require ("TOC/Debug")
local CommandsData = require("TOC/CommandsData")
--------------------------------------------

local ServerRelayCommands = {}

-- TODO We can easily make this a lot more simple without having functions 

---Relay DamageDuringAmputation to another client
---@param args relayDamageDuringAmputationParams
function ServerRelayCommands.RelayDamageDuringAmputation(_, args)
    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end
    ---@type receiveDamageDuringAmputationParams
    --local params = {limbName = args.limbName}
    local AmputationHandler = require("TOC/Handlers/AmputationHandler")
    AmputationHandler.ApplyDamageDuringAmputation(patientPl, args.limbName)     -- ignore warning, class is in shared
    --sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveDamageDuringAmputation, params)
end

---Relay ExecuteAmputationAction to another client
---@param surgeonPl IsoPlayer
---@param args relayExecuteAmputationActionParams
function ServerRelayCommands.RelayExecuteAmputationAction(surgeonPl, args)
    TOC_DEBUG.print("Relaying ExecuteAmputationAction to patient num " .. tostring(args.patientNum) .. " for limb " .. tostring(args.limbName))

    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end

    local AmputationHandler = require("TOC/Handlers/AmputationHandler")
    local handler = AmputationHandler:new(surgeonPl, patientPl, args.limbName)
    handler:execute(true)

    -- ---@type receiveDamageDuringAmputationParams
    -- local params = {surgeonNum = surgeonNum, limbName = args.limbName, damagePlayer = true}
    -- sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveExecuteAmputationAction, params)
end

function ServerRelayCommands.SendCache(player, args)
    local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
    local username = player:getUsername()
    if args.recalculate then
        CachedDataHandler.CalculateCacheableValues(username)
    end

    local cache = CachedDataHandler.GetAll(username)
    TOC_DEBUG.print("Sending cache to client for " .. username)
    sendServerCommand(player, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveCache, {cache = cache})
end

--* ADMIN ONLY *--
---Relay a local init from another client
---@param adminObj IsoPlayer
---@param args relayExecuteInitializationParams
function ServerRelayCommands.RelayExecuteInitialization(adminObj, args)
    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end

    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveExecuteInitialization, {})
end

---Relay a forced amputation to another client.
---@param adminObj IsoPlayer
---@param args relayForcedAmputationParams
function ServerRelayCommands.RelayForcedAmputation(adminObj, args)
    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end

    local AmputationHandler = require("TOC/Handlers/AmputationHandler")
    local handler = AmputationHandler:new(adminObj, patientPl, args.limbName)
    handler:execute(false)

    -- FIX 42.14
    -- Automatic cicatrization
    -- sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveForcedCicatrization, {limbName = args.limbName})
end

function ServerRelayCommands.DeleteAllOldAmputationItems(_, args)
    local playerObj
    if not isServer() then
        playerObj = getPlayer()     -- SP
    else
        playerObj = getPlayerByOnlineID(args.playerNum)
    end

    local ItemsController = require("TOC/Controllers/ItemsController")
    ItemsController.Player.DeleteAllOldAmputationItems(playerObj)
end

-------------------------

local function OnClientRelayCommand(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_RELAY and ServerRelayCommands[command] then
        TOC_DEBUG.print("Received Client Relay command - " .. tostring(command))
        ServerRelayCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientRelayCommand)
