require "TimedActions/ISBaseTimedAction"

ISOperateLimb = ISBaseTimedAction:derive("ISOperateLimb");

function ISOperateLimb:isValid()
    return self.patientX == self.patient:getX() and self.patientY == self.patient:getY();
end

function ISOperateLimb:waitToStart()
    if self.patient == self.surgeon then
        return false
    end
    self.surgeon:faceThisObject(self.patient)
    return self.surgeon:shouldBeTurning()
end

function ISOperateLimb:update()
    if self.patient ~= self.surgeon then
        self.surgeon:faceThisObject(self.patient)
    end
end

function ISOperateLimb:start()
    self:setActionAnim("MedicalCheck")
    if self.use_oven then
        self.sound = self.patient:getEmitter():playSound("Burn_sound")      -- TODO currently broken, but maybe that's good
        self:forceComplete()
    end
end

function ISOperateLimb:findArgs()
    local surgeon_factor = self.surgeon:getPerkLevel(Perks.Doctor)

    if self.use_oven then
        surgeon_factor = surgeon_factor + 100
    else
        if self.kit then
            local weight = math.floor(self.kit:getWeight() * 10 + 0.5)
            if weight == 1 then
                surgeon_factor = surgeon_factor + 2
            elseif weight == surgeon_factor then
                surgeon_factor = surgeon_factor + 4
            elseif weight == 3 then
                surgeon_factor = surgeon_factor + 6
            end
        end

        if self.surgeon:getDescriptor():getProfession() == "surgeon" then surgeon_factor = surgeon_factor + 10 end
        if self.surgeon:getDescriptor():getProfession() == "doctor" then surgeon_factor = surgeon_factor + 5 end
        if self.surgeon:getDescriptor():getProfession() == "nurse" then surgeon_factor = surgeon_factor + 2 end
    end

    return surgeon_factor, self.use_oven;
end

function ISOperateLimb:perform()
    local surgeon_factor, use_oven = self:findArgs()

    if self.patient ~= self.surgeon and isClient() then
        SendOperateLimb(self.patient, self.part_name, surgeon_factor, use_oven)
    else
        TocOperateLimb(self.part_name, surgeon_factor, use_oven)
    end
    self.surgeon:getXp():AddXP(Perks.Doctor, 400)

    -- FIXME Add a check for kit to prevent errors
    if self.kit and not use_oven then
        self.surgeon:getInventory():Remove(self.kit)
    end

    ISBaseTimedAction.perform(self)
end

function ISOperateLimb:new(patient, surgeon, kit, part_name, use_oven)
    local o = ISBaseTimedAction.new(self, patient)
    o.part_name = part_name
    o.patient = patient
    o.character = surgeon -- For anim
    o.patientX = patient:getX()
    o.patientY = patient:getY()
    o.surgeon = surgeon
    o.kit = kit

    o.use_oven = use_oven


    --o.use_oven = use_oven;
    if use_oven then
        o.maxTime = 30
    else
        o.maxTime = 200 - (surgeon:getPerkLevel(Perks.Doctor) * 10)
    end
    o.stopOnWalk = true
    o.stopOnRun = true
    o.ignoreHandsWounds = false
    o.fromHotbar = true
    if o.patient:isTimedActionInstant() then
        o.maxTime = 1
    end

    return o
end
