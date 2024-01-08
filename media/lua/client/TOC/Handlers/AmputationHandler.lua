local DataController = require("TOC/Controllers/DataController")
local ItemsController = require("TOC/Handlers/ItemsController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local StaticData = require("TOC/StaticData")
---------------------------

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

---comment
---@param prevAction ISBaseTimedAction
---@param limbName string
---@param surgeonPl IsoPlayer
---@param patientPl IsoPlayer
---@param stitchesItem InventoryItem
---@return ISStitch
function AmputationHandler.PrepareStitchesAction(prevAction, limbName, surgeonPl, patientPl, stitchesItem)
    local bptEnum = StaticData.BODYLOCS_IND_BPT[limbName]
    local bd = patientPl:getBodyDamage()
    local bodyPart = bd:getBodyPart(bptEnum)
    local stitchesAction = ISStitch:new(surgeonPl, patientPl, stitchesItem, bodyPart, true)
    ISTimedActionQueue.addAfter(prevAction, stitchesAction)

    return stitchesAction
end

---Setup the ISApplyBandage action that will trigger after the amputation
---@param prevAction ISBaseTimedAction
---@param limbName string
---@param surgeonPl IsoPlayer
---@param patientPl IsoPlayer
---@param bandageItem InventoryItem
---@return ISApplyBandage
function AmputationHandler.PrepareBandagesAction(prevAction, limbName, surgeonPl, patientPl, bandageItem)
    local bptEnum = StaticData.BODYLOCS_IND_BPT[limbName]
    local bd = patientPl:getBodyDamage()
    local bodyPart = bd:getBodyPart(bptEnum)
    local bandageAction = ISApplyBandage:new(surgeonPl, patientPl, bandageItem, bodyPart, true)
    ISTimedActionQueue.addAfter(prevAction, bandageAction)

    return bandageAction
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

---Set the damage to the adjacent part of the cut area
---@param surgeonFactor number
function AmputationHandler:damageAfterAmputation(surgeonFactor)
    -- TODO Torniquet should reduce the damage in total, less blood loss

    TOC_DEBUG.print("Applying damage after amputation")
    local patientStats = self.patientPl:getStats()
    local bd = self.patientPl:getBodyDamage()

    local adjacentLimb = StaticData.LIMBS_ADJACENT_IND_STR[self.limbName]
    local bodyPart = bd:getBodyPart(BodyPartType[adjacentLimb])
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
    local surgeonFactor = self.surgeonPl:getPerkLevel(Perks.Doctor) * SandboxVars.TOC.SurgeonAbilityImportance

    -- Set the data in modData
    local dcInst = DataController.GetInstance()
    dcInst:setCutLimb(self.limbName, false, false, false, surgeonFactor)
    dcInst:apply()      -- This will force rechecking the cached amputated limbs on the other client

    -- Heal the area, we're gonna re-set the damage after (if it's enabled)
    local bd = self.patientPl:getBodyDamage()
    local bodyPart = bd:getBodyPart(self.bodyPartType)
    PlayerHandler.HealArea(bodyPart)

    -- Give the player the correct amputation item
    ItemsController.Player.DeleteOldAmputationItem(self.patientPl, self.limbName)
    ItemsController.Player.SpawnAmputationItem(self.patientPl, self.limbName)

    -- Add it to the list of cut limbs on this local client
    local username = self.patientPl:getUsername()
    CachedDataHandler.AddAmputatedLimb(username, self.limbName)

    -- TODO Not optimal, we're already cycling through this when using setCutLimb
    for i=1, #StaticData.LIMBS_DEPENDENCIES_IND_STR[self.limbName] do
        local dependedLimbName = StaticData.LIMBS_DEPENDENCIES_IND_STR[self.limbName][i]
        CachedDataHandler.AddAmputatedLimb(username, dependedLimbName)
    end

    CachedDataHandler.CalculateHighestAmputatedLimbs(username)

    -- If the part was actually infected, heal the player, if they were in time (infectionLevel < 20)
    if bd:getInfectionLevel() < 20 and bodyPart:IsInfected() and not dcInst:getIsIgnoredPartInfected() then
        PlayerHandler.HealZombieInfection(bd, bodyPart, self.limbName, dcInst)
    end

    -- The last part is to handle the damage that the player will receive after the amputation
    if not damagePlayer then return end
    self:damageAfterAmputation(surgeonFactor)

    -- Trigger this event
    triggerEvent("OnAmputatedLimb")
end

---Deletes the instance
function AmputationHandler:close()
    AmputationHandler.instance = nil
end

return AmputationHandler