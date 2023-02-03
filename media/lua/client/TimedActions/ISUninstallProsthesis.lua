require "TimedActions/ISBaseTimedAction"

ISUninstallProsthesis = ISBaseTimedAction:derive("ISUninstallProsthesis");

function ISUninstallProsthesis:isValid()

    if self.item ~= nil and self.is_prosthesis_equipped then
        return true
    else
        return false
    end




end

function ISUninstallProsthesis:update()
    self.item:setJobDelta(self:getJobDelta());
end

function ISUninstallProsthesis:start()
    self.item:setJobType("Uninstall prothesis");
    self.item:setJobDelta(0.0);
    self:setActionAnim("WearClothing");
    if self.item:IsClothing() then
        self:setAnimVariable("WearClothingLocation", "Jacket")
    elseif self.item:IsInventoryContainer() and self.item:canBeEquipped() ~= "" then
        self:setAnimVariable("WearClothingLocation", "Jacket")
    end

    self.character:setPrimaryHandItem(nil)
    self.character:setSecondaryHandItem(self.item)
end

function ISUninstallProsthesis:stop()
    ISBaseTimedAction.stop(self);
    self.item:setJobDelta(0.0);
end

function ISUninstallProsthesis:perform()

    self.item:getContainer():setDrawDirty(true)
    self.item:setJobDelta(0.0)

    if instanceof(self.item, "InventoryContainer") and self.item:canBeEquipped() ~= "" then
        self.character:removeFromHands(self.item)
        self.character:setWornItem(self.item:canBeEquipped(), self.item)
        getPlayerInventory(self.character:getPlayerNum()):refreshBackpacks()
    elseif self.item:getCategory() == "Clothing" then
        if self.item:getBodyLocation() ~= "" then
            self.character:setWornItem(self.item:getBodyLocation(), self.item)
        end
    end


    if self.patient ~= self.surgeon and isClient() then

        SendUnequipProsthesis(self.patient, self.part_name, self.item)
    else
        TheOnlyCure.UnequipProsthesis(self.patient, self.part_name, self.item)
    end

    ISBaseTimedAction.perform(self)
end

function ISUninstallProsthesis:new(surgeon, patient, part_name)
    local o = ISBaseTimedAction.new(self, surgeon)

    local toc_limbs_data = patient:getModData().TOC.Limbs

    o.item = TocFindItemInProstBodyLocation(part_name, patient)
    o.character = surgeon         -- For animation purposes

    o.patient = patient
    o.surgeon = surgeon

    o.part_name = part_name


    o.is_prosthesis_equipped = toc_limbs_data[part_name].is_prosthesis_equipped


    o.maxTime = 100;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.ignoreHandsWounds = false;
    o.fromHotbar = true; -- just to disable hotbar:update() during the wearing
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end
