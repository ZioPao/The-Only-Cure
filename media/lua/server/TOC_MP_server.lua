--- A rly big thx to Fenris_Wolf and Chuck to help me with that. Love you guy


---Server side
local TOC_Commands = {}


--TODO how does this work
TOC_Commands["SendServer"] = function(player, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    print("The Only Cure Command: ", arg['command'])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)
end


-- To make the UI Work
TOC_Commands["GetPlayerData"] = function(_, arg)
    local surgeon_id = arg[1]
    local patient_id = arg[2]
    local patient = getPlayerByOnlineID(arg[2])
    sendServerCommand(patient, "TOC", "GivePlayerData", { surgeon_id, patient_id })
end

TOC_Commands["SendPlayerData"] = function(_, arg)
    local surgeon = getPlayerByOnlineID(arg[1])
    local surgeon_id = arg[1]
    local toc_data = arg[2]
    sendServerCommand(surgeon, "TOC", "SendTocData", { surgeon_id, toc_data })
end



-- CHEATING STUFF
TOC_Commands["AskToResetEverything"] = function(_, arg)
    local clicked_player = getPlayerByOnlineID(arg[1])
    local clicked_player_id = arg[1]


    sendServerCommand(clicked_player, "TOC", "AcceptResetEverything", { clicked_player_id })

end

------ Global Mod Data -----------

function TOC_OnInitGlobalModData()
    ModData.getOrCreate("TOC_PLAYER_DATA")
end

Events.OnInitGlobalModData.Add(TOC_OnInitGlobalModData)

TOC_Commands.OnClientCommand = function(module, command, playerObj, args)
    if module == 'TOC' and TOC_Commands[command] then
        TOC_Commands[command](playerObj, args)
    end
end


Events.OnClientCommand.Add(TOC_Commands.OnClientCommand)


TOC_Commands.ChangePlayerState = function(playerObj, args)
    ModData.get("TOC_PLAYER_DATA")[playerObj:getUsername()] = args
    ModData.transmit("TOC_PLAYER_DATA")
end