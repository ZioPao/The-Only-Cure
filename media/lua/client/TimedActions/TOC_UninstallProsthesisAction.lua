require "TimedActions/ISBaseTimedAction"

TOC_UninstallProsthesisAction = ISBaseTimedAction:derive("TOC_UninstallProsthesisAction")

function TOC_UninstallProsthesisAction:isValid()

    if self.item ~= nil and self.isProsthesisEquipped then
        return true
    else
        return false
    end
end

function TOC_UninstallProsthesisAction:update()
    self.item:setJobDelta(self:getJobDelta())
end

function TOC_UninstallProsthesisAction:start()
    self.item:setJobType("Uninstall prothesis")
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

function TOC_UninstallProsthesisAction:stop()
    ISBaseTimedAction.stop(self);
    self.item:setJobDelta(0.0);
end

function TOC_UninstallProsthesisAction:perform()

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

        SendUnequipProsthesis(self.patient, self.partName, self.item)
    else
        TOC.OperateLimb(self.patient, self.partName, self.item)
    end

    ISBaseTimedAction.perform(self)
end

function TOC_UninstallProsthesisAction:new(surgeon, patient, partName)
    local o = ISBaseTimedAction.new(self, surgeon)

    local limbsData = patient:getModData().TOC.limbs

    o.item = TOC_Common.FindItemInProstBodyLocation(partName, patient)
    o.character = surgeon         -- For animation purposes

    o.patient = patient
    o.surgeon = surgeon

    o.partName = partName


    o.isProsthesisEquipped = limbsData[partName].isProsthesisEquipped


    o.maxTime = 100;
    o.stopOnWalk = true
    o.stopOnRun = true
    o.ignoreHandsWounds = false
    o.fromHotbar = true -- just to disable hotbar:update() during the wearing
    if o.character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end
