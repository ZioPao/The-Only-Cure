local CommandsData = require("TOC/CommandsData")
--------------------------------------------

local ServerRelayCommands = {}

-- TODO We can easily make this a lot more simple without having functions 

---comment
---@param surgeonPl IsoPlayer
---@param args relayDamageDuringAmputationParams
function ServerRelayCommands.RelayDamageDuringAmputation(surgeonPl, args)
    local patientPl = getSpecificPlayer(args.patientNum)
    local surgeonNum = surgeonPl:getOnlineID()

    ---@type receiveDamageDuringAmputationParams
    local params = {surgeonNum = surgeonNum, args.limbName}
    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveDamageDuringAmputation, params)
end

---comment
---@param surgeonPl IsoPlayer
---@param args relayExecuteAmputationActionParams
function ServerRelayCommands.RelayExecuteAmputationAction(surgeonPl, args)
    local patientPl = getSpecificPlayer(args.patientNum)
    local surgeonNum = surgeonPl:getOnlineID()

    ---@type receiveDamageDuringAmputationParams
    local params = {surgeonNum = surgeonNum, args.limbName}
    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveExecuteAmputationAction, params)
end



-------------------------

local function OnClientRelayCommand(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_ACTION and ServerRelayCommands[command] then
        ServerRelayCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientRelayCommand)
