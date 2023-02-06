local function addBodyLocationBefore(new_location, move_to_location)
  -- FIXME This doesn't really move a body location, it just re-adds it to another index. Find a way to remove it entirely (maybe setExclusive?)

  local group = BodyLocations.getGroup("Human")
  local list = getClassFieldVal(group, getClassField(group, 1))
  group:getOrCreateLocation(new_location)
  local newItem = list:get(list:size()-1)
  print("TOC: Created new body location" .. newItem:getId())

  list:remove(newItem)      -- We can't use the Index, it works if we pass the item though!
  local i = group:indexOf(move_to_location)
  list:add(i, newItem)
end



addBodyLocationBefore("TOC_ArmRight", "Shoes")
addBodyLocationBefore("TOC_ArmLeft", "Shoes")
addBodyLocationBefore("TOC_ArmRightProsthesis", "Shoes")
addBodyLocationBefore("TOC_ArmLeftProsthesis", "Shoes")
