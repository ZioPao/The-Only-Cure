require "TimedActions/ISBaseTimedAction"
local DataController = require("TOC/Controllers/DataController")
local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
---------------

---@class CauterizeAction : ISBaseTimedAction
---@field character IsoPlayer
---@field ovenObj IsoObject
---@field limbName string
local CauterizeAction = ISBaseTimedAction:derive("CauterizeAction")

---@param character IsoPlayer
---@param stoveObj IsoObject
---@param limbName string
---@return CauterizeAction
function CauterizeAction:new(character, limbName, stoveObj)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- We need to follow ISBaseTimedAction. self.character is gonna be the surgeon
    o.character = character
    o.stoveObj = stoveObj
    o.limbName = limbName

    o.stopOnWalk = true
    o.stopOnRun = true

    -- Max time depends on the strength
    o.maxTime = 20
    if o.character:isTimedActionInstant() then o.maxTime = 1 end

    return o
end

function CauterizeAction:isValid()
    return not ISHealthPanel.DidPatientMove(self.character, self.character, self.character:getX(), self.character:getY())
end

function CauterizeAction:waitToStart()
    self.character:faceThisObject(self.ovenObj)
    return self.character:shouldBeTurning()
end

function CauterizeAction:start()
    self:setActionAnim("Loot")      -- TODO Better anim pls

    -- Setup audio
    self.sound = self.character:getEmitter():playSound("Cauterization")
    local radius = 5
    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), radius, radius)
end

function CauterizeAction:update()
    self.character:setMetabolicTarget(Metabolics.HeavyWork)
end

function CauterizeAction:stopSound()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
        self.sound = nil
    end
end

function CauterizeAction:stop()
	self:stopSound()
    ISBaseTimedAction.stop(self)
end

function CauterizeAction:perform()
    -- Stop the sound
    self:stopSound()

    local dcInst = DataController.GetInstance()
    dcInst:setCicatrizationTime(self.limbName, 0)
    dcInst:setIsCauterized(self.limbName, true)

    -- Set isCicatrized and the visuals in one go, since this action is gonna be run only on a single client
    LocalPlayerController.HandleSetCicatrization(dcInst, self.character, self.limbName)

    -- TODO Add specific visuals for cauterization

    -- we don't care about the depended limbs, since they're alread "cicatrized"
    dcInst:apply()

    ISBaseTimedAction.perform(self)
end

return CauterizeAction