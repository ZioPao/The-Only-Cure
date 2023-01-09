require "TimedActions/ISBaseTimedAction"

ISUninstallProthesis = ISBaseTimedAction:derive("ISUninstallProthesis");

function ISUninstallProthesis:isValid()
    return true;
end

function ISUninstallProthesis:update()
    self.item:setJobDelta(self:getJobDelta());
end

function ISUninstallProthesis:start()
    self.item:setJobType("Uninstall prothesis");
    self.item:setJobDelta(0.0);
    self:setActionAnim("WearClothing");
    if self.item:IsClothing() then
        self:setAnimVariable("WearClothingLocation", "Jacket")
    elseif self.item:IsInventoryContainer() and self.item:canBeEquipped() ~= "" then
        self:setAnimVariable("WearClothingLocation", "Jacket")
    end
end

function ISUninstallProthesis:stop()
    ISBaseTimedAction.stop(self);
    self.item:setJobDelta(0.0);
end

function ISUninstallProthesis:perform()
    self.item:getContainer():setDrawDirty(true);
    self.item:setJobDelta(0.0);
    if instanceof(self.item, "InventoryContainer") and self.item:canBeEquipped() ~= "" then
        self.character:removeFromHands(self.item);
        self.character:setWornItem(self.item:canBeEquipped(), self.item);
        getPlayerInventory(self.character:getPlayerNum()):refreshBackpacks();
    elseif self.item:getCategory() == "Clothing" then
        if self.item:getBodyLocation() ~= "" then
            self.character:setWornItem(self.item:getBodyLocation(), self.item);
        end
    end

    local modData = self.character:getModData()
    if self.bodyPart:getType() == BodyPartType.Hand_R then
        modData.TOC.RightHand.IsEquiped = false;
        modData.TOC.RightHand.EquipFact = 1;
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_R then
        modData.TOC.RightForearm.IsEquiped = false;
        modData.TOC.RightForearm.EquipFact = 1;
    elseif self.bodyPart:getType() == BodyPartType.Hand_L then
        modData.TOC.LeftHand.IsEquiped = false;
        modData.TOC.LeftHand.EquipFact = 1;
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_L then
        modData.TOC.LeftForearm.IsEquiped = false;
        modData.TOC.LeftForearm.EquipFact = 1;
    end

    local weight = math.floor(self.item:getWeight() * 10 + 0.5)
    if weight == 10 then
        self.character:getInventory():AddItem("TOC.WoodenHook")
    elseif weight == 5 then
        self.character:getInventory():AddItem("TOC.MetalHook")
    elseif weight == 3 then
        self.character:getInventory():AddItem("TOC.MetalHand")
    elseif weight == 20 then
        self.character:getInventory():AddItem("TOC.WoodenHook")
    elseif weight == 15 then
        self.character:getInventory():AddItem("TOC.MetalHook")
    elseif weight == 12 then
        self.character:getInventory():AddItem("TOC.MetalHand")
    end

    self.character:setWornItem(self.item:getBodyLocation(), nil);
    self.character:getInventory():Remove(self.item);
    self.character:transmitModData();

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ISUninstallProthesis:new(character, item, bodyPart)
    local o = ISBaseTimedAction.new(self, character);
    o.item = item;
    o.character = character;
    o.bodyPart = bodyPart;
    o.maxTime = 100;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.ignoreHandsWounds = false;
    o.fromHotbar = true; -- just to disable hotbar:update() during the wearing
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end
