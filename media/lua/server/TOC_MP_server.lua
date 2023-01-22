--- A rly big thx to Fenris_Wolf and Chuck to help me with that. Love you guy
--if isClient() then return end

---Server side
local Commands = {}


--TODO how does this work
Commands["SendServer"] = function(player, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    print("The Only Cure Command: ", arg['command'])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)
end


-- To make the UI Work
Commands["GetPlayerData"] = function(_, arg)
    local surgeon_id = arg[1]
    local patient_id = arg[2]
    local patient = getPlayerByOnlineID(arg[2])
    sendServerCommand(patient, "TOC", "GivePlayerData", { surgeon_id, patient_id })
end

Commands["SendPlayerData"] = function(_, arg)
    local surgeon = getPlayerByOnlineID(arg[1])
    local surgeon_id = arg[1]
    local toc_data = arg[2]
    sendServerCommand(surgeon, "TOC", "SendTocData", { surgeon_id, toc_data })
end



-- CHEATING STUFF
Commands["AskToResetEverything"] = function(_, arg)
    local clicked_player = getPlayerByOnlineID(arg[1])
    local clicked_player_id = arg[1]


    sendServerCommand(clicked_player, "TOC", "AcceptResetEverything", { clicked_player_id })

end

local function OnTocClientCommand(module, command, player, args)
    if module == 'TOC' then
        print("OnTocClientCommand " .. command)
        if Commands[command] then
            args = args or {}
            Commands[command](_, args)
        end
    end

end

Events.OnClientCommand.Add(OnTocClientCommand)
