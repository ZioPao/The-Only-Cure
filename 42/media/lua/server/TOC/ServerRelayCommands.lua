require ("TOC/Debug")
local CommandsData = require("TOC/CommandsData")
local CommonMethods = require("TOC/CommonMethods")
--------------------------------------------

local ServerRelayCommands = {}

-- TODO We can easily make this a lot more simple without having functions 

--* DATA CONTROLLER
function ServerRelayCommands.RelayRequestDataController(playerObj, args)
    local ServerDataController = require("TOC/Controllers/ServerDataController")
    ServerDataController.Initialize(args.username, args.isForced, playerObj)
end

---Used to update data from client in a cautious way
---@param playerObj IsoPlayer
---@param args table
function ServerRelayCommands.UpdateDataControllerFromClient(playerObj, args)
    local DataController = require("TOC/Controllers/DataController")
    local h = DataController.GetInstance(playerObj:getUsername())

    TOC_DEBUG.print("CLIENT SYNC of DC for " .. args.limbName)
    if args.cicTime then
        h:setCicatrizationTime(args.limbName, args.cicTime)
        TOC_DEBUG.print("CicTime = " .. tostring(args.cicTime))
    end

    if args.dirtyness then
        h:setWoundDirtyness(args.limbName, args.dirtyness)
        TOC_DEBUG.print("Dirtyness = " .. tostring(args.dirtyness))

    end

    if args.isInfected then
        h:setIsInfected(args.limbName, args.isInfected)
        TOC_DEBUG.print("isInfected = " .. tostring(args.isInfected))

    end

    if args.isCauterized then
        h:setIsCauterized(args.limbName, args.isCauterized)
        TOC_DEBUG.print("isCauterized = " .. tostring(args.isCauterized))

    end

    if args.isCicatrized then
        h:setIsCicatrized(args.limbName, args.isCicatrized)
        TOC_DEBUG.print("iscicatrized = " .. tostring(args.isCicatrized))

    end

    if args.isIgnoredPartInfected then
        h:setIsIgnoredPartInfected(args.isIgnoredPartInfected)
        TOC_DEBUG.print("isignoredpartinfected = " .. tostring(args.isIgnoredPartInfected))

    end

end


--* AMPUTATION

---Relay DamageDuringAmputation to another client
---@param args relayDamageDuringAmputationParams
function ServerRelayCommands.RelayDamageDuringAmputation(_, args)
    local patientPl = CommonMethods.GetPatientForServer(args.patientNum)
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
    local patientPl = CommonMethods.GetPatientForServer(args.patientNum)

    local AmputationHandler = require("TOC/Handlers/AmputationHandler")
    local handler = AmputationHandler:new(surgeonPl, patientPl, args.limbName)
    handler:execute(true)
end

--* XP

---@param playerObj IsoPlayer
---@param args {perkName : string, xp : number}
function ServerRelayCommands.RelayAddXp(playerObj, args)
    TOC_DEBUG.print("received Add exp," .. tostring(args.perkName) .. " . " .. tostring(args.xp))
    addXp(playerObj, Perks[args.perkName], args.xp)
end

--* TRAITS *--

---Apply a trait amputation for the requesting player (surgeon = patient, no damage, pre-cicatrized)
---@param playerObj IsoPlayer
---@param args relayApplyTraitAmputationParams
function ServerRelayCommands.RelayApplyTraitAmputation(playerObj, args)
    local DataController = require("TOC/Controllers/DataController")
    local dcInst = DataController.GetInstance(playerObj:getUsername())
    if dcInst:getIsCut(args.limbName) then return end  -- already applied on a previous login

    TOC_DEBUG.print("Applying trait amputation for " .. playerObj:getUsername() .. " - " .. args.limbName)
    local AmputationHandler = require("TOC/Handlers/AmputationHandler")
    local handler = AmputationHandler:new(playerObj, playerObj, args.limbName)
    handler:execute(false)  -- no damage

    dcInst:setCicatrizationTime(args.limbName, 0)
    dcInst:setIsCicatrized(args.limbName, true)
    dcInst:apply(playerObj)
end

--* ADMIN ONLY *--
---Relay a local init from another client
---@param adminObj IsoPlayer
---@param args relayExecuteInitializationParams
function ServerRelayCommands.RelayExecuteInitialization(adminObj, args)
    local patientPl = CommonMethods.GetPatientForServer(args.patientNum)

    -- Deletes data from ModData
    local key = CommandsData.GetKey(patientPl:getUsername())
    ModData.remove(key)

    sendServerCommand(patientPl, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveExecuteInitialization, {})
end

---Relay a forced amputation to another client.
---@param adminObj IsoPlayer
---@param args relayForcedAmputationParams
function ServerRelayCommands.RelayForcedAmputation(adminObj, args)
    local patientPl = CommonMethods.GetPatientForServer(args.patientNum)
    local AmputationHandler = require("TOC/Handlers/AmputationHandler")
    local handler = AmputationHandler:new(adminObj, patientPl, args.limbName)
    handler:execute(false)

    -- Janky, but since this is an admin option we don't really care about optimizing it
    local DataController = require("TOC/Controllers/DataController")
    local h = DataController.GetInstance(patientPl:getUsername())
    h:setCicatrizationTime(args.limbName, 0)        -- for color of cicatrization in health panel
    h:setIsCicatrized(args.limbName, true)
    h:apply(patientPl)
end

function ServerRelayCommands.DeleteAllOldAmputationItems(_, args)
    local patientPl = CommonMethods.GetPatientForServer(args.patientNum)
    local ItemsController = require("TOC/Controllers/ItemsController")
    ItemsController.Player.DeleteAllOldAmputationItems(patientPl)
end

-------------------------

local function OnClientRelayCommand(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_RELAY and ServerRelayCommands[command] then
        TOC_DEBUG.print("Received Client Relay command - " .. tostring(command))
        ServerRelayCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientRelayCommand)
