--- A rly big thx to Fenris_Wolf and Chuck to help me with that. Love you guy
if isClient() then return end



---Server side
local Commands = {}

-- todo what is this?
Commands["SendServer"] = function(player, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    print("The Only Cure Command: ", arg['command'])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)
end

local function OnTocClientCommand(module, command, player, args)

    if module == 'TOC' then
        
        print(command)
        if command == 'GetPlayerData' then
            
            local surgeon_id = args[1]
            local patient_id = args[2]
         


            local playerOne = getPlayerByOnlineID(args[1])
            local playerTwo = getPlayerByOnlineID(args[2])
            local playerOneID = args[1]
            sendServerCommand(playerTwo, "TOC", "GivePlayerData", {surgeon_id, patient_id})
        elseif command == 'SendPlayerData' then
            local playerOne = getPlayerByOnlineID(args[1])
            local playerOneID = args[1]
            local toc_data = args[2]
            sendServerCommand(playerOne, "TOC", "SendTocData", {playerOneID, toc_data})
        end
    end

end

local onClientCommand = function(module, command, player, args)
    if module == 'TOC' and Commands[command] then
        args = args or {}
        Commands[command](_, args)
    end
end
Events.OnClientCommand.Add(OnTocClientCommand)

--Client 1 -> Server -> Client 1