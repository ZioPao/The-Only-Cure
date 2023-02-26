-- Thanks to Glytcher and Matías N. Salas for helping out with this

if JCIOAnims == nil then
    JCIOAnims = {}
end


JCIOAnims.SetMissingFootAnimation = function(check)
    local player = getPlayer()
    player:setVariable("IsCrawling", tostring(check))
    
    if not isServer() and not isClient() then
        print("SP, so it's fine")
    else

        sendClientCommand(player, "TOC", "NotifyNewCrawlAnimation", {id = player:getOnlineID(), check = check})
    end
end

JCIOAnims.CheckAndSetMissingFootAnims = function(modData)

    if modData.JCIO.limbs["Left_Foot"].isCut or modData.JCIO.limbs["Right_Foot"].isCut then
        JCIOAnims.SetMissingFootAnimation(true)
    end
end