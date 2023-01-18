require "TimedActions/ISBaseTimedAction"

ISInstallProsthesis = ISBaseTimedAction:derive("ISInstallProsthesis");

function ISInstallProsthesis:isValid()
    return true
end

function ISInstallProsthesis:update()
    self.item:setJobDelta(self:getJobDelta())
end

function ISInstallProsthesis:start()
    self.item:setJobType("Install prosthesis")
    self.item:setJobDelta(0.0)
    self:setActionAnim("WearClothing")
    self:setAnimVariable("WearClothingLocation", "Jacket")
end

function ISInstallProsthesis:stop()
    ISBaseTimedAction.stop(self)
    self.item:setJobDelta(0.0)
end

function ISInstallProsthesis:perform()



    local prosthesis_base_name = self.item:getType()



    self.item:setJobDelta(0.0)
    local toc_data = self.character:getModData().TOC
    local part_name = TocGetPartNameFromBodyPartType(self.bodyPart:getType())

    -- Check if can be performed. This shouldn't be necessary, but just to be sure
    if self.bodyPart:getType() == BodyPartType.UpperArm_L or self.bodyPart:getType() == BodyPartType.UpperArm_R then
        print("Can't equip prosthesis")
        return
    end

    local prosthesis_name = TocFindCorrectClothingProsthesis(prosthesis_base_name, part_name)
    self.cloth = self.character:getInventory():AddItem(prosthesis_name)

    if self.cloth ~= nil then


        if part_name then
            toc_data.Limbs[part_name].is_prosthesis_equipped = true       -- TODO should we show that the hand has a prost too if it's installed in the forearm?
            toc_data.Limbs[part_name].equipped_prosthesis = toc_data.Prosthesis[prosthesis_base_name][part_name]
            
            self.character:getInventory():Remove(self.item)
            self.character:setWornItem(self.cloth:getBodyLocation(), self.cloth)
        end


    end

    self.character:transmitModData()

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISInstallProsthesis:new(character, item, bodyPart)
    local o = ISBaseTimedAction.new(self, character)
    o.item = item
    o.bodyPart = bodyPart
    o.maxTime = 100
    o.stopOnWalk = true
    o.stopOnRun = true
    o.cloth = nil
    o.ignoreHandsWounds = false
    o.fromHotbar = true -- just to disable hotbar:update() during the wearing
    if o.character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end
