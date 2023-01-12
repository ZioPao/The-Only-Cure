

function GetKitInInventory(surgeon)
    local playerInv = surgeon:getInventory();
    local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
    return item

end

function IsSawInInventory(surgeon)
    local playerInv = surgeon:getInventory()
    local item = playerInv:getItemFromType('Saw') or playerInv:getItemFromType('GardenSaw') or playerInv:getItemFromType('Chainsaw')
    return item
end