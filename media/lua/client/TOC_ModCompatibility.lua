---------------------------------
-- Compatibility for various mods
---------------------------------


local function SetCompatibilityFancyHandwork()
    local og_ISHotbar_equipItem = ISHotbar.equipItem

    function ISHotbar:equipItem(item)
        local mod = isFHModKeyDown()
        local primary = self.chr:getPrimaryHandItem()
        local secondary = self.chr:getSecondaryHandItem()
        local equip = true

        local limbs_data = getPlayer():getModData().TOC.Limbs
        local can_be_held = {}

        -- TODO not totally realiable
        TocPopulateCanBeHeldTable(can_be_held, limbs_data)


        -- If we already have the item equipped
        if (primary and primary == item) or (secondary and secondary == item) then
            ISTimedActionQueue.add(ISUnequipAction:new(self.chr, item, 20))
            equip = false
        end

        -- If we didn't just do something
        if equip then
            -- Handle holding big objects
            if primary and isForceDropHeavyItem(primary) then
                ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 50))
                ----- treat "equip" as if we have something equipped from here down
                equip = false
            end
            if mod then
                --print("TOC: Fancy Handwork modifier")
                -- If we still have something equipped in secondary, unequip
                if secondary and equip and can_be_held["Left"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, secondary, 20))
                end

                if can_be_held["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))
                elseif can_be_held["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))

                end
            else
                -- If we still have something equipped in primary, unequip
                if primary and equip and can_be_held["Right"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 20))
                end
                -- Equip Primary
                if can_be_held["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))
                elseif can_be_held["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))

                end
            end
        end

        self.chr:getInventory():setDrawDirty(true)
        getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
    end

    local og_FHSwapHandsAction = FHSwapHandsAction.start


    function FHSwapHandsAction:isValid()
        local limbs_data = getPlayer():getModData().TOC.Limbs
        local can_be_held = {}
        TocPopulateCanBeHeldTable(can_be_held, limbs_data)
        return  (can_be_held["Right"] and can_be_held["Left"]) and(((self.character:getPrimaryHandItem() or self.character:getSecondaryHandItem()) ~= nil))
    end

end

local function SetCompatibilityFancyHandWorkAndSwapIt()

    SetCompatibilityFancyHandwork()

    -- Override equip Item once again with the necessary changes
    function ISHotbar:equipItem(item)
        local mod = isFHModKeyDown()
        local primary = self.chr:getPrimaryHandItem()
        local secondary = self.chr:getSecondaryHandItem()
        local equip = true

        local limbs_data = getPlayer():getModData().TOC.Limbs
        local can_be_held = {}

        -- TODO not totally realiable
        TocPopulateCanBeHeldTable(can_be_held, limbs_data)


        -- If we already have the item equipped
        if (primary and primary == item) or (secondary and secondary == item) then
            ISTimedActionQueue.add(ISUnequipAction:new(self.chr, item, 20))
            equip = false
        end

        -- If we didn't just do something
        if equip then
            -- Handle holding big objects
            if primary and isForceDropHeavyItem(primary) then
                ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 50))
                ----- treat "equip" as if we have something equipped from here down
                equip = false
            end
            if mod then
                --print("TOC: Fancy Handwork modifier")
                -- If we still have something equipped in secondary, unequip
                if secondary and equip and can_be_held["Left"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, secondary, 20))
                end

                if can_be_held["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))
                elseif can_be_held["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))

                end
            else
                -- If we still have something equipped in primary, unequip
                if primary and equip and can_be_held["Right"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 20))
                end
                -- Equip Primary
                if can_be_held["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))
                elseif can_be_held["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))

                end
            end

            -- Swap It part
            local i_slotinuse = item:getAttachedSlot()
            local slot = self.availableSlot[i_slotinuse]
            local slotIndexID = "swap_Hotbar"..i_slotinuse
            if slot and SwapItConfig.config[slotIndexID] == true then
                if primary and not self:isInHotbar(primary) and self:canBeAttached(slot, primary) then
                    self:removeItem(item, false)--false = don't run animation
                    self:attachItem(primary, slot.def.attachments[primary:getAttachmentType()], i_slotinuse, slot.def, true)
                end
            end

        end

        self.chr:getInventory():setDrawDirty(true)
        getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
    end


end

--------------------------------------------------------

function TOC_CheckModCompatibility()
    local activated_mods = getActivatedMods()
    print("TOC: Checking mods")
    if activated_mods:contains("FancyHandwork") then
        if activated_mods:contains("SwapIt") then
            require "SwapIt Main"
            print("TOC: Overriding FancyHandwork and SwapIt methods")
            SetCompatibilityFancyHandWorkAndSwapIt()
        else
            print("TOC: Overriding FancyHandwork methods")
            require "TimedActions/FHSwapHandsAction"
            SetCompatibilityFancyHandwork()
        end
    end



end

print("TOC: Starting CheckModCompatibility")

Events.OnGameStart.Add(TOC_CheckModCompatibility)