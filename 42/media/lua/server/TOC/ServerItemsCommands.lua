require ("TOC/Debug")
local CommandsData = require("TOC/CommandsData")
local ItemsController = require("TOC/Controllers/ItemsController")

--------------------------------------------

local ServerItemsCommands = {}

function ServerItemsCommands.SpawnAmputationItem(_, args)
    local playerObj = getPlayerByOnlineID(args.playerNum)
    local limbName = args.limbName
    ItemsController.Player.SpawnAmputationItem(playerObj, limbName)
end

function ServerItemsCommands.DeleteOldAmputationItem(_, args)
    local patientPl = getPlayerByOnlineID(args.playerNum)
    local limbName = args.limbName

    ItemsController.Player.DeleteOldAmputationItem(patientPl, limbName)
end

function ServerItemsCommands.DeleteAllOldAmputationItems(_, args)
    local playerObj = getPlayerByOnlineID(args.playerNum)
    ItemsController.Player.DeleteAllOldAmputationItems(playerObj)
end

function ServerItemsCommands.OverrideAmputationItemVisuals(_, args)
    local playerObj = getPlayerByOnlineID(args.playerNum)
    local limbName = args.limbName
    local isCicatrized = args.isCicatrized

    ItemsController.Player.OverrideAmputationItemVisuals(playerObj, limbName, isCicatrized)
end


--------------------------------------------------------------------
local function OnClientItemsCommands(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_ITEMS and ServerItemsCommands[command] then
        TOC_DEBUG.print("Received ItemsController command - " .. tostring(command))
        ServerItemsCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientItemsCommands)
