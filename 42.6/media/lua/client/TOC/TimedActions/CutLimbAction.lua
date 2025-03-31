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
    local o = {}
    setmetatable(o, self)
    self.__index = self

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

    o.maxTime = 1000 - (surgeon:getPerkLevel(Perks.Doctor) * 50)
    if o.character:isTimedActionInstant() then o.maxTime = 1 end

    return o
end

function CutLimbAction:isValid()
    return not ISHealthPanel.DidPatientMove(self.character,self.patient, self.patientX, self.patientY)
end

function CutLimbAction:start()
    if self.patient == self.character then
        -- Self
        AmputationHandler.ApplyDamageDuringAmputation(self.patient, self.limbName)
    else
        -- Another player
        ---@type relayDamageDuringAmputationParams
        local params = {patientNum = self.patient:getOnlineID(), limbName = self.limbName}
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayDamageDuringAmputation, params )
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
    -- Stop the sound
    self:stopSound()

    if self.patient == self.character then
        TOC_DEBUG.print("patient and surgeon are the same, executing on the client")
        local handler = AmputationHandler:new(self.limbName)
        handler:execute(true)
    else
        TOC_DEBUG.print("patient and surgeon not the same, sending relay to server")
        -- Other player
        ---@type relayExecuteAmputationActionParams
        local params = {patientNum = self.patient:getOnlineID(), limbName = self.limbName}
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayExecuteAmputationAction, params )
    end

    ISBaseTimedAction.perform(self)
end

return CutLimbAction