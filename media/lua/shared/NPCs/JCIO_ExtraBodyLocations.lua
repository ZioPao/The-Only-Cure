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


AddBodyLocationBefore("JCIO_ArmRight", "Shoes")
AddBodyLocationBefore("JCIO_ArmLeft", "Shoes")



AddBodyLocationBefore("JCIO_ArmRightProsthesis", "Shoes")
AddBodyLocationBefore("JCIO_ArmLeftProsthesis", "Shoes")

AddBodyLocationBefore("JCIO_LegRight", "FannyPackFront")
AddBodyLocationBefore("JCIO_LegLeft", "FannyPackFront")


AddBodyLocationBefore("JCIO_LegRightProsthesis", "FannyPackFront")
AddBodyLocationBefore("JCIO_LegLeftProsthesis", "FannyPackFront")
