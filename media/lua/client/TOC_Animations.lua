-- Thanks to Glytcher and Matías N. Salas for helping out with this

if TOC_Anims == nil then
    TOC_Anims = {}
end


TOC_Anims.SetMissingFootAnimation = function(check)
    local player = getPlayer()
    player:setVariable("IsCrawling", tostring(check))
    
    if not isServer() and not isClient() then
        print("SP, so it's fine")
    else

        sendClientCommand(player, "TOC", "NotifyNewCrawlAnimation", {id = player:getOnlineID(), check = check})
    end
end

TOC_Anims.CheckAndSetMissingFootAnims = function(modData)

    if modData.TOC.limbs["Left_Foot"].isCut or modData.TOC.limbs["Right_Foot"].isCut then
        TOC_Anims.SetMissingFootAnimation(true)
    end
end