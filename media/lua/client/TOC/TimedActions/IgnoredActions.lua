---@diagnostic disable: duplicate-set-field
-- Bunch of actions shouldn't be modified by the adjusted time 

-----------------------------------------------
---* Some actions have specific maxTime calculations and we must account for that
---ISAttachItemHotbar
---ISDetachItemHotbar
---ISEquipWeaponAction
---ISUnequipAction

--- We're forced to re-run this crap to fix it
---@param action ISBaseTimedAction
local function HandleSpeedSpecificAction(action)
    action.skipTOC = true
    action.animSpeed = action.maxTime / action:adjustMaxTime(action.maxTime)
    action.maxTime = -1
end

local og_ISAttachItemHotbar_new = ISAttachItemHotbar.new
function ISAttachItemHotbar:new(character, item, slot, slotIndex, slotDef)
    local action = og_ISAttachItemHotbar_new(self, character, item, slot, slotIndex, slotDef)
    HandleSpeedSpecificAction(action)
    return action
end

local og_ISDetachItemHotbar_new = ISDetachItemHotbar.new
function ISDetachItemHotbar:new(character, item)
    local action = og_ISDetachItemHotbar_new(self, character, item)
    HandleSpeedSpecificAction(action)
    return action
end

local og_ISEquipWeaponAction_new = ISEquipWeaponAction.new
function ISEquipWeaponAction:new(character, item, time, primary, twoHands)
    local action = og_ISEquipWeaponAction_new(self, character, item, time, primary, twoHands)
    --TOC_DEBUG.print("Override ISEquipWeaponAction")
    if not twoHands then
        HandleSpeedSpecificAction(action)
    end
    return action
end

local og_ISUnequipAction_new = ISUnequipAction.new
function ISUnequipAction:new(character, item, time)
    local action = og_ISUnequipAction_new(self, character, item, time)
    HandleSpeedSpecificAction(action)
    return action
end

------------------------------------------------------
--- Normal cases


local og_ISEatFoodAction_new = ISEatFoodAction.new
function ISEatFoodAction:new(character, item, percentage)
    local action = og_ISEatFoodAction_new(self, character, item, percentage)
    --TOC_DEBUG.print("Override ISEatFoodAction")
    action.skipTOC = true
    return action
end

local og_ISReadABook_new = ISReadABook.new
function ISReadABook:new(character, item, time)
    local action = og_ISReadABook_new(self, character, item, time)
    --TOC_DEBUG.print("Override ISReadABook")
    action.skipTOC = true
    return action
end

local og_ISTakePillAction_new = ISTakePillAction.new
function ISTakePillAction:new(character, item, time)
    local action = og_ISTakePillAction_new(self, character, item, time)
    --TOC_DEBUG.print("Override ISTakePillAction")
    action.skipTOC = true
    return action
end

local og_ISTakeWaterAction_new = ISTakeWaterAction.new
function ISTakeWaterAction:new(character, item, waterUnit, waterObject, time, oldItem)
    local action = og_ISTakeWaterAction_new(self, character, item, waterUnit, waterObject, time, oldItem)
    --TOC_DEBUG.print("Override ISTakeWaterAction")
    action.skipTOC = true
    return action
end

local og_ISDrinkFromBottle_new = ISDrinkFromBottle.new
function ISDrinkFromBottle:new(character, item, uses)
    local action = og_ISDrinkFromBottle_new(self, character, item, uses)
    --TOC_DEBUG.print("Override ISDrinkFromBottle")
    action.skipTOC = true
    return action
end

local og_ISFinalizeDealAction_new = ISFinalizeDealAction.new
function ISFinalizeDealAction:new(player, otherPlayer, itemsToGive, itemsToReceive, time)
    local action = og_ISFinalizeDealAction_new(self, player, otherPlayer, itemsToGive, itemsToReceive, time)
    --TOC_DEBUG.print("Override ISFinalizeDealAction")
    action.skipTOC = true
    return action
end

local og_ISCampingInfoAction_new = ISCampingInfoAction.new
function ISCampingInfoAction:new(character, campfireObject, campfire)
    local action = og_ISCampingInfoAction_new(self, character, campfireObject, campfire)
    --TOC_DEBUG.print("Override ISCampingInfoAction")
    action.skipTOC = true
    return action
end