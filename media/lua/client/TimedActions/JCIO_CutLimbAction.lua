------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------

require "TimedActions/ISBaseTimedAction"

TOC_CutLimbAction = ISBaseTimedAction:derive("TOC_CutLimbAction")


function TOC_CutLimbAction:isValid()
    return self.patientX == self.patient:getX() and self.patientY == self.patient:getY()
end

function TOC_CutLimbAction:waitToStart()
    if self.patient == self.surgeon then
        return false
    end
    self.surgeon:faceThisObject(self.patient)
    return self.surgeon:shouldBeTurning()
end

function TOC_CutLimbAction:update()
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

function TOC_CutLimbAction:stop()

    --print("Stopping ISCutLimb")

    -- Handles sound
    if self.sawSound and self.sawSound ~= 0 and self.surgeon:getEmitter():isPlaying(self.sawSound) then
        self.surgeon:getEmitter():stopSound(self.sawSound)
    end


    -- TODO test this with more than 2 players
    -- TODO this gets bugged when player dies while amputating


end




function TOC_CutLimbAction:start()
    -- TODO Add a check so you can't cut your arm if you don't have hands or if you only have one arm and want to cut that same arm.

    self:setActionAnim("SawLog")
    local sawItem = TOC_Common.GetSawInInventory(self.surgeon)

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
        TOC.DamagePlayerDuringAmputation(self.patient, self.partName)
    else
        sendClientCommand(self.surgeon, "TOC", "AskDamageOtherPlayer", {self.patient:getOnlineID(), self.partName})
    end





end

function TOC_CutLimbAction:findArgs()
    local surgeonFactor = self.surgeon:getPerkLevel(Perks.Doctor)
    if self.surgeon:getDescriptor():getProfession() == "surgeon" then surgeonFactor = surgeonFactor + 15 end
    if self.surgeon:getDescriptor():getProfession() == "doctor" then surgeonFactor = surgeonFactor + 9 end
    if self.surgeon:getDescriptor():getProfession() == "nurse" then surgeonFactor = surgeonFactor + 4 end

    local bandageTable = {
        useBandage = false,
        bandageType = nil,
        isBandageSterilized = nil
    }
    local painkiller_table = {}


    local bandage = self.surgeon:getInventory():FindAndReturn('Bandage')
    local sterilizedBandage = self.surgeon:getInventory():FindAndReturn('AlcoholBandage')
    --local ripped_sheets = self.surgeon:getInventory():FindAndReturn("...")

    if sterilizedBandage then
        bandageTable.bandageType = sterilizedBandage:getType()
        bandageTable.isBandageSterilized = true
        bandageTable.useBandage = true
        self.surgeon:getInventory():Remove(sterilizedBandage)
        surgeonFactor = surgeonFactor + 4
    elseif bandage then
        bandageTable.bandageType = bandage:getType()
        bandageTable.isBandageSterilized = false
        bandageTable.useBandage = true
        self.surgeon:getInventory():Remove(bandage)
        surgeonFactor = surgeonFactor + 2
    else
        bandageTable.bandageType = ""
        bandageTable.useBandage = false
        bandageTable.isBandageSterilized = false
    end



    -- local painkiller = self.surgeon:getInventory():FindAndReturn('Pills');
    -- if painkiller then
    --     usePainkiller = true;
    --     painkillerCount = painkiller:getRemainingUses();
    -- end

    return surgeonFactor, bandageTable, painkiller_table
end

function TOC_CutLimbAction:perform()
    local surgeonFactor, bandageTable, painkillerTable = self:findArgs()

    if self.patient ~= self.surgeon and isClient() then
        SendCutLimb(self.patient, self.partName, surgeonFactor, bandageTable, painkillerTable)
        sendClientCommand(self.surgeon, "TOC", "AskStopAmputationSound", {surgeonID = self.surgeon:getOnlineID()})
    else
        TOC.CutLimb(self.partName, surgeonFactor, bandageTable, painkillerTable)
    end

    self.surgeon:getEmitter():stopSoundByName("Amputation_Sound")
    self.surgeon:getXp():AddXP(Perks.Doctor, 400)
    ISBaseTimedAction.perform(self)

end

function TOC_CutLimbAction:new(patient, surgeon, partName)

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
