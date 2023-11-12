local CommandsData = require("TOC/CommandsData")

local DebugCommands = {}



---comment
---@param playerObj IsoPlayer
---@param args {username : string}
function DebugCommands.PrintTocData(playerObj, args)
    local data = ModData.get(CommandsData.GetKey(args.username))
    TOC_DEBUG.printTable(data)
end

--------------------

local function OnClientDebugCommand(module, command, playerObj, args)
    if module == CommandsData.modules.TOC_DEBUG and DebugCommands[command] then
        DebugCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientDebugCommand)
