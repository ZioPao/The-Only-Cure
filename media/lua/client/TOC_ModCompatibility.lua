---------------------------------
-- Compatibility for various mods
---------------------------------

local function OverrideFancyHandwork()
    if getActivatedMods():contains('FancyHandwork') == false then return end



    local og_ISHotbar_equipItem = ISHotbar.equipItem

    function ISHotbar:equipItem(item)
        print("TOC: Overriding FancyHandwork methods")
        local mod = isFHModKeyDown()
        local primary = self.chr:getPrimaryHandItem()
        local secondary = self.chr:getSecondaryHandItem()
        local equip = true

        local limbs_data = getPlayer():getModData().TOC.Limbs
        local can_be_held = {}
        TocPopulateCanBeHeldTable(can_be_held, limbs_data)


        for _, test in pairs(can_be_held) do
            print(test)
        end
        --ISInventoryPaneContextMenu.transferIfNeeded(self.chr, item)

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
                -- If we still have something equipped in secondary, unequip
                if secondary and equip and can_be_held["Left"] then
                    ISTimedActionQueue.add(ISUnequipAction:new(self.chr, secondary, 20))
                end

                if can_be_held["Left"] then
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))
                else
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
                else
                    ISTimedActionQueue.add(ISEquipWeaponAction:new(self.chr, item, 20, false, item:isTwoHandWeapon()))

                end
            end
        end

        self.chr:getInventory():setDrawDirty(true)
        getPlayerData(self.chr:getPlayerNum()).playerInventory:refreshBackpacks()
    end



    local og_FHSwapHandsAction = FHSwapHandsAction.start

    function FHSwapHandsAction:start()
        local limbs_data = getPlayer():getModData().TOC.Limbs
        local can_be_held = {}
        TocPopulateCanBeHeldTable(can_be_held, limbs_data)


        if self.itemL and can_be_held["Right"] then
            self.itemL:setJobType(getText("ContextMenu_Equip_Primary") .. " " .. self.itemL:getName())
            self.itemL:setJobDelta(0.0)

        else
            self:stop()
            return
        end

        if self.itemR and can_be_held["Left"] then
            self.itemR:setJobType(getText("ContextMenu_Equip_Secondary") .. " " .. self.itemR:getName())
            self.itemR:setJobDelta(0.0)
        else
            self:stop()
            return
        end

        self:setActionAnim("EquipItem")
        self:setOverrideHandModels(self.itemR, self.itemL)

    end

end


Events.OnGameStart.Add(OverrideFancyHandwork)