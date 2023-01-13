function ResetEverything()

    local player = getPlayer()
    local mod_data = player:getModData()        -- TODO we need to send data...
    mod_data.TOC = nil
    TheOnlyCure.InitTheOnlyCure(_, player)

    -- Destroy the amputation model

    for _,v in ipairs(GetBodyParts()) do
        local cloth = player:getInventory():FindAndReturn(find_clothName2_TOC(v))

        if cloth ~= nil then
            player:removeWornItem(cloth)
            player:getInventory():Remove(cloth:getName())
        end

    end

    player:transmitModData()

end
