
local CommonMethods = require("TOC/CommonMethods")


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

---@private
---@param obj any  self 
---@param wrappedFunc function
function TourniquetController.WrapClothingAction(obj, wrappedFunc)
    local isTourniquet = TourniquetController.IsItemTourniquet(obj.item:getFullType())
    local group
    if isTourniquet then
        group = BodyLocations.getGroup("Human")
        group:setMultiItem(TourniquetController.bodyLoc, false)
    end

    local ogValue = wrappedFunc(obj)

    if isTourniquet then
        group:setMultiItem(TourniquetController.bodyLoc, true)
    end

    return ogValue      -- Needed for isValid
end


--[[
    Horrendous workaround

    To unequp items, the java side uses WornItems.setItem, which has
    a check for multiItem. Basically, if it's active, it won't actually remove the item,
    fucking things up. So, to be 100% sure that we're removing the items, we're gonna
    disable and re-enable the multi-item bool for the Unequip Action.

    Same story as the prosthesis item basically.
]]


local og_ISClothingExtraAction_perform = ISClothingExtraAction.perform
function ISClothingExtraAction:perform()
    TourniquetController.WrapClothingAction(self, og_ISClothingExtraAction_perform)
end

local og_ISWearClothing_isValid = ISWearClothing.isValid
function ISWearClothing:isValid()
    return TourniquetController.WrapClothingAction(self, og_ISWearClothing_isValid)
end

local og_ISUnequipAction_perform = ISUnequipAction.perform
function ISUnequipAction:perform()
   return TourniquetController.WrapClothingAction(self, og_ISUnequipAction_perform)
end


return TourniquetController