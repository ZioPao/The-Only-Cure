require "TimedActions/ISBaseTimedAction"
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local CommandsData = require("TOC/CommandsData")

-----------------------------

---@class CutLimbAction : ISBaseTimedAction
---@field patient IsoPlayer
---@field character IsoPlayer
---@field patientX number
---@field patientY number
---@field limbName string
---@field item InventoryItem
---@field stitchesItem InventoryItem?
---@field bandageItem InventoryItem?
local CutLimbAction = ISBaseTimedAction:derive("CutLimbAction")

---Starts CutLimbAction
---@param surgeon IsoPlayer This is gonna be self.character to have working animations
---@param patient IsoPlayer 
---@param limbName string
---@param item InventoryItem This is gonna be the saw, following ISBaseTimedAction
---@param stitchesItem InventoryItem?
---@param bandageItem InventoryItem?
---@return CutLimbAction
function CutLimbAction:new(surgeon, patient, limbName, item, stitchesItem, bandageItem)
    local o = ISBaseTimedAction.new(self, surgeon)

    -- We need to follow ISBaseTimedAction. self.character is gonna be the surgeon
    o.character = surgeon
    o.patient = patient
    o.limbName = limbName
    o.item = item

    o.patientX = patient:getX()
    o.patientY = patient:getY()

    o.stitchesItem = stitchesItem or nil
    o.bandageItem = bandageItem or nil

    o.stopOnWalk = true
    o.stopOnRun = true

    o.maxTime = o:getDuration()

    return o
end

function CutLimbAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    else
        local baseTime = 1000
        local perkLevel = self.character:getPerkLevel(Perks.Doctor)
        local finalTime = baseTime - (perkLevel * 50)
        TOC_DEBUG.print("finalTime = " .. finalTime)
        return finalTime
    end
end

function CutLimbAction:isValid()
    return not ISHealthPanel.DidPatientMove(self.character,self.patient, self.patientX, self.patientY)
end

function CutLimbAction:start()

    if isClient() then
        -- MP
        local params = {patientNum = self.patient:getOnlineID(), limbName = self.limbName}
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayDamageDuringAmputation, params)
    else
        AmputationHandler.ApplyDamageDuringAmputation(self.patient, self.limbName)
    end

    ---@type ISBaseTimedAction
    local prevAction = self

    -- Handle stitching
    if self.stitchesItem then
        TOC_DEBUG.print("Stitches...")
        prevAction = AmputationHandler.PrepareStitchesAction(prevAction, self.limbName, self.character, self.patient, self.stitchesItem)
    end

    -- Handle bandages
    if self.bandageItem then
        prevAction = AmputationHandler.PrepareBandagesAction(prevAction, self.limbName, self.character, self.patient, self.bandageItem)
    end

    -- Setup cosmetic stuff
    self:setActionAnim("SawLog")
    self:setOverrideHandModels(self.item:getStaticModel())

    -- Setup audio
    self.sound = self.character:getEmitter():playSound("Amputation")
    local radius = 5
    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), radius, radius)

end

-- function CutLimbAction:serverStart()

--     emulateAnimEvent(self.netAction, 200, "")

-- end

-- function CutLimbAction:animEvent(event, parameter)

-- end

function CutLimbAction:waitToStart()
    if self.character == self.patient then
        return false
    end
    self.character:faceThisObject(self.patient)
    return self.character:shouldBeTurning()
end

function CutLimbAction:update()
    self.character:setMetabolicTarget(Metabolics.HeavyWork)
    if self.character ~= self.patient then
        self.patient:setMetabolicTarget(Metabolics.HeavyWork)
    end
end

function CutLimbAction:stopSound()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
        self.sound = nil
    end
end

function CutLimbAction:stop()
	self:stopSound()
    ISBaseTimedAction.stop(self)
end

function CutLimbAction:perform()
    self:stopSound()
    if isClient() then
        -- MP
        local params = {patientNum = self.patient:getOnlineID(), limbName = self.limbName}
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayExecuteAmputationAction, params)
    else
        local handler = AmputationHandler:new(self.character, self.patient, self.limbName)
        handler:execute(true)
    end
    ISBaseTimedAction.perform(self)
end

return CutLimbAction