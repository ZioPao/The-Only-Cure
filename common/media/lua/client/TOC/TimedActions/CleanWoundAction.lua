local DataController = require("TOC/Controllers/DataController")
local CommonMethods = require("TOC/CommonMethods")
--------------------

---@class CleanWoundAction : ISBaseTimedAction
---@field doctor IsoPlayer
---@field otherPlayer IsoPlayer
---@field bandage InventoryItem
---@field bodyPart any
local CleanWoundAction = ISBaseTimedAction:derive("CleanWoundAction")

---@param doctor IsoPlayer
---@param otherPlayer IsoPlayer
---@param bandage InventoryItem
---@param bodyPart any
---@return CleanWoundAction
function CleanWoundAction:new(doctor, otherPlayer, bandage, bodyPart)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = doctor
    o.otherPlayer = otherPlayer
    o.doctorLevel = doctor:getPerkLevel(Perks.Doctor)
	o.bodyPart = bodyPart
    o.bandage = bandage
	o.stopOnWalk = true
	o.stopOnRun = true

    o.bandagedPlayerX = otherPlayer:getX()
    o.bandagedPlayerY = otherPlayer:getY()

    o.maxTime = 250 - (o.doctorLevel * 6)
    if doctor:isTimedActionInstant() then
        o.maxTime = 1
    end
    if doctor:getAccessLevel() ~= "None" then       -- TODO Fix for B42
        o.doctorLevel = 10
    end
	return o
end
function CleanWoundAction:isValid()
	if ISHealthPanel.DidPatientMove(self.character, self.otherPlayer, self.bandagedPlayerX, self.bandagedPlayerY) then
		return false
	end
	return true
end

function CleanWoundAction:waitToStart()
    if self.character == self.otherPlayer then
        return false
    end
    self.character:faceThisObject(self.otherPlayer)
    return self.character:shouldBeTurning()
end

function CleanWoundAction:update()
    if self.character ~= self.otherPlayer then
        self.character:faceThisObject(self.otherPlayer)
    end
    local jobType = getText("ContextMenu_CleanWound")
    ISHealthPanel.setBodyPartActionForPlayer(self.otherPlayer, self.bodyPart, self, jobType, { cleanBurn = true })
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function CleanWoundAction:start()
    if self.character == self.otherPlayer then
        self:setActionAnim(CharacterActionAnims.Bandage)
        self:setAnimVariable("BandageType", ISHealthPanel.getBandageType(self.bodyPart))
        self.character:reportEvent("EventBandage")
    else
        self:setActionAnim("Loot")
        self.character:SetVariable("LootPosition", "Mid")
        self.character:reportEvent("EventLootItem")
    end
    self:setOverrideHandModels(nil, nil)
end

function CleanWoundAction:stop()
    ISHealthPanel.setBodyPartActionForPlayer(self.otherPlayer, self.bodyPart, nil, nil, nil)
    ISBaseTimedAction.stop(self)
end

function CleanWoundAction:perform()

    TOC_DEBUG.print("CleanWound for " .. self.otherPlayer:getUsername())

    if self.character:HasTrait("Hemophobic") then
        self.character:getStats():setPanic(self.character:getStats():getPanic() + 15)
    end

    self.character:getXp():AddXP(Perks.Doctor, 10)
    local addPain = (60 - (self.doctorLevel * 1))
    self.bodyPart:setAdditionalPain(self.bodyPart:getAdditionalPain() + addPain)
    self.bandage:Use()

    -- TOC Data handling

    local limbName = CommonMethods.GetLimbNameFromBodyPart(self.bodyPart)
    local dcInst = DataController.GetInstance(self.otherPlayer:getUsername())

    local currentWoundDirtyness = dcInst:getWoundDirtyness(limbName)
    local newWoundDirtyness = currentWoundDirtyness - (self.bandage:getBandagePower() * 10)
    if newWoundDirtyness < 0 then newWoundDirtyness = 0 end

    dcInst:setWoundDirtyness(limbName, newWoundDirtyness)

    dcInst:apply()

    -- Clean visual
    local bbptEnum = BloodBodyPartType[limbName]

    ---@type HumanVisual
    local visual = self.otherPlayer:getHumanVisual()
    visual:setDirt(bbptEnum, 0)
    visual:setBlood(bbptEnum, 0)

    ISHealthPanel.setBodyPartActionForPlayer(self.otherPlayer, self.bodyPart, nil, nil, nil)

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

return CleanWoundAction