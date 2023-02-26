require "TimedActions/ISBaseTimedAction"

JCIO_OperateLimbAction = ISBaseTimedAction:derive("JCIO_OperateLimbAction")

function JCIO_OperateLimbAction:isValid()
    return self.patientX == self.patient:getX() and self.patientY == self.patient:getY()
end

function JCIO_OperateLimbAction:waitToStart()
    if self.patient == self.surgeon then
        return false
    end
    self.surgeon:faceThisObject(self.patient)
    return self.surgeon:shouldBeTurning()
end

function JCIO_OperateLimbAction:update()
    if self.patient ~= self.surgeon then
        self.surgeon:faceThisObject(self.patient)
    end
end

function JCIO_OperateLimbAction:start()
    self:setActionAnim("MedicalCheck")
    if self.useOven then
        self.sound = self.patient:getEmitter():playSound("Burn_sound")
        self:forceComplete()
    end
end

function JCIO_OperateLimbAction:findArgs()
    local surgeonFactor = self.surgeon:getPerkLevel(Perks.Doctor)

    if self.useOven then
        surgeonFactor = surgeonFactor + 100
    else
        if self.kit then
            local weight = math.floor(self.kit:getWeight() * 10 + 0.5)
            if weight == 1 then
                surgeonFactor = surgeonFactor + 2
            elseif weight == surgeonFactor then
                surgeonFactor = surgeonFactor + 4
            elseif weight == 3 then
                surgeonFactor = surgeonFactor + 6
            end
        end

        if self.surgeon:getDescriptor():getProfession() == "surgeon" then surgeonFactor = surgeonFactor + 10 end
        if self.surgeon:getDescriptor():getProfession() == "doctor" then surgeonFactor = surgeonFactor + 5 end
        if self.surgeon:getDescriptor():getProfession() == "nurse" then surgeonFactor = surgeonFactor + 2 end
    end

    return surgeonFactor, self.useOven;
end

function JCIO_OperateLimbAction:perform()
    local surgeonFactor, useOven = self:findArgs()

    if self.patient ~= self.surgeon and isClient() then
        SendOperateLimb(self.patient, self.partName, surgeonFactor, useOven)
    else
        JCIO.OperateLimb(self.partName, surgeonFactor, useOven)
    end
    self.surgeon:getXp():AddXP(Perks.Doctor, 400)

    if self.kit and not useOven then
        self.surgeon:getInventory():Remove(self.kit)
    end

    ISBaseTimedAction.perform(self)
end

function JCIO_OperateLimbAction:new(patient, surgeon, kit, partName, useOven)
    local o = ISBaseTimedAction.new(self, patient)
    o.partName = partName
    o.patient = patient
    o.character = surgeon -- For anim
    o.patientX = patient:getX()
    o.patientY = patient:getY()
    o.surgeon = surgeon
    o.kit = kit

    o.useOven = useOven


    --o.useOven = useOven;
    if useOven then
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
