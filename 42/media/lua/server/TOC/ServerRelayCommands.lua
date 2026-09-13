require ("TOC/Debug")
local CommandsData = require("TOC/CommandsData")
local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
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

    -- limbName is absent on the updateIsIgnoredPartInfectedFromClient path, and
    -- Lua evaluates this concatenation before the call, so a bare `.. args.limbName`
    -- threw here and aborted the whole handler before any field was applied.
    TOC_DEBUG.print("CLIENT SYNC of DC for " .. tostring(args.limbName))
    if args.cicTime then
        h:setCicatrizationTime(args.limbName, args.cicTime)
        TOC_DEBUG.print("CicTime = " .. tostring(args.cicTime))
    end

    if args.dirtyness then
        h:setWoundDirtyness(args.limbName, args.dirtyness)
        TOC_DEBUG.print("Dirtyness = " .. tostring(args.dirtyness))

    end

    -- DRAFT #279: `if args.flag` drops `false`, so a client clearing isInfected
    -- (bite on missing limb healed) never reached the server and the flag stayed
    -- stale. Check for nil instead so both true and false propagate.
    if args.isInfected ~= nil then
        h:setIsInfected(args.limbName, args.isInfected)
        TOC_DEBUG.print("isInfected = " .. tostring(args.isInfected))

    end

    if args.isCauterized ~= nil then
        h:setIsCauterized(args.limbName, args.isCauterized)
        TOC_DEBUG.print("isCauterized = " .. tostring(args.isCauterized))

    end

    if args.isCicatrized ~= nil then
        h:setIsCicatrized(args.limbName, args.isCicatrized)
        TOC_DEBUG.print("iscicatrized = " .. tostring(args.isCicatrized))

    end

    if args.isIgnoredPartInfected ~= nil then
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
    --TOC_DEBUG.print("received Add exp," .. tostring(args.perkName) .. " . " .. tostring(args.xp))
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

--* PROSTHESES *--

---Apply a prosthesis equip/unequip that the owning client reported.
---The client is only allowed to touch its own data, and only a group that already
---exists on it, so the worst a crafted packet can do is toggle a flag it could
---toggle anyway by wearing the item.
---@param playerObj IsoPlayer
---@param args relayProsthesisStateParams
function ServerRelayCommands.RelayProsthesisState(playerObj, args)
    local username = playerObj:getUsername()
    local DataController = require("TOC/Controllers/DataController")
    local dcInst = DataController.GetInstance(username)
    if not dcInst or not dcInst.tocData or not dcInst.tocData.prostheses then return end
    if type(args.group) ~= "string" or dcInst.tocData.prostheses[args.group] == nil then return end

    local isEquipped = args.isEquipped == true
    TOC_DEBUG.print("Prosthesis state from client for " .. username .. " => " .. args.group .. " - " .. tostring(isEquipped))
    dcInst:setIsProstEquipped(args.group, isEquipped)
    dcInst:apply(playerObj)

    if not isEquipped then
        -- ProsthesisHandler triggers OnProsthesisUnequipped from ISUnequipAction:complete,
        -- which is client-side, while its only listener (ItemsController.Player.
        -- DropItemsAfterAmputation) is registered in a server/ file. So in MP the rings
        -- and the held weapon the prosthesis was allowing stayed on. Fire it here, where
        -- the listener actually lives. Harmless if it ends up running twice - the handler
        -- only removes finger/wrist items and clears hand slots.
        local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
        local highestAmputatedLimbs = CachedDataHandler.GetHighestAmputatedLimbs(username)
        if highestAmputatedLimbs then
            local hal = highestAmputatedLimbs[CommonMethods.GetSide(args.group)]
            if hal then
                triggerEvent("OnProsthesisUnequipped", playerObj, hal)
            end
        end
    end
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

---Clear a bite sitting on the requesting player's own already-amputated limb (#279).
---The client detects it (it can only ever see itself); the server validates and
---clears it authoritatively, since client Lua cannot push BodyDamage. Sender is
---implicitly scoped: we only ever touch playerObj's own data, so a crafted packet
---can at most clear the sender's own phantom bites - nothing it couldn't already
---achieve by playing normally.
---@param playerObj IsoPlayer
---@param args requestSanitizeCutLimbParams
function ServerRelayCommands.RequestSanitizeCutLimb(playerObj, args)
    local limbName = args and args.limbName or nil
    if type(limbName) ~= "string" or StaticData.LIMBS_TO_BODYLOCS_IND_BPT[limbName] == nil then
        TOC_DEBUG.print("RequestSanitizeCutLimb rejected: bad limbName from " .. playerObj:getUsername())
        return
    end

    local DataController = require("TOC/Controllers/DataController")
    local dcInst = DataController.GetInstance(playerObj:getUsername())
    if not dcInst or not dcInst:getIsDataReady() then return end
    if not dcInst:getIsCut(limbName) then
        TOC_DEBUG.print("RequestSanitizeCutLimb rejected: limb not cut - " .. limbName)
        return
    end

    TOC_DEBUG.print("RequestSanitizeCutLimb accepted for " .. playerObj:getUsername() .. " - " .. limbName)
    local ServerDamageSanitizer = require("TOC/Controllers/ServerDamageSanitizer")
    local ok, err = pcall(ServerDamageSanitizer.SanitizePlayer, playerObj)
    if not ok then TOC_DEBUG.print("RequestSanitizeCutLimb error: " .. tostring(err)) end
end

---Apply bleeding to the patient's wound server-side, relayed from client perform() in MP
---@param playerObj IsoPlayer sender (validated against patientNum — players can only bleed themselves)
---@param args relayTriggerBleedParams
function ServerRelayCommands.RelayTriggerBleed(playerObj, args)
    if playerObj:getOnlineID() ~= args.patientNum then return end
    local patientPl = CommonMethods.GetPatientForServer(args.patientNum)
    if not patientPl then return end
    local adjacentBodyPartType = BodyPartType[StaticData.LIMBS_ADJACENT_IND_STR[args.limbName]]
    local bp = patientPl:getBodyDamage():getBodyPart(adjacentBodyPartType)
    if bp then
        bp:setBleedingTime(args.bleedingTime)
    end
end

function ServerRelayCommands.DeleteAllOldAmputationItems(_, args)
    local patientPl = CommonMethods.GetPatientForServer(args.patientNum)
    local ItemsController = require("TOC/Controllers/ItemsController")
    ItemsController.Player.DeleteAllOldAmputationItems(patientPl)
end

-------------------------

local function OnClientRelayCommand(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_RELAY and ServerRelayCommands[command] then
        --TOC_DEBUG.print("Received Client Relay command - " .. tostring(command))
        ServerRelayCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientRelayCommand)
