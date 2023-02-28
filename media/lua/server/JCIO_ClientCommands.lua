------------------------------------------
------------- JUST CUT IT OFF ------------
------------------------------------------
------------- CLIENT COMMANDS ------------

local ClientCommands = {}


-- Main handler of base functions for JCIO, based on the original work for TOC
ClientCommands.SendServer = function(_, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    sendServerCommand(otherPlayer, "JCIO", arg["command"], arg)

end


-- Cutting Limbs
ClientCommands.AskDamageOtherPlayer = function(_, arg)

    local patient = getPlayerByOnlineID(arg[1])
    local patient_id = arg[1]
    local partName = arg[2]

    sendServerCommand(patient, "JCIO", "AcceptDamageOtherPlayer", {patient_id, partName})

end

ClientCommands.AskStopAmputationSound = function(_, args)

    print("JCIO: We're in AskStopAmputationSound")
    sendServerCommand("JCIO", "StopAmputationSound", {surgeon_id = args.surgeon_id})


end

-- Animations
ClientCommands.NotifyNewCrawlAnimation = function(_, args)

    sendServerCommand("JCIO", "SetCrawlAnimation", {id = args.id, check = args.check})

end




-- Cheats
ClientCommands.AskToResetEverything = function(_, arg)
    local clickedPlayer = getPlayerByOnlineID(arg[1])
    sendServerCommand(clickedPlayer, "JCIO", "ResetEverything", {})
end


-- Global Mod Data data handler
ClientCommands.ChangePlayerState = function(playerObj, args)
    ModData.get("JCIO_PLAYER_DATA")[playerObj:getUsername()] = args
    ModData.transmit("JCIO_PLAYER_DATA")
end


------ Global Mod Data -----------

local function OnInitGlobalModData()
    ModData.getOrCreate("JCIO_PLAYER_DATA")
end

Events.OnInitGlobalModData.Add(OnInitGlobalModData)


------------------------------------------------------

local function OnClientCommand(module, command, playerObj, args)
    if module == 'JCIO' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)


