--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

-- Locations must be declared in render-order.
-- Location IDs must match BodyLocation= and CanBeEquipped= values in items.txt.

-- FullBody     1
-- BodyCostume  2
-- FullHat      3
-- Hat          4    
-- MakeUp       5
-- Mask         6
-- JacketHat    7
-- Jacket       8
-- Shirt        9
-- Sweater      10
-- TankTop      11
-- TorsoExtra   12
-- Hands        13
-- Neck         14
-- Scarf        15
-- Pants        16
-- Shorts       17
-- Underwear    18
-- Shoes        19
-- None         20

local function addBodyLocationBefore(newLocation, movetoLocation)

    -- TODO pretty sure this function is borked


    local group = BodyLocations.getGroup("Human")
    local list = getClassFieldVal(group, getClassField(group, 1))
    group:getOrCreateLocation(newLocation)


    local newItem = list:get(list:size()-1)
    list:remove(list:size()-1)
    local i = group:indexOf(movetoLocation)
    list:add(i, newItem)
  end


local function TocSetSleeves(check)

    -- FIXME This can't work, we need to fix masks before changing the order. There is nothing I can do for now with only this




    local group = BodyLocations.getGroup("Human")
    group:getOrCreateLocation("ArmRight_Prot")
    group:getOrCreateLocation("ArmLeft_Prot")
    group:getOrCreateLocation("ArmRight")
    group:getOrCreateLocation("ArmLeft")

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

TocSetSleeves(true)