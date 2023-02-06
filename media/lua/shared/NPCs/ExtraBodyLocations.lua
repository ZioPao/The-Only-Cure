local function addBodyLocationBefore(newLocation, movetoLocation)
  -- FIXME This doesn't really move a body location, it just re-adds it to another index. Find a way to remove it entirely (maybe setExclusive?)

  local group = BodyLocations.getGroup("Human")
  local list = getClassFieldVal(group, getClassField(group, 1))
  group:getOrCreateLocation(newLocation)
  local newItem = list:get(list:size()-1)
  print("TOC: Created new body location" .. newItem:getId())

  list:remove(list:size()-1)
  local i = group:indexOf(movetoLocation)
  list:add(i, newItem)
end



addBodyLocationBefore("TOC_ArmRight", "Shoes")
addBodyLocationBefore("TOC_ArmLeft", "Shoes")
addBodyLocationBefore("TOC_ArmRightProsthesis", "Shoes")
addBodyLocationBefore("TOC_ArmLeftProsthesis", "Shoes")
