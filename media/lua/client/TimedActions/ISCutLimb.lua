require "TimedActions/ISBaseTimedAction"

ISCutLimb = ISBaseTimedAction:derive("ISCutLimb")

-- TODO Add a check so you can't cut your arm if you don't have hands or if you only have one arm and want to cut that same arm.

function ISCutLimb:isValid()
    return self.patientX == self.patient:getX() and self.patientY == self.patient:getY()
end

function ISCutLimb:waitToStart()
    if self.patient == self.surgeon then
        return false
    end
    self.surgeon:faceThisObject(self.patient)
    return self.surgeon:shouldBeTurning()
end

function ISCutLimb:update()
    if self.patient ~= self.surgeon then
        self.surgeon:faceThisObject(self.patient)
    end


    -- Sound handling
    if self.soundTime < getTimestamp() then
        self.soundTime = getTimestamp()

        if not self.character:getEmitter():isPlaying(self.sawSound) then
            --print("TOC: Running sound again")
            self.sawSound = self.character:getEmitter():playSound("Amputation_Sound")
            addSound(self.surgeon, self.surgeon:getX(), self.surgeon:getY(), self.surgeon:getZ(), 3, 3)
        end
    end






end

function ISCutLimb:stop()

    if self.sawSound and self.sawSound ~= 0 and self.surgeon:getEmitter():isPlaying(self.sawSound) then
        self.surgeon:getEmitter():stopSound(self.sawSound)
    end

end




function ISCutLimb:start()

    self:setActionAnim("SawLog")
    local saw_item = TocGetSawInInventory(self.surgeon)

	self.soundTime = 0
    self.worldSoundTime = 0
    self.sawSound = self.surgeon:getEmitter():playSound("Amputation_Sound")


    -- Return whatever object we've got in the inventory
    if self.surgeon:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(self.surgeon, self.surgeon:getPrimaryHandItem(), 2));
    end
    if self.surgeon:getSecondaryHandItem() and self.surgeon:getSecondaryHandItem() ~= self.surgeon:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(self.surgeon, self.surgeon:getSecondaryHandItem(), 2));
    end

    if saw_item then
        self:setOverrideHandModels(saw_item:getStaticModel(), nil)

    end

    if self.patient == self.surgeon then
        TocDamagePlayerDuringAmputation(self.patient, self.part_name)
    else
        sendClientCommand(self.surgeon, "TOC", "AskDamageOtherPlayer", {self.patient:getOnlineID(), self.part_name})
    end





end

function ISCutLimb:findArgs()
    local surgeon_factor = self.surgeon:getPerkLevel(Perks.Doctor)
    if self.surgeon:getDescriptor():getProfession() == "surgeon" then surgeon_factor = surgeon_factor + 15 end
    if self.surgeon:getDescriptor():getProfession() == "doctor" then surgeon_factor = surgeon_factor + 9 end
    if self.surgeon:getDescriptor():getProfession() == "nurse" then surgeon_factor = surgeon_factor + 4 end

    local bandage_table = {
        use_bandage = false,
        bandage_type = nil,
        is_bandage_sterilized = nil
    }
    local painkiller_table = {}


    local bandage = self.surgeon:getInventory():FindAndReturn('Bandage')
    local sterilized_bandage = self.surgeon:getInventory():FindAndReturn('AlcoholBandage')
    --local ripped_sheets = self.surgeon:getInventory():FindAndReturn("...")

    if sterilized_bandage then
        bandage_table.bandage_type = sterilized_bandage:getType()
        bandage_table.is_bandage_sterilized = true
        bandage_table.use_bandage = true
        self.surgeon:getInventory():Remove(sterilized_bandage)
        surgeon_factor = surgeon_factor + 4
    elseif bandage then
        bandage_table.bandage_type = bandage:getType()
        bandage_table.is_bandage_sterilized = false
        bandage_table.use_bandage = true
        self.surgeon:getInventory():Remove(bandage)
        surgeon_factor = surgeon_factor + 2
    else
        bandage_table.bandage_type = ""
        bandage_table.use_bandage = false
        bandage_table.is_bandage_sterilized = false
    end



    -- local painkiller = self.surgeon:getInventory():FindAndReturn('Pills');
    -- if painkiller then
    --     usePainkiller = true;
    --     painkillerCount = painkiller:getRemainingUses();
    -- end

    return surgeon_factor, bandage_table, painkiller_table
end

function ISCutLimb:perform()
    local surgeon_factor, bandage_table, painkiller_table = self:findArgs()

    if self.patient ~= self.surgeon and isClient() then
        SendCutLimb(self.patient, self.part_name, surgeon_factor, bandage_table, painkiller_table)
        sendClientCommand(self.surgeon, "TOC", "AskStopAmputationSound", {surgeon_id = self.surgeon:getOnlineID()})
    else
        TocCutLimb(self.part_name, surgeon_factor, bandage_table, painkiller_table)
    end

    self.surgeon:getEmitter():stopSoundByName("Amputation_Sound")
    self.surgeon:getXp():AddXP(Perks.Doctor, 400)
    ISBaseTimedAction.perform(self)

end

function ISCutLimb:new(patient, surgeon, part_name)

    -- TODO align surgeon, patient not patient, surgeon


    local o = {}
    setmetatable(o, self)           -- TODO what's this crap?
    self.__index = self
    o.part_name = part_name
    o.character = surgeon -- For anim

    o.surgeon = surgeon; -- Surgeon or player that make the operation
    o.patient = patient; -- Player to amputate

    o.patientX = patient:getX()
    o.patientY = patient:getY()

    o.maxTime = 1000 - (surgeon:getPerkLevel(Perks.Doctor) * 50)
    o.stopOnWalk = true
    o.stopOnRun = true
    o.ignoreHandsWounds = false
    o.fromHotbar = true
    if o.patient:isTimedActionInstant() then o.maxTime = 1 end
    return o
end
