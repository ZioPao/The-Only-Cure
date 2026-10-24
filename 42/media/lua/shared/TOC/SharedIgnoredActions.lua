--- We're forced to re-run this crap to fix it
---@param o ISBaseTimedAction
---@param maxTime number
local function OverrideAction(o, maxTime)
    -- TODO Add forced debuff instead of just relying on the vanilla values?
    o.skipTOC = true
    o.maxTime = maxTime
    o.animSpeed = 1.0
end

local og_ISAttachItemHotbar_new = ISAttachItemHotbar.new
function ISAttachItemHotbar:new(character, item, slot, slotIndex, slotDef)
    local action = og_ISAttachItemHotbar_new(self, character, item, slot, slotIndex, slotDef)
    OverrideAction(action, 30)      -- Default time for this action
    return action
end

local og_ISEquipWeaponAction_new = ISEquipWeaponAction.new
function ISEquipWeaponAction:new(character, item, maxTimeInit, primary, twoHands, alwaysTurnOn)

    local action = og_ISEquipWeaponAction_new(self, character, item, maxTimeInit, primary, twoHands, alwaysTurnOn)
    --TOC_DEBUG.print("Override ISEquipWeaponAction New")


    -- check if right arm is cut off or not. if it is, penality shall apply
    -- if we got here, the action is valid, so we know that we have a prosthesis.
    local DataController = require("TOC/Controllers/DataController")
    local dcInst = DataController.GetInstance(character:getUsername())

    -- Brutal Handwork should be considered. Use the twohands thing
    if not (dcInst:getIsAnyLimbCut() and twoHands) then
        OverrideAction(action, maxTimeInit)
    end

    return action

end

--FIX Re-enable?
-- local og_ISUnequipAction_new = ISUnequipAction.new
-- function ISUnequipAction:new(character, item, maxTimeInit)
--     local action = og_ISUnequipAction_new(self, character, item, maxTimeInit)
--     ---@cast item InventoryItem

--     -- TODO Consider other cases where unequipping something should skip TOC.
--     if instanceof(item, 'HandWeapon') then
--         OverrideAction(action, maxTimeInit)
--     end

--     return action
-- end


local og_ISTakeWaterAction_new = ISTakeWaterAction.new
function ISTakeWaterAction:new(character, item, waterObject, waterTaintedCL)
    local o = og_ISTakeWaterAction_new(self,character, item, waterObject, waterTaintedCL)
    --TOC_DEBUG.print("Override ISTakeWaterAction")
    o.skipTOC = true
    return o
end

local og_ISEatFoodAction_new = ISEatFoodAction.new
function ISEatFoodAction:new(character, item, percentage)
    local o = og_ISEatFoodAction_new(self, character, item, percentage)
    --TOC_DEBUG.print("Override ISEatFoodAction")
    o.skipTOC = true
    return o
end

local og_ISReadABook_new = ISReadABook.new
function ISReadABook:new(character, item)
    local o = og_ISReadABook_new(self, character, item)
    --TOC_DEBUG.print("Override ISReadABook")
    o.skipTOC = true
    return o
end

local og_ISTakePillAction_new = ISTakePillAction.new
function ISTakePillAction:new(character, item)
    local o = og_ISTakePillAction_new(self, character, item)
    --TOC_DEBUG.print("Override ISTakePillAction")
    o.skipTOC = true
    return o
end

local og_ISDrinkFromBottle_new = ISDrinkFromBottle.new
function ISDrinkFromBottle:new(character, item, uses)
    local o = og_ISDrinkFromBottle_new(self, character, item, uses)
    --TOC_DEBUG.print("Override ISDrinkFromBottle")
    o.skipTOC = true
    return o
end

-- #285: fluid/fuel actions are one-handed; exempt from the amputation time penalty.
-- #292: the parameter names below are the wire args NetTimedAction reads off the
-- constructor prototype. Never wrap these `new`s with `...`: a vararg prototype
-- has no named params, so the server would rebuild the action with nil args.
local og_ISDrinkFluidAction_new = ISDrinkFluidAction.new
function ISDrinkFluidAction:new(character, item, percentage)
    local o = og_ISDrinkFluidAction_new(self, character, item, percentage)
    o.skipTOC = true
    return o
end

local og_ISFluidEmptyAction_new = ISFluidEmptyAction.new
function ISFluidEmptyAction:new(character, containerObject)
    local o = og_ISFluidEmptyAction_new(self, character, containerObject)
    o.skipTOC = true
    return o
end

local og_ISFluidTransferAction_new = ISFluidTransferAction.new
function ISFluidTransferAction:new(character, sourceContainer, sourceFluidObject, targetContainer, targetFluidObject, amount)
    local o = og_ISFluidTransferAction_new(self, character, sourceContainer, sourceFluidObject, targetContainer, targetFluidObject, amount)
    o.skipTOC = true
    return o
end

local og_ISAddFluidFromItemAction_new = ISAddFluidFromItemAction.new
function ISAddFluidFromItemAction:new(character, itemFrom, objectTo)
    local o = og_ISAddFluidFromItemAction_new(self, character, itemFrom, objectTo)
    o.skipTOC = true
    return o
end

local og_ISTakeFuel_new = ISTakeFuel.new
function ISTakeFuel:new(character, fuelStation, petrolCan)
    local o = og_ISTakeFuel_new(self, character, fuelStation, petrolCan)
    o.skipTOC = true
    return o
end

local og_ISRefuelFromGasPump_new = ISRefuelFromGasPump.new
function ISRefuelFromGasPump:new(character, part, fuelStation)
    local o = og_ISRefuelFromGasPump_new(self, character, part, fuelStation)
    o.skipTOC = true
    return o
end

local og_ISTakeGasolineFromVehicle_new = ISTakeGasolineFromVehicle.new
function ISTakeGasolineFromVehicle:new(character, part, item, otherItems)
    local o = og_ISTakeGasolineFromVehicle_new(self, character, part, item, otherItems)
    o.skipTOC = true
    return o
end

local og_ISDumpWaterAction_new = ISDumpWaterAction.new
function ISDumpWaterAction:new(character, item)
    local o = og_ISDumpWaterAction_new(self, character, item)
    o.skipTOC = true
    return o
end

local og_ISTransferWaterAction_new = ISTransferWaterAction.new
function ISTransferWaterAction:new(character, itemFrom, itemTo, itemFromEndingDelta, itemToEndingDelta)
    local o = og_ISTransferWaterAction_new(self, character, itemFrom, itemTo, itemFromEndingDelta, itemToEndingDelta)
    o.skipTOC = true
    return o
end

local og_ISAddFuelAction_new = ISAddFuelAction.new
function ISAddFuelAction:new(character, campfire, item, fuelAmt)
    local o = og_ISAddFuelAction_new(self, character, campfire, item, fuelAmt)
    o.skipTOC = true
    return o
end

local og_ISInsertLightSourceFuelAction_new = ISInsertLightSourceFuelAction.new
function ISInsertLightSourceFuelAction:new(character, lightSource, fuel)
    local o = og_ISInsertLightSourceFuelAction_new(self, character, lightSource, fuel)
    o.skipTOC = true
    return o
end

local og_ISRemoveLightSourceFuelAction_new = ISRemoveLightSourceFuelAction.new
function ISRemoveLightSourceFuelAction:new(character, lightSource)
    local o = og_ISRemoveLightSourceFuelAction_new(self, character, lightSource)
    o.skipTOC = true
    return o
end

local og_ISLightFromPetrol_new = ISLightFromPetrol.new
function ISLightFromPetrol:new(character, campfire, lighter, petrol, maxTimeInit)
    local o = og_ISLightFromPetrol_new(self, character, campfire, lighter, petrol, maxTimeInit)
    o.skipTOC = true
    return o
end
