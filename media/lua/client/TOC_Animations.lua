-- Thanks to Glytcher and Matías N. Salas for helping out with this

function SetMissingFootAnimation(check)


    local player = getPlayer()
    player:setVariable("IsCrawling", tostring(check))
    
    if not isServer() and not isClient() then
        print("SP, so it's fine")
    else

        sendClientCommand(player, "TOC", "NotifyNewCrawlAnimation", {id = player:getOnlineID(), check = check})
    end

end


