

local ClientCommands = {}


-- Main handler of base functions for TOC, not changed till now 'cause it works
ClientCommands.SendServer = function(player, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)

end


-- Cutting Limbs
ClientCommands.AskDamageOtherPlayer = function(_, arg)

    local patient = getPlayerByOnlineID(arg[1])
    local patient_id = arg[1]
    local part_name = arg[2]

    sendServerCommand(patient, "TOC", "AcceptDamageOtherPlayer", {patient_id, part_name})

end

ClientCommands.AskStopAmputationSound = function(_, args)

    print("TOC: We're in AskStopAmputationSound")
    sendServerCommand("TOC", "StopAmputationSound", {surgeon_id = args.surgeon_id})


end

-- Animations
ClientCommands.NotifyNewCrawlAnimation = function(player, args)

    sendServerCommand("TOC", "SetCrawlAnimation", {id = args.id, check = args.check})

end




-- Cheats
ClientCommands.AskToResetEverything = function(_, arg)
    local clicked_player = getPlayerByOnlineID(arg[1])
    sendServerCommand(clicked_player, "TOC", "ResetEverything", {})
end


-- Global Mod Data data handler
ClientCommands.ChangePlayerState = function(playerObj, args)
    ModData.get("TOC_PLAYER_DATA")[playerObj:getUsername()] = args
    ModData.transmit("TOC_PLAYER_DATA")
end


------ Global Mod Data -----------

function TOC_OnInitGlobalModData()
    ModData.getOrCreate("TOC_PLAYER_DATA")
end

Events.OnInitGlobalModData.Add(TOC_OnInitGlobalModData)


------------------------------------------------------

local function OnClientCommand(module, command, playerObj, args)
    if module == 'TOC' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)


