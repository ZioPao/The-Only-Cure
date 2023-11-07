-- TODO This part is still one of the weakest and we don't have a better solution yet

local function AddBodyLocationBefore(newLocation, moveToLocation)
    local group = BodyLocations.getGroup("Human")
    local list = getClassFieldVal(group, getClassField(group, 1))
    group:getOrCreateLocation(newLocation)
    local newItem = list:get(list:size()-1)
    print("TOC: Created new body location" .. newItem:getId())
    list:remove(newItem)   -- We can't use the Index, it works if we pass the item though!
    local i = group:indexOf(moveToLocation)
    list:add(i, newItem)
end


AddBodyLocationBefore("TOC_ArmRight", "Shoes")
AddBodyLocationBefore("TOC_ArmLeft", "Shoes")
