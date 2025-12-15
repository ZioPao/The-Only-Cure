------------------------------------------
--      Compatibility Handler by Dhert
------------------------------------------

local DataController = require("TOC/Controllers/DataController")
local StaticData = require("TOC/StaticData")


local TOC_Compat = {}

-- Raw access, must pass valid part
--- @param player IsoPlayer
--- @param part string
--- @return boolean
function TOC_Compat.hasPart(player, part)
    if not player or not part then return false end
    local dc = DataController.GetInstance(player:getUsername())
    if not dc then return false end
    return (dc:getIsCut(part) and dc:getIsProstEquipped(part)) or not dc:getIsCut(part)
end

--- Check if hand is available
---@param player IsoPlayer
---@param left boolean Optional
---@return boolean
function TOC_Compat.hasHand(player, left)
    return TOC_Compat.hasPart(player, ((left and StaticData.LIMBS_IND_STR.Hand_L) or StaticData.LIMBS_IND_STR.Hand_R))
end

--- Check if both hands are available
---@param player IsoPlayer
---@return boolean
function TOC_Compat.hasBothHands(player)
    return TOC_Compat.hasHand(player, false) and TOC_Compat.hasHand(player, true)
end


-- This returns a number for the hands that you have
----- 11 == both hands
----- 10 == left hand
----- 01 (1) == right hand
----- 00 (0) == no hands
---@param player any
---@return integer
function TOC_Compat.getHands(player)
    return ((TOC_Compat.hasHand(player, false) and 1) or 0) + ((TOC_Compat.hasHand(player, true) and 10) or 0)
end


return TOC_Compat