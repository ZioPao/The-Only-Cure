require "TimedActions/ISBaseTimedAction"

ISUninstallProsthesis = ISBaseTimedAction:derive("ISUninstallProsthesis");

function ISUninstallProsthesis:isValid()
    return true;
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

    local toc_data = self.character:getModData().TOC
    local body_part_type = self.bodyPart:getType()
    local accepting_body_parts = GetAcceptingProsthesisBodyParts()

    if accepting_body_parts == nil then
        return      -- should never happen
    end

    --if accepting_body_parts[body_part_type] then
    --    toc_data[TOC_getBodyPart(body_part_type)]
    --end




    if self.bodyPart:getType() == BodyPartType.Hand_R then
        toc_data.RightHand.is_prosthesis_equipped = false
        toc_data.RightHand.prothesis_factor = 1
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_R then
        toc_data.RightForearm.is_prosthesis_equipped = false
        toc_data.RightForearm.prothesis_factor = 1
    elseif self.bodyPart:getType() == BodyPartType.Hand_L then
        toc_data.LeftHand.is_prosthesis_equipped = false
        toc_data.LeftHand.prothesis_factor = 1
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_L then
        toc_data.LeftForearm.is_prosthesis_equipped = false
        toc_data.LeftForearm.prothesis_factor = 1
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

    self.character:setWornItem(self.item:getBodyLocation(), nil)
    self.character:getInventory():Remove(self.item)
    self.character:transmitModData()

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ISUninstallProsthesis:new(character, item, bodyPart)
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
