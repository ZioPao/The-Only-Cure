------------------------------------------
------------- JUST CUT IT OUT ------------
------------------------------------------

------------------------------------------
--      Compatibility for various mods
------------------------------------------


local function SetCompatibilityFancyHandwork()
    local og_ISHotbar_equipItem = ISHotbar.equipItem

    function ISHotbar:equipItem(item)
        local mod = isFHModKeyDown()
        local primary = self.chr:getPrimaryHandItem()
        local secondary = self.chr:getSecondaryHandItem()
        local equip = true

        local limbsData = getPlayer():getModData().JCIO.limbs
        local canBeHeld = JCIO_Common.GetCanBeHeldTable(limbsData)

        
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
                --print("JCIO: Fancy Handwork modifier")
                -- If we still have something equipped in secondary, unequip
                if secondary and equip and canBeHeld["Left"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, secondary, 20))
                end

                if canBeHeld["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))
                elseif canBeHeld["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))

                end
            else
                -- If we still have something equipped in primary, unequip
                if primary and equip and canBeHeld["Right"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 20))
                end
                -- Equip Primary
                if canBeHeld["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))
                elseif canBeHeld["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))

                end
            end
        end

        self.chr:getInventory():setDrawDirty(true)
        getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
    end

    local og_FHSwapHandsAction = FHSwapHandsAction.start


    function FHSwapHandsAction:isValid()
        local limbsData = getPlayer():getModData().JCIO.limbs
        local canBeHeld = JCIO_Common.GetCanBeHeldTable(limbsData)

        return (canBeHeld["Right"] and canBeHeld["Left"]) and(((self.character:getPrimaryHandItem() or self.character:getSecondaryHandItem()) ~= nil))
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

        local limbsData = getPlayer():getModData().JCIO.limbs
        local canBeHeld = JCIO_Common.GetCanBeHeldTable(limbsData)

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
                --print("JCIO: Fancy Handwork modifier")
                -- If we still have something equipped in secondary, unequip
                if secondary and equip and canBeHeld["Left"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, secondary, 20))
                end

                if canBeHeld["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))
                elseif canBeHeld["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))

                end
            else
                -- If we still have something equipped in primary, unequip
                if primary and equip and canBeHeld["Right"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, primary, 20))
                end
                -- Equip Primary
                if canBeHeld["Right"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, true, item:isTwoHandWeapon()))
                elseif canBeHeld["Left"] then
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

local function CheckModCompatibility()
    local activatedMods = getActivatedMods()
    print("JCIO: Checking mods")

    if activatedMods:contains("FancyHandwork") then

        if activatedMods:contains("SwapIt") then
            require "SwapIt Main"
            print("JCIO: Overriding FancyHandwork and SwapIt methods")
            SetCompatibilityFancyHandWorkAndSwapIt()
        else
            print("JCIO: Overriding FancyHandwork methods")
            require "TimedActions/FHSwapHandsAction"
            SetCompatibilityFancyHandwork()
        end
    end
end

print("JCIO: Starting CheckModCompatibility")
Events.OnGameStart.Add(CheckModCompatibility)

