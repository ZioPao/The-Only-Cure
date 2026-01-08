require ("TOC/Debug")
local CommandsData = require("TOC/CommandsData")
--------------------------------------------

local ServerRelayCommands = {}

-- TODO We can easily make this a lot more simple without having functions 

---Relay DamageDuringAmputation to another client
---@param args relayDamageDuringAmputationParams
function ServerRelayCommands.RelayDamageDuringAmputation(_, args)
    local patientPl = getPlayerByOnlineID(args.patientNum)

    ---@type receiveDamageDuringAmputationParams
    local params = {limbName = args.limbName}
    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveDamageDuringAmputation, params)
end

---Relay ExecuteAmputationAction to another client
---@param surgeonPl IsoPlayer
---@param args relayExecuteAmputationActionParams
function ServerRelayCommands.RelayExecuteAmputationAction(surgeonPl, args)
    local patientPl = getPlayerByOnlineID(args.patientNum)
    local surgeonNum = surgeonPl:getOnlineID()

    ---@type receiveDamageDuringAmputationParams
    local params = {surgeonNum = surgeonNum, limbName = args.limbName, damagePlayer = true}
    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveExecuteAmputationAction, params)
end

--* ADMIN ONLY *--
---Relay a local init from another client
---@param adminObj IsoPlayer
---@param args relayExecuteInitializationParams
function ServerRelayCommands.RelayExecuteInitialization(adminObj, args)
    local patientPl = getPlayerByOnlineID(args.patientNum)
    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveExecuteInitialization, {})

end

---Relay a forced amputation to another client.
---@param adminObj IsoPlayer
---@param args relayForcedAmputationParams
function ServerRelayCommands.RelayForcedAmputation(adminObj, args)
    local patientPl = getPlayerByOnlineID(args.patientNum)
    local adminNum = adminObj:getOnlineID()

    ---@type receiveDamageDuringAmputationParams
    local ampParams = {surgeonNum = adminNum, limbName = args.limbName, damagePlayer = false}        -- the only difference between relayExecuteAmputationAction and this is the damage
    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveExecuteAmputationAction, ampParams)

    -- Automatic cicatrization
    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveForcedCicatrization, {limbName = args.limbName})
end



-------------------------

local function OnClientRelayCommand(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_RELAY and ServerRelayCommands[command] then
        TOC_DEBUG.print("Received Client Relay command - " .. tostring(command))
        ServerRelayCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientRelayCommand)
