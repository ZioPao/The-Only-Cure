require ("TOC/Debug")
local CommandsData = require("TOC/CommandsData")
local ItemsController = require("TOC/Controllers/ItemsController")

--------------------------------------------

local ServerItemsCommands = {}

function ServerItemsCommands.SpawnAmputationItem(_, args)
    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end
    local limbName = args.limbName
    ItemsController.Player.SpawnAmputationItem(patientPl, limbName)
end

function ServerItemsCommands.DeleteOldAmputationItem(_, args)
    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end
    local limbName = args.limbName

    ItemsController.Player.DeleteOldAmputationItem(patientPl, limbName)
end

function ServerItemsCommands.DeleteAllOldAmputationItems(_, args)
    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end
    ItemsController.Player.DeleteAllOldAmputationItems(patientPl)
end

function ServerItemsCommands.OverrideAmputationItemVisuals(_, args)
    local patientPl
    if not isServer() then
        patientPl = getPlayer()     -- SP
    else
        patientPl = getPlayerByOnlineID(args.patientNum)
    end
    local limbName = args.limbName
    local isCicatrized = args.isCicatrized

    ItemsController.Player.OverrideAmputationItemVisuals(patientPl, limbName, isCicatrized)
end


--------------------------------------------------------------------
local function OnClientItemsCommands(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_ITEMS and ServerItemsCommands[command] then
        TOC_DEBUG.print("Received ItemsController command - " .. tostring(command))
        ServerItemsCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientItemsCommands)
