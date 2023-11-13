local CommandsData = require("TOC/CommandsData")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
--------------------------------------------

local ClientRelayCommands = {}

---comment
---@param limbName any
---@param surgeonNum any
---@return AmputationHandler
local function InitAmputationHandler(limbName, surgeonNum)

    -- TODO Pretty unclean
    local surgeonPl = getSpecificPlayer(surgeonNum)
    local handler = AmputationHandler:new(limbName, surgeonPl)
    return handler
end

---Receive the damage from another player during the amputation
---@param args receiveDamageDuringAmputationParams
function ClientRelayCommands.ReceiveDamageDuringAmputation(args)
    AmputationHandler.ApplyDamageDuringAmputation(getPlayer(), args.limbName)
end

---Creates a new handler and execute the amputation function on this client
---@param args receiveExecuteAmputationActionParams
function ClientRelayCommands.ReceiveExecuteAmputationAction(args)
    local handler = InitAmputationHandler(args.limbName, args.surgeonNum)
    handler:execute(true)
end
-------------------------

local function OnServerRelayCommand(module, command, args)
    if module == CommandsData.modules.TOC_RELAY and ClientRelayCommands[command] then
        TOC_DEBUG.print("Received Server Relay command - " .. tostring(command))
        ClientRelayCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerRelayCommand)
