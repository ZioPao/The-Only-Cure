require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISEquipWeaponAction"
require "TimedActions/ISUnequipAction"
require "ISUI/ISInventoryPaneContextMenu"



-- TODO 1) Add exceptions for watches

local og_ISBaseTimedActionAdjustMaxTime = ISBaseTimedAction.adjustMaxTime
function ISBaseTimedAction:adjustMaxTime(maxTime)

    -- TODO we can customize it better through clothing items modifier, you mook
    --        RunSpeedModifier = 0.93 for example
    local originalMaxTime = og_ISBaseTimedActionAdjustMaxTime(self, maxTime)

    if originalMaxTime ~= -1 then


        local modData = getPlayer():getModData()

        local limbParameters = JCIO.limbParameters
        local limbsData = modData.JCIO.limbs

        local modifiedMaxTime = originalMaxTime
        local burnFactor = 1.3         -- TODO Move this crap

        for _, partName in pairs(JCIO_Common.GetPartNames()) do
            if limbsData[partName].isCut then







                --Equipped prosthesis or not
                if limbsData[partName].isProsthesisEquipped then
                -- FIXME We should apply the correct values to equippedProsthesis once we equip it 

                    --modifiedMaxTime = modifiedMaxTime * limbsData[partName].equipped_prosthesis.prosthesis_factor
                else
                    -- TODO this should depend on the limb?
                    modifiedMaxTime = modifiedMaxTime * 1.5
                end

                -- Cauterization check
                if limbsData[partName].is_cauterized then
                    modifiedMaxTime = modifiedMaxTime * burnFactor
                end

                -- Perk scaling
                if partName == "Right_Hand" or partName == "Left_Hand" then
                    modifiedMaxTime = modifiedMaxTime *
                        (1 + (9 - self.character:getPerkLevel(Perks[partName])) / 20)
                end

            end
        end
        if modifiedMaxTime > 10 * originalMaxTime then modifiedMaxTime = 10 * originalMaxTime end
        return modifiedMaxTime

    end
        
    return originalMaxTime
    

end


-------------------------------------------------
-- Block access to drag, picking, inspecting, etc to amputated limbs
local og_ISInventoryPaneOnMouseDoubleClick = ISInventoryPane.onMouseDoubleClick
function ISInventoryPane:onMouseDoubleClick(x, y)

    local item_to_check = self.items[self.mouseOverOption]
    local player_inventory = getPlayerInventory(self.player).inventory


    if instanceof(item_to_check, "InventoryItem") then
        og_ISInventoryPaneOnMouseDoubleClick(self, x, y)
    elseif JCIO_Common.CheckIfItemIsAmputatedLimb(item_to_check.items[1]) or JCIO_Common.CheckIfItemIsInstalledProsthesis(item_to_check.items[1]) then
        --print("JCIO: Can't double click this item")

    end
    og_ISInventoryPaneOnMouseDoubleClick(self, x, y)



end

local og_ISInventoryPaneGetActualItems = ISInventoryPane.getActualItems
function ISInventoryPane.getActualItems(items)

    -- TODO add an exception for installed prosthesis, make them unequippable automatically from here and get the correct obj
    local ret = og_ISInventoryPaneGetActualItems(items)

    -- This is gonna be slower than just overriding the function but hey it's more compatible
    for i = 1, #ret do
        local item_full_type = ret[i]:getFullType()
        if string.find(item_full_type, "Amputation_") or string.find(item_full_type, "Prost_") then
            table.remove(ret, i)
        end
    end
    return ret
end

local og_ISInventoryPaneContextMenuOnInspectClothing = ISInventoryPaneContextMenu.onInspectClothing
ISInventoryPaneContextMenu.onInspectClothing         = function(playerObj, clothing)

    -- Inspect menu bypasses getActualItems, so we need to add that workaround here too
    local clothing_full_type = clothing:getFullType()
    if JCIO_Common.CheckIfItemIsAmputatedLimb(clothing) or JCIO_Common.CheckIfItemIsInstalledProsthesis(clothing) then
        --print("JCIO: Can't inspect this!")
    else
        og_ISInventoryPaneContextMenuOnInspectClothing(playerObj, clothing)

    end

end


local og_ISEquipWeaponActionPerform = ISEquipWeaponAction.perform
function ISEquipWeaponAction:perform()
    -- TODO this is only for weapons, not items. Won't work for everything I think
    --TODO Block it before even performing
    -- TODO in the inventory menu there is something broken, even though this works
    og_ISEquipWeaponActionPerform(self)
    local limbs_data = self.character:getModData().JCIO.limbs
    local can_be_held = JCIO_Common.GetCanBeHeldTable(limbs_data)


    if not self.item:isRequiresEquippedBothHands() then
        if can_be_held["Right"] and not can_be_held["Left"] then
            self.character:setPrimaryHandItem(self.item)
            self.character:setSecondaryHandItem(nil)
        elseif not can_be_held["Right"] and can_be_held["Left"] then
            self.character:setPrimaryHandItem(nil)
            self.character:setSecondaryHandItem(self.item)
        elseif not can_be_held["Left"] and not can_be_held["Right"] then
            self.character:dropHandItems()
        end
    else
        if (can_be_held["Right"] and not can_be_held["Left"]) or
            (not can_be_held["Right"] and can_be_held["Left"]) or
            (not can_be_held["Left"] and not can_be_held["Right"]) then
            self.character:dropHandItems()

        end
    end


    -- Check if it's a prosthesis and let the player know that they're fucking things up 
    if self.item then
        local item_name = self.item:getFullType()

        for _, prost_v in pairs(GetProsthesisList()) do
            local prosthesis_name = string.match(item_name, prost_v)
            if prosthesis_name then
                self.character:Say("This isn't the right way to equip this...")
            end
        end

    end



end

local og_ISInventoryPaneContextMenuUnequipItem = ISInventoryPaneContextMenu.unequipItem
function ISInventoryPaneContextMenu.unequipItem(item, player)

    if item == nil then
        return
    end
    if JCIO_Common.CheckIfItemIsAmputatedLimb(item) == false and JCIO_Common.CheckIfItemIsInstalledProsthesis(item) == false then
        og_ISInventoryPaneContextMenuUnequipItem(item, player)
    end
end

local og_ISInventoryPaneContextMenuDropItem = ISInventoryPaneContextMenu.dropItem
function ISInventoryPaneContextMenu.dropItem(item, player)

    if JCIO_Common.CheckIfItemIsAmputatedLimb(item) == false and JCIO_Common.CheckIfItemIsInstalledProsthesis(item) == false then
        og_ISInventoryPaneContextMenuDropItem(item, player)
    end

end

-- Make the player unable to equip a tourniquet or watches on an already fully amputated limb
local og_ISWearClothingIsValid = ISWearClothing.isValid
function ISWearClothing:isValid()

	local baseCheck = og_ISWearClothingIsValid(self)
    local itemFullType = self.item:getFullType()
    local limbsData = self.character:getModData().JCIO.limbs

    local itemToCheck = "Surgery_%s_Tourniquet"
    for _, side in pairs(JCIO.sideNames) do

        local formattedItemName = string.format(itemToCheck, side)

        if string.find(itemFullType, formattedItemName) then
            if limbsData[side .. "_UpperArm"].isCut then
                return false
            end
        end
    end

    return baseCheck
    
end

local og_ISWearClothingExtraAction = ISClothingExtraAction.isValid

function ISClothingExtraAction:isValid()
	local baseCheck = og_ISWearClothingExtraAction(self)

    -- Check the new extra instead of the old item
    local newItem = self:createItem(self.item, self.extra)


    local itemFullType = newItem:getFullType()
    local location = newItem:getBodyLocation()


    --print("JCIO: watch full type " .. itemFullType)
    --print("JCIO: watch location " .. location)

    local itemToCheck = "Watch_"
    local limbsData = self.character:getModData().JCIO.limbs

    if string.find(itemFullType, itemToCheck) then
        
        for _, side in pairs (JCIO.sideNames) do
            
            if location == side .. "Wrist" then
                if limbsData[side .. "_LowerArm"].isCut then
                    return false
                end
            end
            
        end


    end

    return baseCheck
end