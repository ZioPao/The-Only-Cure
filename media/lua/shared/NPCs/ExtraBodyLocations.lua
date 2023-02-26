local function AddBodyLocationBefore(new_location, move_to_location)
  local group = BodyLocations.getGroup("Human")
  local list = getClassFieldVal(group, getClassField(group, 1))
  group:getOrCreateLocation(new_location)
  local new_item = list:get(list:size()-1)
  print("JCIO: Created new body location" .. new_item:getId())
  list:remove(new_item)   -- We can't use the Index, it works if we pass the item though!
  local i = group:indexOf(move_to_location)
  list:add(i, new_item)
end


AddBodyLocationBefore("TOC_ArmRight", "Shoes")
AddBodyLocationBefore("TOC_ArmLeft", "Shoes")



AddBodyLocationBefore("TOC_ArmRightProsthesis", "Shoes")
AddBodyLocationBefore("TOC_ArmLeftProsthesis", "Shoes")

AddBodyLocationBefore("TOC_LegRight", "FannyPackFront")
AddBodyLocationBefore("TOC_LegLeft", "FannyPackFront")


AddBodyLocationBefore("TOC_LegRightProsthesis", "FannyPackFront")
AddBodyLocationBefore("TOC_LegLeftProsthesis", "FannyPackFront")
