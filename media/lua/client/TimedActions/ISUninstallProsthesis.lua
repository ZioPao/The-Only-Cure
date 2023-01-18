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
    local accepting_body_parts = GetAcceptingProsthesisBodyPartTypes()

    if accepting_body_parts == nil then
        return      -- should never happen
    end

    for _, v in ipairs(GetAcceptingProsthesisBodyPartTypes()) do
        if self.bodyPart:getType() == v then
            local part_name = FindTocBodyPartNameFromBodyPartType(v)

            print("Found prost in " .. part_name)
            if part_name then 
                toc_data.Limbs[part_name].is_prosthesis_equipped = false
                --toc_data.Limbs[part_name].prosthesis_factor = 1         -- TODO This is wrong
    
                --local side = string.gsub(part_name, "Hand" or "Forearm", "")
                local item_full_type = self.item:getFullType()
                print("Searching for " .. item_full_type)
                for _, prost_v in ipairs(GetProsthesisList()) do
                    local prosthesis_name = string.match(item_full_type, prost_v)

                    if prosthesis_name then
                        self.character:getInventory():AddItem(prosthesis_name)

                        self.character:setWornItem(self.item:getBodyLocation(), nil)
                        self.character:getInventory():Remove(self.item)
                        self.character:transmitModData()
                    
                        -- needed to remove from queue / start next.
                        ISBaseTimedAction.perform(self)
                        
                    end
                end

            end









        end
    end

    -- TODO Make the object currently on the hand return to the inventory

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


