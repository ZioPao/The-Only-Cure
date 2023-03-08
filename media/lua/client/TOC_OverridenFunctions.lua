require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISEquipWeaponAction"
require "TimedActions/ISUnequipAction"
require "ISUI/ISInventoryPaneContextMenu"

local og_ISBaseTimedActionAdjustMaxTime = ISBaseTimedAction.adjustMaxTime


function ISBaseTimedAction:adjustMaxTime(maxTime)

    local original_max_time = og_ISBaseTimedActionAdjustMaxTime(self, maxTime)

    if original_max_time ~= -1 then
        local mod_data = getPlayer():getModData()
        local limbs_data = mod_data.TOC.Limbs
        local modified_max_time = original_max_time
        local burn_factor = 1.3         -- TODO Move this crap

        for _, part_name in pairs(GetBodyParts()) do
            if limbs_data[part_name].is_cut then

                --Equipped prosthesis or not
                if limbs_data[part_name].is_prosthesis_equipped then
                    modified_max_time = modified_max_time * limbs_data[part_name].equipped_prosthesis.prosthesis_factor
                else
                    -- TODO this should depend on the limb?
                    modified_max_time = modified_max_time * 1.5
                end

                -- Cauterization check
                if limbs_data[part_name].is_cauterized then
                    modified_max_time = modified_max_time * burn_factor
                end

                -- Perk scaling
                if part_name == "Right_Hand" or part_name == "Left_Hand" then
                    modified_max_time = modified_max_time *
                        (1 + (9 - self.character:getPerkLevel(Perks[part_name])) / 20)
                end

            end
        end
        if modified_max_time > 10 * original_max_time then modified_max_time = 10 * original_max_time end
        return modified_max_time

    end
        
    return original_max_time
    

end


-------------------------------------------------
-- Block access to drag, picking, inspecting, etc to amputated limbs
local og_ISInventoryPaneOnMouseDoubleClick = ISInventoryPane.onMouseDoubleClick
function ISInventoryPane:onMouseDoubleClick(x, y)

    local item_to_check = self.items[self.mouseOverOption]
    local player_inventory = getPlayerInventory(self.player).inventory
    if instanceof(item_to_check, "InventoryItem") then
        og_ISInventoryPaneOnMouseDoubleClick(self, x, y)
    elseif CheckIfItemIsAmputatedLimb(item_to_check.items[1]) or CheckIfItemIsInstalledProsthesis(item_to_check.items[1]) then
        --print("TOC: Can't double click this item")
    else
        og_ISInventoryPaneOnMouseDoubleClick(self, x, y)

    end



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
    if CheckIfItemIsAmputatedLimb(clothing) or CheckIfItemIsInstalledProsthesis(clothing) then
        --print("TOC: Can't inspect this!")
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
    local limbs_data = self.character:getModData().TOC.Limbs
    local can_be_held = {}
    TocPopulateCanBeHeldTable(can_be_held, limbs_data)

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

        for _, prost_v in ipairs(GetProsthesisList()) do
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
    if CheckIfItemIsAmputatedLimb(item) == false and CheckIfItemIsInstalledProsthesis(item) == false then
        og_ISInventoryPaneContextMenuUnequipItem(item, player)
    end
end

local og_ISInventoryPaneContextMenuDropItem = ISInventoryPaneContextMenu.dropItem
function ISInventoryPaneContextMenu.dropItem(item, player)

    if CheckIfItemIsAmputatedLimb(item) == false and CheckIfItemIsInstalledProsthesis(item) == false then
        og_ISInventoryPaneContextMenuDropItem(item, player)
    end

end


local og_ISInventoryPagePrerender = ISInventoryPage.prerender

function ISInventoryPage:prerender()
    -- Check if there is any amputated limb here. if there is, just fail and maybe notify the player
    og_ISInventoryPagePrerender(self)
    if TocCheckIfAnyAmputationItemInInventory(self.inventory) then
        self.canLootAll = false
    else
        self.canLootAll = true
    end
end

local og_ISInventoryPageLootAll = ISInventoryPage.lootAll
function ISInventoryPage:lootAll()
    if self.canLootAll then
        og_ISInventoryPageLootAll(self)
    end
end