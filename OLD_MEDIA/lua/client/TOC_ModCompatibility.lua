------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------

------------------------------------------
--      Compatibility Handler by Dhert
------------------------------------------



-- TODO Connect this with TOC logic instead of hardcoding it here
local parts = {
    "Right_Hand",
    "Left_Hand",
    "Right_LowerArm",
    "Left_LowerArm"
}
-- TODO Connect this with TOC logic instead of hardcoding it here
local vars = {
    "isCut",
    "isProsthesisEquipped"
}


local TOC_Compat = {}

-- Raw access, must pass valid part
--- @param player
--- @param part string
--- @return boolean
TOC_Compat.hasArmPart = function(player, part)
    if not player or not part then return false end
    local data = (player:getModData().TOC and player:getModData().TOC.Limbs) or nil
    return not data or not data[part] or (data[part][vars[1]] and data[part][vars[2]]) or not data[part][vars[1]]
end

-- Raw access, must pass valid parts. Will check for 2 parts (arm and hand)
--- @param player
--- @param part string
--- @param part2 string
--- @return boolean
TOC_Compat.hasArm = function(player, part, part2)
    if not player or not part then return false end
    local data = (player:getModData().TOC and player:getModData().TOC.Limbs) or nil
    return not data or (not data[part] or (data[part][vars[1]] and data[part][vars[2]]) or not data[part][vars[1]]) or (not data[part] or (data[part2][vars[1]] and data[part2][vars[2]]) or not data[part2][vars[1]])
end

-- Check if hand is available
--- @param player
--- @param left boolean -- optional
--- @return boolean
TOC_Compat.hasHand = function(player, left)
    return TOC_Compat.hasArm(player, ((left and parts[2]) or parts[1]), ((left and parts[4]) or parts[3]))
end

-- Check if both hands are available
--- @param player
--- @return boolean
TOC_Compat.hasBothHands = function(player)
    return TOC_Compat.hasArm(player, parts[1], parts[3]) and TOC_Compat.hasArm(player, parts[2], parts[4])
end

-- This returns a number for the hands that you have
----- 11 == both hands
----- 10 == left hand
----- 01 (1) == right hand
----- 00 (0) == no hands
--- @param player 
--- @return integer
TOC_Compat.getHands = function(player)
    return ((TOC_Compat.hasArm(player, parts[1], parts[3]) and 1) or 0) + ((TOC_Compat.hasArm(player, parts[2], parts[4]) and 10) or 0)
end


return TOC_Compat