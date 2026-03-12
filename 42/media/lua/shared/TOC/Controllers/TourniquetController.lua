
local CommonMethods = require("TOC/CommonMethods")
---------------------------

---@class TourniquetController
local TourniquetController = {
    bodyLoc = "TOC_ArmAccessory"
}

function TourniquetController.CheckTourniquetOnLimb(player, limbName)
    local side = CommonMethods.GetSide(limbName)

    local wornItems = player:getWornItems()
    for j=1,wornItems:size() do
        local wornItem = wornItems:get(j-1)

        local fType = wornItem:getItem():getFullType()
        if TourniquetController.IsItemTourniquet(fType) then
            -- Check side
            if luautils.stringEnds(fType, side) then
                TOC_DEBUG.print("Found acceptable tourniquet")
                return true
            end
        end
    end

    return false
end

function TourniquetController.IsItemTourniquet(fType)
    -- TODO Add legs stuff
    return string.contains(fType, "Surg_Arm_Tourniquet_")
end

---@param player IsoPlayer
---@param limbName string
---@return boolean
function TourniquetController.CheckTourniquet(player, limbName)

    local side = CommonMethods.GetSide(limbName)

    local wornItems = player:getWornItems()
    for j=1,wornItems:size() do
        local wornItem = wornItems:get(j-1)

        local fType = wornItem:getItem():getFullType()
        if string.contains(fType, "Surg_Arm_Tourniquet_") then
            -- Check side
            if luautils.stringEnds(fType, side) then
                TOC_DEBUG.print("Found acceptable tourniquet")
                return true
            end
        end
    end

    return false
end

return TourniquetController
