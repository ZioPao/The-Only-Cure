function TocResetEverything()

    local player = getPlayer()
    local mod_data = player:getModData()
    mod_data.TOC = nil
    TheOnlyCure.InitTheOnlyCure(_, player)

    -- Destroy the amputation model
    for _, v in ipairs(GetBodyParts()) do
        local cloth = player:getInventory():FindAndReturn(TocFindAmputatedClothingFromPartName(v))

        if cloth ~= nil then
            print("Resetting " .. cloth:getName())
            player:removeWornItem(cloth)
            player:getInventory():Remove(cloth)
        end
        cloth = nil -- reset it

    end

    player:transmitModData()

end
