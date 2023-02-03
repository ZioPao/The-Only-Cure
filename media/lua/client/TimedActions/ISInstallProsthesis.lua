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
    -- local toc_data = self.character:getModData().TOC
    --local part_name = TocGetPartNameFromBodyPartType(self.bodyPart:getType())

    local body_part_type = TocGetBodyPartFromPartName(self.part_name)

    -- Check if can be performed. This shouldn't be necessary, but just to be sure
    if body_part_type == BodyPartType.UpperArm_L or body_part_type == BodyPartType.UpperArm_R then
        print("Can't equip prosthesis")
        return
    end

    self.surgeon:getInventory():Remove(prosthesis_base_name)         -- Removes the base item and substitute it with the part one


    if self.patient ~= self.surgeon and isClient() then

        SendEquipProsthesis(self.patient, self.part_name, prosthesis_base_name)
    else
        TocEquipProsthesis(self.part_name, prosthesis_base_name)

    end

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISInstallProsthesis:new(surgeon, patient, item, part_name)

    local o = ISBaseTimedAction.new(self, patient)

    o.character = surgeon -- For animation, since self.startAnim or whatever relies on this
    o.surgeon = surgeon
    o.patient = patient

    o.item = item

    o.part_name = part_name

    --o.bodyPart = bodyPart
    o.maxTime = 100
    o.stopOnWalk = true
    o.stopOnRun = true
    o.cloth = nil
    o.ignoreHandsWounds = false
    o.fromHotbar = true -- just to disable hotbar:update() during the wearing
    if o.character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end
