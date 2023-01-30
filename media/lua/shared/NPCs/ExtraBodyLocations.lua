local function addBodyLocationBefore(newLocation, movetoLocation)

  -- TODO this is still broken!
  local group = BodyLocations.getGroup("Human")



  local list = getClassFieldVal(group, getClassField(group, 1))



  group:getOrCreateLocation(newLocation)


  local newItem = list:get(list:size()-1)
  print("TOC: Created new body location" .. newItem:getId())




  list:remove(list:size()-1)
  local i = group:indexOf(movetoLocation)
  list:add(i, newItem)
end




local function TocSetSleeves(check)

    -- FIXME This can't work, we need to fix masks before changing the order. There is nothing I can do for now with only this






    -- -- Check if we already set stuff before
    -- -- Readd them
    -- print("TOC: Running TocSetSleeves")

    -- if group:getLocation("RightArm") or group:getLocation("LeftArm") then
    --     BodyLocations:Reset()       -- maybe it's too much
    -- end

    -- if check then
    --     print("TOC: Rolling up sleeves")
    --     group:getOrCreateLocation("ArmRight_Prot")
    --     group:getOrCreateLocation("ArmLeft_Prot")
    --     group:getOrCreateLocation("ArmRight")
    --     group:getOrCreateLocation("ArmLeft")
    -- else
    --     print("TOC: Won't roll up sleeve")
    --     addBodyLocationBefore("ArmRight_Prot", "TorsoExtra")
    --     addBodyLocationBefore("ArmLeft_Prot", "TorsoExtra")
    --     addBodyLocationBefore("ArmRight", "Jacket")
    --     addBodyLocationBefore("ArmLeft", "Jacket")

    -- end


end

-- FIXME this still breaks

local group = BodyLocations.getGroup("Human")




addBodyLocationBefore("TOC_ArmRight", "Shoes")
addBodyLocationBefore("TOC_ArmLeft", "Shoes")
addBodyLocationBefore("TOC_ArmRightProsthesis", "Shoes")
addBodyLocationBefore("TOC_ArmLeftProsthesis", "Shoes")



-- group:getOrCreateLocation("TOC_ArmRight")
-- group:getOrCreateLocation("ArmLeft")
-- group:getOrCreateLocation("ArmRight_Prot")
-- group:getOrCreateLocation("ArmLeft_Prot")