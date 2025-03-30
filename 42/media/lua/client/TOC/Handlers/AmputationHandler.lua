local DataController = require("TOC/Controllers/DataController")
local ItemsController = require("TOC/Controllers/ItemsController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local StaticData = require("TOC/StaticData")
local TourniquetController = require("TOC/Controllers/TourniquetController")
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

---@param player IsoPlayer
---@param limbName string
function AmputationHandler.ApplyDamageDuringAmputation(player, limbName)


    local ampGroup = StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR[limbName]
    local isTourniquetEquipped = false

    -- Check if tourniquet is applied on the zone
    for bl, tournAmpGroup in pairs(StaticData.TOURNIQUET_BODYLOCS_TO_GROUPS_IND_STR) do
        local item = player:getWornItem(bl)

        -- LimbName -> Group -> BodyLoc
        if item and tournAmpGroup == ampGroup then
            TOC_DEBUG.print("tourniquet is equipped")
            isTourniquetEquipped = true
            break
        end
    end


    local bodyDamage = player:getBodyDamage()
    local bodyPartType = BodyPartType[limbName]
    local bodyDamagePart = bodyDamage:getBodyPart(bodyPartType)
    TOC_DEBUG.print("damage patient - " .. tostring(bodyPartType))

    bodyDamagePart:setBleeding(true)
    bodyDamagePart:setCut(true)

    local bleedingTime
    if isTourniquetEquipped then
        bleedingTime = ZombRand(1,5)
    else
        bleedingTime = ZombRand(10, 20)
    end

    bodyDamagePart:setBleedingTime(bleedingTime)
end


---@param prevAction ISBaseTimedAction
---@param limbName string
---@param surgeonPl IsoPlayer
---@param patientPl IsoPlayer
---@param stitchesItem InventoryItem
---@return ISStitch
function AmputationHandler.PrepareStitchesAction(prevAction, limbName, surgeonPl, patientPl, stitchesItem)
    local bd = patientPl:getBodyDamage()

    -- we need the adjacent one, not the actual one
    local adjacentLimb = StaticData.LIMBS_ADJACENT_IND_STR[limbName]
    local bodyPart = bd:getBodyPart(BodyPartType[adjacentLimb])

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
    local bd = patientPl:getBodyDamage()
    -- we need the adjacent one, not the actual one
    local adjacentLimb = StaticData.LIMBS_ADJACENT_IND_STR[limbName]
    local bodyPart = bd:getBodyPart(BodyPartType[adjacentLimb])

    local bandageAction = ISApplyBandage:new(surgeonPl, patientPl, bandageItem, bodyPart, true)
    ISTimedActionQueue.addAfter(prevAction, bandageAction)

    return bandageAction
end


--* Main methods *--

---Set the damage to the adjacent part of the cut area
---@param surgeonFactor number
function AmputationHandler:damageAfterAmputation(surgeonFactor)


    TOC_DEBUG.print("Applying damage after amputation")
    local patientStats = self.patientPl:getStats()
    local bd = self.patientPl:getBodyDamage()

    local adjacentLimb = StaticData.LIMBS_ADJACENT_IND_STR[self.limbName]
    local bodyPart = bd:getBodyPart(BodyPartType[adjacentLimb])
    local baseDamage = StaticData.LIMBS_BASE_DAMAGE_IND_NUM[self.limbName]


    -- Check if player has tourniquet equipped on the limb
    -- TODO Suboptimal checks, but they should work for now.
    local hasTourniquet = TourniquetController.CheckTourniquetOnLimb(self.patientPl, self.limbName)
    if hasTourniquet then
        TOC_DEBUG.print("Do something different for the damage calculation because tourniquet is applied")
        baseDamage = baseDamage * 0.5   -- 50% less damage due to tourniquet
    end


    bodyPart:AddDamage(baseDamage - surgeonFactor)
    bodyPart:setAdditionalPain(baseDamage - surgeonFactor)
    bodyPart:setBleeding(true)
    bodyPart:setBleedingTime(baseDamage - surgeonFactor)
    bodyPart:setDeepWounded(true)
    bodyPart:setDeepWoundTime(baseDamage - surgeonFactor)
    patientStats:setEndurance(surgeonFactor)
    patientStats:setStress(baseDamage - surgeonFactor)
end

---Execute the amputation. This method doesn't check if the upper limb has been amputated or not, so if
--- somehow the method gets triggered and we're trying to cut off a part that doesn't really exist anymore,
--- it will still be executed. This is by design, additional checks must be made BEFORE running the AmputationHandler
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
    LocalPlayerController.HealArea(bodyPart)

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

    -- Cache highest amputation and hand feasibility
    CachedDataHandler.CalculateCacheableValues(username)

    -- If the part was actually infected, heal the player, if they were in time (infectionLevel < 20)
    if bd:getInfectionLevel() < 20 and bodyPart:IsInfected() and not dcInst:getIsIgnoredPartInfected() then
        LocalPlayerController.HealZombieInfection(bd, bodyPart, self.limbName, dcInst)
    end

    -- The last part is to handle the damage that the player will receive after the amputation
    if not damagePlayer then return end
    self:damageAfterAmputation(surgeonFactor)

    -- Trigger this event
    triggerEvent("OnAmputatedLimb", self.limbName)
end

---Deletes the instance
function AmputationHandler:close()
    AmputationHandler.instance = nil
end

return AmputationHandler