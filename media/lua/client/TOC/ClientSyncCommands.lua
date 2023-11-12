local CommandsData = require("TOC/CommandsData")
local ClientSyncCommands = {}
local moduleName = CommandsData.modules.TOC_SYNC

------------------------------

---Send the toc mod data to the server to relay it to someone else
---@param args {surgeonNum : number}
function ClientSyncCommands.SendPlayerData(args)
    -- TODO get moddata and send it
    sendClientCommand(moduleName, CommandsData.server.Sync.RelayPlayerData, {surgeonNum = args.surgeonNum, tocData = {}})
end

---Receives and store the toc mod data from another player
---@param args {patientNum : number}
function ClientSyncCommands.ReceivePlayerData(args)
    local patientPl = getSpecificPlayer(args.patientNum)
    local patientUsername patientPl:getUsername()


    -- TODO Save the data somewhere that makes sense.
end

------------------------------

local function OnServerSyncCommand(module, command, args)
    if module == moduleName and ClientSyncCommands[command] then
        args = args or {}
        ClientSyncCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerSyncCommand)
