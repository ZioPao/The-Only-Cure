------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
------------- CLIENT COMMANDS ------------

local ClientCommands = {}


-- Main handler of base functions for TOC, based on the original work for TOC
ClientCommands.SendServer = function(_, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)

end


-- Cutting Limbs
ClientCommands.AskDamageOtherPlayer = function(_, arg)

    local patient = getPlayerByOnlineID(arg[1])
    local patient_id = arg[1]
    local partName = arg[2]

    sendServerCommand(patient, "TOC", "AcceptDamageOtherPlayer", {patient_id, partName})

end

ClientCommands.AskStopAmputationSound = function(_, args)

    print("TOC: We're in AskStopAmputationSound")
    sendServerCommand("TOC", "StopAmputationSound", {surgeon_id = args.surgeonID})


end

-- Animations
ClientCommands.NotifyNewCrawlAnimation = function(_, args)

    sendServerCommand("TOC", "SetCrawlAnimation", {id = args.id, check = args.check})

end




-- Cheats
ClientCommands.AskToResetEverything = function(_, arg)
    local clickedPlayer = getPlayerByOnlineID(arg[1])
    sendServerCommand(clickedPlayer, "TOC", "ResetEverything", {})
end


-- Global Mod Data data handler
ClientCommands.ChangePlayerState = function(playerObj, args)
    ModData.get("TOC_PLAYER_DATA")[playerObj:getUsername()] = args
    ModData.transmit("TOC_PLAYER_DATA")
end


------ Global Mod Data -----------

local function OnInitGlobalModData()
    ModData.getOrCreate("TOC_PLAYER_DATA")
end

Events.OnInitGlobalModData.Add(OnInitGlobalModData)


------------------------------------------------------

local function OnClientCommand(module, command, playerObj, args)
    if module == 'TOC' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)


