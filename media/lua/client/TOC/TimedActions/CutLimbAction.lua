require "TimedActions/ISBaseTimedAction"
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local CommandsData = require("TOC/CommandsData")
-----------------------------

---@class CutLimbAction : ISBaseTimedAction
---@field patient IsoPlayer
---@field character IsoPlayer
---@field limbName string
---@field item InventoryItem
local CutLimbAction = ISBaseTimedAction:derive("CutLimbAction")

---Starts CutLimbAction
---@param patient IsoPlayer
---@param surgeon IsoPlayer
---@param limbName string
---@param item InventoryItem
---@return CutLimbAction
function CutLimbAction:new(surgeon, patient, limbName, item)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- We need to follow ISBaseTimedAction. self.character is gonna be the surgeon
    o.character = surgeon
    o.patient = patient
    o.limbName = limbName
    o.item = item

    o.stopOnWalk = true
    o.stopOnRun = true

    o.maxTime = 100
    if o.character:isTimedActionInstant() then o.maxTime = 1 end

    return o
end

function CutLimbAction:isValid()
    -- TODO Surgeon should be close to patient
    return true
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

    -- Setup cosmetic stuff
    self:setActionAnim("SawLog")
    self:setOverrideHandModels(self.item:getStaticModel())
    -- if self.character:getPrimaryHandItem() then
    --     ISTimedActionQueue.add(ISUnequipAction:new(self.character, self.character:getPrimaryHandItem(), 2))
    -- end
    -- if self.character:getSecondaryHandItem() and self.character:getSecondaryHandItem() ~= self.character:getPrimaryHandItem() then
    --     ISTimedActionQueue.add(ISUnequipAction:new(self.character, self.surgeon:getSecondaryHandItem(), 2))
    -- end

    -- if sawItem then
    --     self:setOverrideHandModels(sawItem:getStaticModel(), nil)

    -- end


end

function CutLimbAction:waitToStart()
    if self.character == self.patient then
        return false
    end
    self.character:faceThisObject(self.patient)
    return self.character:shouldBeTurning()
end

function CutLimbAction:perform()
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