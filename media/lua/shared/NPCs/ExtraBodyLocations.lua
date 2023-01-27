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
    local group = BodyLocations.getGroup("Human")
    local list = getClassFieldVal(group, getClassField(group, 1))
    group:getOrCreateLocation(newLocation)
    local newItem = list:get(list:size()-1)
    list:remove(list:size()-1)
    local i = group:indexOf(movetoLocation)
    list:add(i, newItem)
  end


function TocSetSleeves(check)
    local group = BodyLocations.getGroup("Human")
    if check then
        print("TOC: Rolling up sleeves")
        group:getOrCreateLocation("ArmRight")
        group:getOrCreateLocation("ArmLeft")
        group:getOrCreateLocation("ArmRight_Prot")
        group:getOrCreateLocation("ArmLeft_Prot")
    else
        print("TOC: Won't roll up sleeve")
        addBodyLocationBefore("ArmRight", "Jacket")
        addBodyLocationBefore("ArmLeft", "Jacket")
        addBodyLocationBefore("ArmRight_Prot", "Shoes")
        addBodyLocationBefore("ArmLeft_Prot", "Shoes")
    end
end

