local CommandsData = require("TOC/CommandsData")
local ServerSyncCommands = {}
local moduleName = CommandsData.modules.TOC_SYNC

------------------------------


-- TODO This is gonna be impossible to manage. We need Global Mod Data to keep track of this kind of stuff at this point


---A client has asked the server to ask another client to send its toc mod data
---@param surgeonPl IsoPlayer
---@param args askPlayerDataParams
function ServerSyncCommands.AskPlayerData(surgeonPl, args)
    local patientPl = getSpecificPlayer(args.patientNum)

    ---@type sendPlayerDataParams
    local params = {surgeonNum = surgeonPl:getOnlineID()}
    sendServerCommand(patientPl, moduleName, CommandsData.client.Sync.SendPlayerData, params)
end

---Relay the toc mod data from a certain player to another one
---@param patientPl IsoPlayer
---@param args relayPlayerDataParams
function ServerSyncCommands.RelayPlayerData(patientPl, args)
    local surgeonPl = getSpecificPlayer(args.surgeonNum)
    local patientNum = patientPl:getOnlineID()

    ---@type receivePlayerDataParams
    local params = {patientNum = patientNum, tocData = args.tocData}
    sendServerCommand(surgeonPl, moduleName, CommandsData.client.Sync.ReceivePlayerData, params)
end

------------------------------

local function OnClientSyncCommand(module, command, playerObj, args)
    if module == moduleName and ServerSyncCommands[command] then
        ServerSyncCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientSyncCommand)
