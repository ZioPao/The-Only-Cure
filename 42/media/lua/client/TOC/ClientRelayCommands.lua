local CommandsData = require("TOC/CommandsData")
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local DataController = require("TOC/Controllers/DataController")
--------------------------------------------

local ClientRelayCommands = {}

---Initialize Amputation Handler
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

    -- Check if player already doesn't have that limb or it's a dependant limb.
    -- Mostly a check for admin forced amputations more than anything else, since this case is handled in the GUI already.
    local dcInst = DataController.GetInstance()
    if dcInst:getIsCut(args.limbName) then return end

    local handler = InitAmputationHandler(args.limbName, args.surgeonNum)
    handler:execute(args.damagePlayer)
end


--* APPLY RELAY *--

function ClientRelayCommands.ReceiveApplyFromServer()
    TOC_DEBUG.print("Received forced re-apply from server")
    local key = CommandsData.GetKey(getPlayer():getUsername())
    ModData.request(key)
end


--* TRIGGERED BY ADMINS *--

function ClientRelayCommands.ReceiveExecuteInitialization()
    local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
    LocalPlayerController.InitializePlayer(true)
end

---Creates a new handler and execute the amputation function on this client
---@param args receiveForcedCicatrizationParams
function ClientRelayCommands.ReceiveForcedCicatrization(args)
    local dcInst = DataController.GetInstance()
    --dcInst:setCicatrizationTime(args.limbName, 1)
    dcInst:setIsCicatrized(args.limbName, true)
    dcInst:apply()
end

-------------------------

local function OnServerRelayCommand(module, command, args)
    if module == CommandsData.modules.TOC_RELAY and ClientRelayCommands[command] then
        TOC_DEBUG.print("Received Server Relay command - " .. tostring(command))
        ClientRelayCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerRelayCommand)

-- TODO temporary
return ClientRelayCommands