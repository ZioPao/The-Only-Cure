require "TimedActions/ISBaseTimedAction"

TOC_InstallProsthesisAction = ISBaseTimedAction:derive("TOC_InstallProsthesisAction")

function TOC_InstallProsthesisAction:isValid()

    -- TODO add here conditions if the action can be performed or not, so if thing is in inventory
    -- TODO 'not sure about multiplayer, maybe an overriding check?
    return true
end

function TOC_InstallProsthesisAction:update()
    self.item:setJobDelta(self:getJobDelta())
end

function TOC_InstallProsthesisAction:start()
    self.item:setJobType("Install prosthesis")
    self.item:setJobDelta(0.0)

    self:setActionAnim("WearClothing")
    self:setAnimVariable("WearClothingLocation", "Jacket")

end

function TOC_InstallProsthesisAction:stop()
    ISBaseTimedAction.stop(self)
    self.item:setJobDelta(0.0)
end

function TOC_InstallProsthesisAction:perform()

    local prosthesisBaseName = self.item:getType()

    self.item:setJobDelta(0.0)
    -- local toc_data = self.character:getModData().TOC
    --local partName = TocGetPartNameFromBodyPartType(self.bodyPart:getType())

    local bodyPartType = TOC_Common.GetBodyPartFromPartName(self.partName)

    -- Check if can be performed. This shouldn't be necessary, but just to be sure
    if bodyPartType == BodyPartType.UpperArm_L or bodyPartType == BodyPartType.UpperArm_R then
        print("Can't equip prosthesis")
        return
    end



    if self.patient ~= self.surgeon and isClient() then

        SendEquipProsthesis(self.patient, self.partName, self.item, prosthesisBaseName)
    else
        TOC.EquipProsthesis(self.partName, self.item, prosthesisBaseName)

    end


    self.surgeon:getInventory():Remove(prosthesisBaseName)         -- Removes the base item after we transferred everything

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function TOC_InstallProsthesisAction:new(surgeon, patient, item, partName)

    local o = ISBaseTimedAction.new(self, patient)

    o.character = surgeon -- For animation, since self.startAnim or whatever relies on this
    o.surgeon = surgeon
    o.patient = patient

    o.item = item

    o.partName = partName

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
