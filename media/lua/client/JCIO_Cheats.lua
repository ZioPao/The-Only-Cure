------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
---------------- CHEATS  -----------------


if TOC_Cheat == nil then
    TOC_Cheat = {}
end


TOC_Cheat.ResetEverything = function()
    -- This has to be run on the local player to be sure that we're correctly reassigning everything
    local player = getPlayer()
    local playerInv = player:getInventory()
    local modData = player:getModData()
    modData.TOC = nil

    -- Removes traits just to be sure
    local customTraits = player:getTraits()
    customTraits:remove("Amputee_Hand")
    customTraits:remove("Amputee_LowerArm")
    customTraits:remove("Amputee_UpperArm")


    TOC.Init(_, player)

    -- Destroy the amputation or prosthesis item
    for _, partName in pairs(TOC_Common.GetPartNames()) do
        local amputationItemName = TOC_Common.FindAmputationOrProsthesisName(partName, player, "Amputation")
        local prostItemName = TOC_Common.FindAmputationOrProsthesisName(partName, player, "Prosthesis")
        if amputationItemName ~= nil then
            local amputationItem = playerInv:FindAndReturn(amputationItemName)
            if amputationItem ~= nil then
                print("Resetting " .. amputationItem:getName())
                player:removeWornItem(amputationItem)
                player:getInventory():Remove(amputationItem)
            end
            amputationItem = nil -- reset it
        end
        if prostItemName ~= nil then
            local prostItem = playerInv:FindAndReturn(prostItemName)
            if prostItem ~= nil then
                print("Resetting " .. prostItem:getName())
                player:removeWornItem(prostItem)
                player:getInventory():Remove(prostItem)
            end
            prostItem = nil -- reset it
        end
    end



    -- Reset special flag for legs amputations
    TOC_Anims.SetMissingFootAnimation(false)

end