require "TimedActions/ISBaseTimedAction"

ISOperateArm = ISBaseTimedAction:derive("ISOperateArm");

function ISOperateArm:isValid()
    return self.patientX == self.patient:getX() and self.patientY == self.patient:getY();
end

function ISOperateArm:waitToStart()
    if self.patient == self.surgeon then
        return false
    end
    self.surgeon:faceThisObject(self.patient)
    return self.surgeon:shouldBeTurning()
end

function ISOperateArm:update()
    if self.patient ~= self.surgeon then
        self.surgeon:faceThisObject(self.patient)
    end
end

function ISOperateArm:start()
    self:setActionAnim("MedicalCheck");
    if self.UseOven then
        self.sound = self.patient:getEmitter():playSound("Burn_sound")
        self:forceComplete();
    end
end

function ISOperateArm:findArgs()
    local surgeonFact = self.surgeon:getPerkLevel(Perks.Doctor);

    if self.UseOven then 
        surgeonFact = surgeonFact + 100;
    else
        if self.kit then
            local weight = math.floor(self.kit:getWeight() * 10 + 0.5)
            if weight == 1 then
                surgeonFact = surgeonFact + 2;
            elseif weight == surgeonFact then
                surgeonFact = surgeonFact + 4;
            elseif weight == 3 then
                surgeonFact = surgeonFact + 6;
            end
        end
    
        if self.surgeon:getDescriptor():getProfession() == "surgeon" then surgeonFact = surgeonFact + 10 end
        if self.surgeon:getDescriptor():getProfession() == "doctor" then surgeonFact = surgeonFact + 5 end
        if self.surgeon:getDescriptor():getProfession() == "nurse" then surgeonFact = surgeonFact + 2 end
    end

    return surgeonFact, self.useOven;
end

function ISOperateArm:perform()
    local surgeonFact, useOven = self:findArgs();

    if self.patient ~= self.surgeon and isClient() then
        SendOperateArm(self.patient, self.partName, surgeonFact, useOven);
    else
        OperateArm(self.partName, surgeonFact, useOven);
    end
    self.surgeon:getXp():AddXP(Perks.Doctor, 400);
    if self.kit then
        self.surgeon:getInventory():Remove(self.kit);
    end

    ISBaseTimedAction.perform(self);
end

function ISOperateArm:new(patient, surgeon, kit, partName, UseOven)
    local o = ISBaseTimedAction.new(self, patient);
    o.partName = partName;
    o.patient = patient;
    o.character = surgeon; -- For anim
    o.patientX = patient:getX();
    o.patientY = patient:getY();
    o.surgeon = surgeon;
    o.kit = kit;
    o.UseOven = UseOven;
    if UseOven then o.maxTime = 30 else o.maxTime = 200 - (surgeon:getPerkLevel(Perks.Doctor) * 10) end
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.ignoreHandsWounds = false;
    o.fromHotbar = true;
    if o.patient:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end
