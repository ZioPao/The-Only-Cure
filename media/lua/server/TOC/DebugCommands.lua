local CommandsData = require("TOC/CommandsData")
local ServerDataHandler = require("TOC/ServerDataHandler")
----------------------------

local DebugCommands = {}

---comment
---@param playerObj IsoPlayer
---@param args table
function DebugCommands.PrintAllTocData(playerObj, args)
    TOC_DEBUG.printTable(ServerDataHandler.modData)
end

---Print ALL TOC data
---@param playerObj IsoPlayer
---@param args printTocDataParams
function DebugCommands.PrintTocData(playerObj, args)
    local key = CommandsData.GetKey(args.username)
    local tocData = ServerDataHandler.GetTable(key)
    TOC_DEBUG.printTable(tocData)
end

--------------------

local function OnClientDebugCommand(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_DEBUG and DebugCommands[command] then
        DebugCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientDebugCommand)
