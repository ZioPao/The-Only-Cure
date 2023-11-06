local PlayerHandler = require("TOC_PlayerHandler")

require "TimedActions/ISBaseTimedAction"

---@class CutLimbAction
---@field patient IsoPlayer
---@field surgeon IsoPlayer
---@field limbName string
local CutLimbAction = ISBaseTimedAction:derive("CutLimbAction")

---Starts CutLimbAction
---@param patient IsoPlayer
---@param surgeon IsoPlayer
---@param limbName string
---@return CutLimbAction
function CutLimbAction:new(patient, surgeon, limbName)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.patient = patient
    o.surgeon = surgeon
    o.limbName = limbName

    o.stopOnWalk = true
    o.stopOnRun = true
    if o.surgeon:isTimedActionInstant() then o.maxTime = 1 end

    return o
end

function CutLimbAction:isValid()
    -- TODO Surgeon should be close to patient
    return true
end

function CutLimbAction:start()

    print("Damage patient")
    if self.patient == self.surgeon then
        -- Self
        PlayerHandler.DamageDuringAmputation(self.patient, self.limbName)
    else
        -- Other player
        -- TODO Send Damage
    end
end

function CutLimbAction:perform()

    PlayerHandler.CutLimb(self.patient, self.surgeon, self.limbName, {})
    ISBaseTimedAction.perform(self)
end

return CutLimbAction