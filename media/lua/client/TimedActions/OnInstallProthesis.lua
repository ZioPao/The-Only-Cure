require "TimedActions/ISBaseTimedAction"

ISInstallProthesis = ISBaseTimedAction:derive("ISInstallProthesis");

function ISInstallProthesis:isValid()
    return true;
end

function ISInstallProthesis:update()
    self.item:setJobDelta(self:getJobDelta());
end

function ISInstallProthesis:start()
    self.item:setJobType("Install prothesis");
    self.item:setJobDelta(0.0);
    self:setActionAnim("WearClothing");
    self:setAnimVariable("WearClothingLocation", "Jacket");
end

function ISInstallProthesis:stop()
    ISBaseTimedAction.stop(self);
    self.item:setJobDelta(0.0);
end

function ISInstallProthesis:perform()
    self.item:setJobDelta(0.0);

    local modData = self.character:getModData();

    local lor = 0
    local foh = 0

    if     self.bodyPart:getType() == BodyPartType.Hand_R then lor = 1; foh = 1
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_R then lor = 1; foh = 2
    elseif self.bodyPart:getType() == BodyPartType.Hand_L then lor = 0; foh = 1
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_L then lor = 0; foh = 2
    end

    local mat_id = 0
    local weight = math.floor(self.item:getWeight() * 10 + 0.5) / 10

    if weight == 1 and foh == 1 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_right_noHand");
            mat_id = 1;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_left_noHand");
            mat_id = 1;
        end
    elseif weight == 0.5 and foh == 1 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_right_noHand");
            mat_id = 2;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_left_noHand");
            mat_id = 2;
        end
    elseif weight == 0.3 and foh == 1 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_right_noHand");
            mat_id = 3;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_left_noHand");
            mat_id = 3;
        end
    elseif weight == 1 and foh == 2 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_right_noForearm");
            mat_id = 1;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_left_noForearm");
            mat_id = 1;
        end
    elseif weight == 0.5 and foh == 2  then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_right_noForearm");
            mat_id = 2;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_left_noForearm");
            mat_id = 2;
        end
    elseif weight == 0.3 and foh == 2 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_right_noForearm");
            mat_id = 3;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_left_noForearm");
            mat_id = 3;
        end
    end

    if self.cloth ~= nil then
        if self.bodyPart:getType() == BodyPartType.Hand_R then
            modData.TOC.RightHand.IsEquiped = true;
            modData.TOC.RightHand.Equip_mat_id = mat_id;
            modData.TOC.RightHand.EquipFact = find_protheseFact_TOC(self.cloth);
        elseif self.bodyPart:getType() == BodyPartType.ForeArm_R then
            modData.TOC.RightForearm.IsEquiped = true;
            modData.TOC.RightForearm.Equip_mat_id = mat_id;
            modData.TOC.RightForearm.EquipFact = find_protheseFact_TOC(self.cloth);
        elseif self.bodyPart:getType() == BodyPartType.Hand_L then
            modData.TOC.LeftHand.IsEquiped = true;
            modData.TOC.LeftHand.Equip_mat_id = mat_id;
            modData.TOC.LeftHand.EquipFact = find_protheseFact_TOC(self.cloth);
        elseif self.bodyPart:getType() == BodyPartType.ForeArm_L then
            modData.TOC.LeftForearm.IsEquiped = true;
            modData.TOC.LeftForearm.Equip_mat_id = mat_id;
            modData.TOC.LeftForearm.EquipFact = find_protheseFact_TOC(self.cloth);
        end

        self.character:getInventory():Remove(self.item);
        self.character:setWornItem(self.cloth:getBodyLocation(), self.cloth);
    end

    self.character:transmitModData()

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ISInstallProthesis:new(character, item, bodyPart)
    local o = ISBaseTimedAction.new(self, character);
    o.item = item;
    o.bodyPart = bodyPart;
    o.maxTime = 100;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.cloth = nil;
    o.ignoreHandsWounds = false;
    o.fromHotbar = true; -- just to disable hotbar:update() during the wearing
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end
