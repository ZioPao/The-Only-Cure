local function addBodyLocationBefore(new_location, move_to_location)
  local group = BodyLocations.getGroup("Human")
  local list = getClassFieldVal(group, getClassField(group, 1))
  group:getOrCreateLocation(new_location)
  local new_item = list:get(list:size()-1)
  print("TOC: Created new body location" .. new_item:getId())
  list:remove(new_item)   -- We can't use the Index, it works if we pass the item though!
  local i = group:indexOf(move_to_location)
  list:add(i, new_item)
end


addBodyLocationBefore("TOC_ArmRight", "Shoes")
addBodyLocationBefore("TOC_ArmLeft", "Shoes")

addBodyLocationBefore("TOC_LegRight", "Shoes")
addBodyLocationBefore("TOC_LegLeft", "Shoes")

addBodyLocationBefore("TOC_ArmRightProsthesis", "Shoes")
addBodyLocationBefore("TOC_ArmLeftProsthesis", "Shoes")

addBodyLocationBefore("TOC_LegRightProsthesis", "Shoes")
addBodyLocationBefore("TOC_LegLeftProsthesis", "Shoes")
