--- A rly big thx to Fenris_Wolf and Chuck to help me with that. Love you guy


---Server side
local TOC_Commands = {}


TOC_Commands["SendServer"] = function(player, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)
end



-- Cut Limb stuff
TOC_Commands["AskDamageOtherPlayer"] = function(_, arg)

    local patient = getPlayerByOnlineID(arg[1])
    local patient_id = arg[1]
    local part_name = arg[2]

    sendServerCommand(patient, "TOC", "AcceptDamageOtherPlayer", {patient_id, part_name})

end






-- CHEATING STUFF
TOC_Commands["AskToResetEverything"] = function(_, arg)
    local clicked_player = getPlayerByOnlineID(arg[1])
    local clicked_player_id = arg[1]


    sendServerCommand(clicked_player, "TOC", "AcceptResetEverything", { clicked_player_id })

end

TOC_Commands.AskStopAmputationSound = function(_, args)

    print("TOC: We're in AskStopAmputationSound")
    sendServerCommand("TOC", "StopAmputationSound", {surgeon_id = args.surgeon_id})


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