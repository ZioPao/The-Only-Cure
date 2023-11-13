require "TimedActions/ISBaseTimedAction"
local AmputationHandler = require("TOC/Handlers/AmputationHandler")
local CommandsData = require("TOC/CommandsData")
-----------------------------

---@class CutLimbAction : ISBaseTimedAction
---@field patient IsoPlayer
---@field character IsoPlayer
---@field limbName string
local CutLimbAction = ISBaseTimedAction:derive("CutLimbAction")

---Starts CutLimbAction
---@param patient IsoPlayer
---@param surgeon IsoPlayer
---@param limbName string
---@return CutLimbAction
function CutLimbAction:new(surgeon, patient, limbName)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- We need to follow ISBaseTimedAction. self.character is gonna be the surgeon
    o.character = surgeon
    o.patient = patient
    o.limbName = limbName

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
        self.handler = AmputationHandler:new(self.limbName)
        self.handler:damageDuringAmputation()
    else
        -- Other player
        ----@type relayDamageDuringAmputationParams


        local params = {patientNum = self.patient:getOnlineID(), limbName = self.limbName}
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayDamageDuringAmputation, params )
    end
end

function CutLimbAction:perform()
    if self.patient == self.character then
        TOC_DEBUG.print("patient and surgeon are the same, executing on the client")
        self.handler:execute(true)
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