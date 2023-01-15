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
end

function ISCutLimb:start()

    self:setActionAnim("SawLog")
    local saw_item = GetSawInInventory(self.surgeon)

    if saw_item then
        self:setOverrideHandModels(saw_item:getStaticModel(), nil)

    end



    -- TODO this doesn't work when doing it on another player
    local body_part_type = TocGetBodyPartTypeFromBodyPart(self.part_name)
    local body_damage = self.patient:getBodyDamage()
    local body_damage_part = body_damage:getBodyPart(body_part_type)


    body_damage_part:setBleeding(true)
    body_damage_part:setCut(true)
    body_damage_part:setBleedingTime(ZombRand(10,20))


    -- TODO Make the object currently on the hand return to the inventory

end


function ISCutLimb:findArgs()
    local surgeon_factor = self.surgeon:getPerkLevel(Perks.Doctor)
    if self.surgeon:getDescriptor():getProfession() == "surgeon" then surgeon_factor = surgeon_factor + 15 end
    if self.surgeon:getDescriptor():getProfession() == "doctor" then surgeon_factor = surgeon_factor + 9 end
    if self.surgeon:getDescriptor():getProfession() == "nurse" then surgeon_factor = surgeon_factor + 4 end

    local bandage_table = {
        use_bandage = false,
        bandage_type = nil,
        is_bandage_sterilized = nil}
    local painkiller_table = {}

    
    local bandage = self.surgeon:getInventory():FindAndReturn('Bandage')
    local sterilized_bandage = self.surgeon:getInventory():FindAndReturn('AlcoholBandage')

    if sterilized_bandage then
        bandage_table.bandage_type = sterilized_bandage:getType()
        bandage_table.is_bandage_sterilized = true
        bandage_table.use_bandage = true
        self.surgeon:getInventory():Remove(sterilized_bandage)
        surgeon_factor = surgeon_factor + 4
    elseif bandage then
        bandage_table.bandage_type = bandage:getType()
        bandage_table.is_bandage_sterilized = false
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
    else
        TheOnlyCure.CutLimb(self.part_name, surgeon_factor, bandage_table, painkiller_table)
    end

    if self.patient ~= self.surgeon and isClient() then
        SendCutLimb(self.patient, self.part_name, surgeon_factor, bandage_table, painkiller_table)
    else
        TheOnlyCure.CutLimb(self.part_name, surgeon_factor, bandage_table, painkiller_table)
    end


    self.surgeon:getXp():AddXP(Perks.Doctor, 400);

    ISBaseTimedAction.perform(self);

end


function ISCutLimb:new(patient, surgeon, part_name)
    local o = {}
    setmetatable(o, self)
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