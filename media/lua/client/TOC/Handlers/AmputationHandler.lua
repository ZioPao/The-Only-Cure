local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local ItemsHandler = require("TOC/Handlers/ItemsHandler")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local StaticData = require("TOC/StaticData")
---------------------------

-- TODO Add Bandages, Torniquet, etc.
--- Manages an amputation. Will be run on the patient client
---@class AmputationHandler
---@field patientPl IsoPlayer
---@field limbName string
---@field bodyPartType BodyPartType
---@field surgeonPl IsoPlayer?
local AmputationHandler = {}


---@param limbName string
---@param surgeonPl IsoPlayer?
---@return AmputationHandler
function AmputationHandler:new(limbName, surgeonPl)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.patientPl = getPlayer()
    o.limbName = limbName
    o.bodyPartType = BodyPartType[limbName]

    -- TOC_DEBUG.print("limbName = " .. o.limbName)
    -- TOC_DEBUG.print("bodyPartType = " .. tostring(o.bodyPartType))

    if surgeonPl then
        o.surgeonPl = surgeonPl
    else
        o.surgeonPl = o.patientPl
    end

    AmputationHandler.instance = o
    return o
end


--* Static methods *--

---comment
---@param player IsoPlayer
---@param limbName string
function AmputationHandler.ApplyDamageDuringAmputation(player, limbName)
    local bodyDamage = player:getBodyDamage()
    local bodyPartType = BodyPartType[limbName]
    local bodyDamagePart = bodyDamage:getBodyPart(bodyPartType)
    TOC_DEBUG.print("damage patient - " .. tostring(bodyPartType))

    bodyDamagePart:setBleeding(true)
    bodyDamagePart:setCut(true)
    bodyDamagePart:setBleedingTime(ZombRand(10, 20))
end

--* Main methods *--


---Damage the player part during the amputation process
function AmputationHandler:damageDuringAmputation()
    local bodyDamage = self.patientPl:getBodyDamage()
    local bodyDamagePart = bodyDamage:getBodyPart(self.bodyPartType)
    TOC_DEBUG.print("damage patient - " .. tostring(self.bodyPartType))

    bodyDamagePart:setBleeding(true)
    bodyDamagePart:setCut(true)
    bodyDamagePart:setBleedingTime(ZombRand(10, 20))
end

---Set the damage to the amputated area
---@param surgeonFactor number
function AmputationHandler:damageAfterAmputation(surgeonFactor)
    local patientStats = self.patientPl:getStats()
    local bd = self.patientPl:getBodyDamage()
    local bodyPart = bd:getBodyPart(self.bodyPartType)
    local baseDamage = StaticData.LIMBS_BASE_DAMAGE_IND_NUM[self.limbName]

    bodyPart:AddDamage(baseDamage - surgeonFactor)
    bodyPart:setAdditionalPain(baseDamage - surgeonFactor)
    bodyPart:setBleeding(true)
    bodyPart:setBleedingTime(baseDamage - surgeonFactor)
    bodyPart:setDeepWounded(true)
    bodyPart:setDeepWoundTime(baseDamage - surgeonFactor)
    patientStats:setEndurance(surgeonFactor)
    patientStats:setStress(baseDamage - surgeonFactor)
end

---Execute the amputation
---@param damagePlayer boolean
function AmputationHandler:execute(damagePlayer)

    -- TODO Calculate surgeonStats
    -- TODO Cap it to a certain amount, it shouldn't be more than ...?
    local surgeonFactor = 1
    if damagePlayer then
        self:damageAfterAmputation(surgeonFactor)
    end

    -- Set the data in modData
    local modDataHandler = ModDataHandler.GetInstance()
    modDataHandler:setCutLimb(self.limbName, false, false, false, surgeonFactor)
    modDataHandler:apply()      -- This will force rechecking the cached amputated limbs on the other client

    -- Give the player the correct amputation item
    ItemsHandler.DeleteOldAmputationItem(self.patientPl, self.limbName)
    ItemsHandler.SpawnAmputationItem(self.patientPl, self.limbName)

    -- Add it to the list of cut limbs on this local client
    local username = self.patientPl:getUsername()
    CachedDataHandler.AddAmputatedLimb(username, self.limbName)
    CachedDataHandler.CalculateHighestAmputatedLimbs(username)
end

---Deletes the instance
function AmputationHandler:close()
    AmputationHandler.instance = nil
end

return AmputationHandler