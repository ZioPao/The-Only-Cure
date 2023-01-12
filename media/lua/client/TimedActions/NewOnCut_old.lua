-- require "TimedActions/ISBaseTimedAction"

-- IsCutArm = ISBaseTimedAction:derive("IsCutArm");

-- function IsCutArm:isValid()
--     return self.patientX == self.patient:getX() and self.patientY == self.patient:getY();
-- end

-- function IsCutArm:waitToStart()
--     if self.patient == self.surgeon then
--         return false
--     end
--     self.surgeon:faceThisObject(self.patient)
--     return self.surgeon:shouldBeTurning()
-- end

-- function IsCutArm:update()
--     if self.patient ~= self.surgeon then
--         self.surgeon:faceThisObject(self.patient)
--     end
-- end

-- function IsCutArm:start()
--     if self.patient == self.surgeon then
--         self:setActionAnim("WearClothing");
--         self:setAnimVariable("WearClothingLocation", "Jacket")
--     else
--         self:setActionAnim("Loot")
--         self.patient:SetVariable("LootPosition", "Mid")
--     end
-- end

-- function IsCutArm:findArgs()
--     local useBandage, bandageAlcool, usePainkiller, painkillerCount
--     local surgeonFact = self.surgeon:getPerkLevel(Perks.Doctor);
--     if self.surgeon:getDescriptor():getProfession() == "surgeon" then surgeonFact = surgeonFact + 15 end
--     if self.surgeon:getDescriptor():getProfession() == "doctor" then surgeonFact = surgeonFact + 9 end
--     if self.surgeon:getDescriptor():getProfession() == "nurse" then surgeonFact = surgeonFact + 4 end

--     local bandage = self.surgeon:getInventory():FindAndReturn('Bandage');
--     local albandage = self.surgeon:getInventory():FindAndReturn('AlcoholBandage');
--     if albandage then
--         useBandage = true;
--         bandageAlcool = true;
--         self.patient:getInventory():Remove(albandage);
--         surgeonFact = surgeonFact + 4
--     elseif bandage then
--         useBandage = true;
--         self.patient:getInventory():Remove(bandage);
--         surgeonFact = surgeonFact + 2
--     end

--     local painkiller = self.surgeon:getInventory():FindAndReturn('Pills');
--     if painkiller then
--         usePainkiller = true;
--         painkillerCount = painkiller:getRemainingUses();
--     end

--     return surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount;
-- end

-- function IsCutArm:perform()
--     local surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount = self:findArgs();

--     if self.patient ~= self.surgeon and isClient() then
--         SendCutArm(self.patient, self.partName, surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount);
--     else
--         CutArm(self.partName, surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount);
--     end
--     self.surgeon:getXp():AddXP(Perks.Doctor, 400);

--     ISBaseTimedAction.perform(self);
-- end

-- function IsCutArm:new(patient, surgeon, partName)
--     local o = {}
--     setmetatable(o, self)
--     self.__index = self
--     o.partName = partName;
--     o.bodyPart = TOC_getBodyPart(partName);
--     o.character = surgeon; -- For anim

--     o.surgeon = surgeon; -- Surgeon or player that make the operation
--     o.patient = patient; -- Player to cut

--     o.patientX = patient:getX();
--     o.patientY = patient:getY();

--     o.maxTime = 1000 - (surgeon:getPerkLevel(Perks.Doctor) * 50);
--     o.stopOnWalk = true;
--     o.stopOnRun = true;
--     o.ignoreHandsWounds = false;
--     o.fromHotbar = true;
--     if o.patient:isTimedActionInstant() then o.maxTime = 1; end
--     return o;
-- end