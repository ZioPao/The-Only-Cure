local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local ItemsHandler = require("TOC/Handlers/ItemsHandler")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local StaticData = require("TOC/StaticData")
---------------------------

-- TODO Add Bandages, Torniquet, etc.
--- Manages an amputation. Could be run on either clients
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

    o.patientPl = getPlayer()     -- TODO This isn't necessarily true anymore.
    o.limbName = limbName
    o.bodyPartType = BodyPartType[self.limbName]
    if surgeonPl then
        o.surgeonPl = surgeonPl
    else
        o.surgeonPl = o.patientPl
    end

    AmputationHandler.instance = o
    return o
end


--* Main methods *--

---Starts bleeding from the point where the saw is being used
function AmputationHandler:damageDuringAmputation()
    TOC_DEBUG.print("damage patient")
    local bodyDamage = self.patientPl:getBodyDamage()
    local bodyDamagePart = bodyDamage:getBodyPart(self.bodyPartType)

    bodyDamagePart:setBleeding(true)
    bodyDamagePart:setCut(true)
    bodyDamagePart:setBleedingTime(ZombRand(10, 20))
end

---Execute the amputation
---@param damagePlayer boolean?
function AmputationHandler:execute(damagePlayer)

    -- TODO Calculate surgeonStats
    -- TODO Cap it to a certain amount, it shouldn't be more than ...?
    local surgeonFactor = 1
    if damagePlayer == nil then damagePlayer = true end     -- Default at true
    if damagePlayer then
        local patientStats = self.patientPl:getStats()
        local bd = self.patientPl:getBodyDamage()
        local bodyPart = bd:getBodyPart(self.bodyPartType)
        local baseDamage = StaticData.LIMBS_BASE_DAMAGE[self.limbName]

        -- Set the bleeding and all the damage stuff in that part
        bodyPart:AddDamage(baseDamage - surgeonFactor)
        bodyPart:setAdditionalPain(baseDamage - surgeonFactor)
        bodyPart:setBleeding(true)
        bodyPart:setBleedingTime(baseDamage - surgeonFactor)
        bodyPart:setDeepWounded(true)
        bodyPart:setDeepWoundTime(baseDamage - surgeonFactor)
        patientStats:setEndurance(surgeonFactor)
        patientStats:setStress(baseDamage - surgeonFactor)
    end


    -- Set the data in modData
    local modDataHandler = ModDataHandler.GetInstance()
    modDataHandler:setCutLimb(self.limbName, false, false, false, surgeonFactor)
    modDataHandler:apply()      -- This will force rechecking the cached amputated limbs on the other client

    -- Give the player the correct amputation item
    -- TODO We need to consider where this will be ran. 
    if self.patientPl == self.surgeonPl then
        ItemsHandler.DeleteOldAmputationItem(self.patientPl, self.limbName)
        ItemsHandler.SpawnAmputationItem(self.patientPl, self.limbName)
    else
        -- TODO Send server command to manage items and spawn on another player
    end

    -- Add it to the list of cut limbs on this local client
    local username = self.patientPl:getUsername()
    CachedDataHandler.AddAmputatedLimb(username, self.limbName)
    CachedDataHandler.CalculateHighestAmputatedLimbs(username)
end

---Deletes the instance
function AmputationHandler:close()
    AmputationHandler.instance = nil
end

--* Events *--
---Updates the cicatrization process, run when a limb has been cut
function AmputationHandler.UpdateCicatrization()
    if ModDataHandler.GetInstance():getIsAnyLimbCut() == false then return end

    -- TODO Update cicatrization
end

return AmputationHandler