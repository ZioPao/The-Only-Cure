local CommandsData = require("TOC/CommandsData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")

local ClientSyncCommands = {}
local moduleName = CommandsData.modules.TOC_SYNC

------------------------------

---Send the toc mod data to the server to relay it to someone else
---@param args sendPlayerDataParams
function ClientSyncCommands.SendPlayerData(args)
    -- TODO get moddata and send it

    ---@type relayPlayerDataParams
    local params = {surgeonNum = args.surgeonNum, tocData = {}}
    sendClientCommand(moduleName, CommandsData.server.Sync.RelayPlayerData, params)
end

---Receives and store the toc mod data from another player
---@param args receivePlayerDataParams
function ClientSyncCommands.ReceivePlayerData(args)
    local patientPl = getSpecificPlayer(args.patientNum)
    local patientUsername patientPl:getUsername()
    ModDataHandler.AddExternalTocData(patientUsername, args.tocData)
end

------------------------------

local function OnServerSyncCommand(module, command, args)
    if module == moduleName and ClientSyncCommands[command] then
        args = args or {}
        ClientSyncCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerSyncCommand)
