-- local DataController = require("TOC/Controllers/DataController")
-- local CommonMethods = require("TOC/CommonMethods")
-- --------------------

-- ---@class CleanWoundAction : ISBaseTimedAction
-- ---@field doctor IsoPlayer
-- ---@field patient IsoPlayer
-- ---@field bandage InventoryItem
-- ---@field bodyPart any
-- ---@field characterLevel number
-- ---@field bandagedPlayerX number
-- ---@field bandagedPlayerY number
-- local CleanWoundAction = ISBaseTimedAction:derive("CleanWoundAction")

-- ---@param character IsoPlayer doctor performing the action
-- ---@param patient IsoPlayer
-- ---@param bandage InventoryItem
-- ---@param bodyPart any
-- ---@return CleanWoundAction
-- function CleanWoundAction:new(character, patient, bandage, bodyPart)

--     local o = ISBaseTimedAction.new(self, character)

--     o.patient = patient
--     o.characterLevel = character:getPerkLevel(Perks.Doctor)
-- 	o.bodyPart = bodyPart
--     o.bandage = bandage
-- 	o.stopOnWalk = true
-- 	o.stopOnRun = true

--     o.bandagedPlayerX = patient:getX()
--     o.bandagedPlayerY = patient:getY()

--     o.maxTime = 250 - (o.characterLevel * 6)
--     if character:isTimedActionInstant() then
--         o.maxTime = 1
--     end
--     -- if doctor:getAccessLevel() ~= "None" then   -- B42 Deprecated
--     --     o.characterLevel = 10
--     -- end
-- 	return o
-- end
-- function CleanWoundAction:isValid()
-- 	if ISHealthPanel.DidPatientMove(self.character, self.patient, self.bandagedPlayerX, self.bandagedPlayerY) then
-- 		return false
-- 	end
-- 	return true
-- end

-- function CleanWoundAction:waitToStart()
--     if self.character == self.patient then
--         return false
--     end
--     self.character:faceThisObject(self.patient)
--     return self.character:shouldBeTurning()
-- end

-- function CleanWoundAction:update()
--     if self.character ~= self.patient then
--         self.character:faceThisObject(self.patient)
--     end
--     local jobType = getText("ContextMenu_CleanWound")
--     ISHealthPanel.setBodyPartActionForPlayer(self.patient, self.bodyPart, self, jobType, { cleanBurn = true })
--     self.character:setMetabolicTarget(Metabolics.LightDomestic)
-- end

-- function CleanWoundAction:start()
--     if self.character == self.patient then
--         self:setActionAnim(CharacterActionAnims.Bandage)
--         self:setAnimVariable("BandageType", ISHealthPanel.getBandageType(self.bodyPart))
--         self.character:reportEvent("EventBandage")
--     else
--         self:setActionAnim("Loot")
--         self.character:SetVariable("LootPosition", "Mid")
--         self.character:reportEvent("EventLootItem")
--     end
--     self:setOverrideHandModels(nil, nil)
-- end

-- function CleanWoundAction:stop()
--     ISHealthPanel.setBodyPartActionForPlayer(self.patient, self.bodyPart, nil, nil, nil)
--     ISBaseTimedAction.stop(self)
-- end

-- function CleanWoundAction:perform()

--     TOC_DEBUG.print("CleanWound for " .. self.patient:getUsername())

--     if self.character:hasTrait("Hemophobic") then
--         self.character:getStats():setPanic(self.character:getStats():getPanic() + 15)
--     end

--     self.character:getXp():AddXP(Perks.Doctor, 10)
--     local addPain = (60 - (self.characterLevel * 1))
--     self.bodyPart:setAdditionalPain(self.bodyPart:getAdditionalPain() + addPain)
--     self.bandage:Use()

--     -- TOC Data handling

--     local limbName = CommonMethods.GetLimbNameFromBodyPart(self.bodyPart)
--     local dcInst = DataController.GetInstance(self.patient:getUsername())

--     local currentWoundDirtyness = dcInst:getWoundDirtyness(limbName)
--     local newWoundDirtyness = currentWoundDirtyness - (self.bandage:getBandagePower() * 10)
--     if newWoundDirtyness < 0 then newWoundDirtyness = 0 end

--     dcInst:setWoundDirtyness(limbName, newWoundDirtyness)

--     dcInst:apply()

--     -- Clean visual
--     local bbptEnum = BloodBodyPartType[limbName]

--     ---@type HumanVisual
--     local visual = self.patient:getHumanVisual()
--     visual:setDirt(bbptEnum, 0)
--     visual:setBlood(bbptEnum, 0)

--     ISHealthPanel.setBodyPartActionForPlayer(self.patient, self.bodyPart, nil, nil, nil)

--     -- needed to remove from queue / start next.
--     ISBaseTimedAction.perform(self)
-- end

-- return CleanWoundAction