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

---comment
---@param args receiveDamageDuringAmputationParams
function ClientRelayCommands.ReceiveDamageDuringAmputation(args)
    local handler = InitAmputationHandler(args.limbName, args.surgeonNum)
    handler:damageDuringAmputation()
end

---@param args receiveExecuteAmputationActionParams
function ClientRelayCommands.ReceiveExecuteAmputationAction(args)
    local handler = InitAmputationHandler(args.limbName, args.surgeonNum)
    handler:execute(true)
end
-------------------------

local function OnServerRelayCommand(module, command, args)
    if module == CommandsData.modules.TOC_ACTION and ClientRelayCommands[command] then
        ClientRelayCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerRelayCommand)
