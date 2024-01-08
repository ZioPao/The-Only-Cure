local DataController = require("TOC/Controllers/DataController")
local CommonMethods = require("TOC/CommonMethods")
----

---@class CleanWoundAction : ISBaseTimedAction
local CleanWoundAction = ISBaseTimedAction:derive("CleanWoundAction")

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
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)

    if self.character:HasTrait("Hemophobic") then
        self.character:getStats():setPanic(self.character:getStats():getPanic() + 50)
    end

    self.character:getXp():AddXP(Perks.Doctor, 10)
    local addPain = (60 - (self.doctorLevel * 1))
    self.bodyPart:setAdditionalPain(self.bodyPart:getAdditionalPain() + addPain)
    --self.bodyPart:setNeedBurnWash(false)
    self.bandage:Use()

    -- TODO Use Water too

    if isClient() then
        --sendCleanBurn(self.character, self.otherPlayer, self.bodyPart, self.bandage)
    end

    local limbName = CommonMethods.GetLimbNameFromBodyPart(self.bodyPart)

    -- TODO CHeck if correct in MP
    local dcInst = DataController.GetInstance(self.otherPlayer:getUsername())
    dcInst:setWoundDirtyness(limbName, 0)


    -- Clean visual
    local bbptEnum = BloodBodyPartType[limbName]

    ---@type HumanVisual
    local visual = self.otherPlayer:getHumanVisual()
    visual:setDirt(bbptEnum, 0)
    visual:setBlood(bbptEnum, 0)

    ISHealthPanel.setBodyPartActionForPlayer(self.otherPlayer, self.bodyPart, nil, nil, nil)
end

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
    if doctor:getAccessLevel() ~= "None" then
        o.doctorLevel = 10
    end
	return o
end


return CleanWoundAction