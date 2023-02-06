-- Thanks to Glytcher and Matías N. Salas for helping out with this





function SetMissingFootAnimation(check)


    local player = getPlayer()

    if check then
        player:setVariable("IsCrawling", "true")
    else
        player:setVariable("IsCrawling", "false")
    end
    
    -- if isClient() then
    --     sendClientCommand("TOC", "SetCrawlAnimation", {})
    -- end

end


