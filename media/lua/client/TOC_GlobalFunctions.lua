



function GetKitInInventory(surgeon)
    local playerInv = surgeon:getInventory();
    local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
    return item

end


function GetSawInInventory(surgeon)

    local player_inv = surgeon:getInventory()
    local item = player_inv:getItemFromType("Saw") or player_inv:getItemFromType("GardenSaw") or player_inv:getItemFromType("Chainsaw")
    return item
end
