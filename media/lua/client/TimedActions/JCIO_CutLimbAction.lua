------------------------------------------
------------- JUST CUT IT OFF ------------
------------------------------------------

require "TimedActions/ISBaseTimedAction"

JCIO_CutLimbAction = ISBaseTimedAction:derive("JCIO_CutLimbAction")


function JCIO_CutLimbAction:isValid()
    return self.patientX == self.patient:getX() and self.patientY == self.patient:getY()
end

function JCIO_CutLimbAction:waitToStart()
    if self.patient == self.surgeon then
        return false
    end
    self.surgeon:faceThisObject(self.patient)
    return self.surgeon:shouldBeTurning()
end

function JCIO_CutLimbAction:update()
    if self.patient ~= self.surgeon then
        self.surgeon:faceThisObject(self.patient)
    end


    local worldSoundRadius = 3

    local soundDelay = 6

    -- Sound handling
    if self.soundTime + soundDelay < getTimestamp() then

        self.soundTime = getTimestamp()

        if not self.chatacter:getEmitter():isPlaying(self.sawSound) then
            self.sawSound = self.character:getEmitter():playSound("Amputation_Sound")

        end



    end

    -- TODO This is to handle MP I guess?
    if worldSoundRadius > 0 then
        self.worldSoundTime = getTimestamp()
        addSound(self.surgeon, self.surgeon:getX(), self.surgeon:getY(), self.surgeon:getZ(), worldSoundRadius, worldSoundRadius)
    end
end

function JCIO_CutLimbAction:stop()

    print("Stopping ISCutLimb")

    -- Handles sound

    if self.sawSound and self.sawSound ~= 0 and self.surgeon:getEmitter():isPlaying(self.sawSound) then
        self.surgeon:getEmitter():stopSound(self.sawSound)
    end


    -- TODO test this with more than 2 players
    -- TODO this gets bugged when player dies while amputating


end




function JCIO_CutLimbAction:start()
    -- TODO Add a check so you can't cut your arm if you don't have hands or if you only have one arm and want to cut that same arm.

    self:setActionAnim("SawLog")
    local sawItem = JCIO_Common.GetSawInInventory(self.surgeon)

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

    if sawItem then
        self:setOverrideHandModels(sawItem:getStaticModel(), nil)

    end

    if self.patient == self.surgeon then
        JCIO.DamagePlayerDuringAmputation(self.patient, self.partName)
    else
        sendClientCommand(self.surgeon, "JCIO", "AskDamageOtherPlayer", {self.patient:getOnlineID(), self.partName})
    end





end

function JCIO_CutLimbAction:findArgs()
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

function JCIO_CutLimbAction:perform()
    local surgeon_factor, bandage_table, painkiller_table = self:findArgs()

    if self.patient ~= self.surgeon and isClient() then
        SendCutLimb(self.patient, self.partName, surgeon_factor, bandage_table, painkiller_table)
        sendClientCommand(self.surgeon, "JCIO", "AskStopAmputationSound", {surgeonID = self.surgeon:getOnlineID()})
    else
        JCIO.CutLimb(self.partName, surgeon_factor, bandage_table, painkiller_table)
    end

    self.surgeon:getEmitter():stopSoundByName("Amputation_Sound")
    self.surgeon:getXp():AddXP(Perks.Doctor, 400)
    ISBaseTimedAction.perform(self)

end

function JCIO_CutLimbAction:new(patient, surgeon, partName)

    -- TODO align surgeon, patient not patient, surgeon


    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.partName = partName
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
