local function OnTocServerCommand(module, command, args)
-- TODO Change name of the func


    if module == 'TOC' then
        print(command)

        if command == 'GivePlayerData' then
            --local surgeon = getPlayerByOnlineID(args[1])
            local surgeon_id = args[1]
            local patient = getPlayer()

            local toc_data = patient:getModData().TOC

            -- todo maybe we cant send a table like this. Let's try something easier
            --local moneyAmount = playerTwo:getInventory():getCountTypeRecurse("Money")
            print("Giving info")
            sendClientCommand(patient, "TOC", "SendPlayerData", {surgeon_id, 69})

        elseif command == 'SendTocData' then
            print("Sending TOC data")
            local patient = getPlayerByOnlineID(args[1])        --todo cant we delete this>?


            -- ew a global var.... but dunno if there's a better way to do this
            MP_other_player_toc_data = args[2]
        end
    end
end




Events.OnServerCommand.Add(OnTocServerCommand)