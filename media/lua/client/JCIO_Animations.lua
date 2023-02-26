-- Thanks to Glytcher and Matías N. Salas for helping out with this

if JCIO_Anims == nil then
    JCIO_Anims = {}
end


JCIO_Anims.SetMissingFootAnimation = function(check)
    local player = getPlayer()
    player:setVariable("IsCrawling", tostring(check))
    
    if not isServer() and not isClient() then
        print("SP, so it's fine")
    else

        sendClientCommand(player, "TOC", "NotifyNewCrawlAnimation", {id = player:getOnlineID(), check = check})
    end
end

JCIO_Anims.CheckAndSetMissingFootAnims = function(modData)

    if modData.JCIO.limbs["Left_Foot"].isCut or modData.JCIO.limbs["Right_Foot"].isCut then
        JCIO_Anims.SetMissingFootAnimation(true)
    end
end