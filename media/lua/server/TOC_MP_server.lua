--- A rly big thx to Fenris_Wolf and Chuck to help me with that. Love you guy

---Server side
local Commands = {}

Commands["SendServer"] = function(player, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    print("The Only Cure Command: ", arg['command'])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)
end

local onClientCommand = function(module, command, player, args)
    if module == 'TOC' and Commands[command] then
        args = args or {}
        Commands[command](_, args)
    end
end
Events.OnClientCommand.Add(onClientCommand)