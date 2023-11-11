local ModDataHandler = require("Handlers/TOC_ModDataHandler")
local StaticData = require("TOC_StaticData")
local ItemsHandler = require("Handlers/TOC_ItemsHandler")
local PlayerHandler = require("Handlers/TOC_PlayerHandler")

---------------------------

-- TODO Add Bandages, Torniquet, etc.
--- This will be run EXCLUSIVELY on the client which is getting the amputation
---@class AmputationHandler
---@field patient IsoPlayer
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

    o.patient = getPlayer()
    o.limbName = limbName
    o.bodyPartType = BodyPartType[self.limbName]
    if surgeonPl then
        o.surgeonPl = surgeonPl
    else
        o.surgeonPl = o.patient
    end

    AmputationHandler.instance = o
    return o
end


--* Main methods *--

---Starts bleeding from the point where the saw is being used
function AmputationHandler:damageDuringAmputation()
    print("TOC: Damage patient")
    local bodyDamage = self.patient:getBodyDamage()
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
        local patientStats = self.patient:getStats()
        local bd = self.patient:getBodyDamage()
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
    ModDataHandler.GetInstance():setCutLimb(self.limbName, false, false, false, surgeonFactor)

    -- Give the player the correct amputation item
    ItemsHandler.DeleteOldAmputationItem(self.patient, self.limbName)
    ItemsHandler.SpawnAmputationItem(self.patient, self.limbName)

    -- Add it to the list of cut limbs
    PlayerHandler.AddLocalAmputatedLimb(self.limbName)

    -- Set the highest amputation and caches them.
    ISHealthPanel.GetHighestAmputation()
end

---Deletes the instance
function AmputationHandler:close()
    AmputationHandler.instance = nil
end

--* Events *--
function AmputationHandler.UpdateCicatrization()
    if ModDataHandler.GetInstance():getIsAnyLimbCut() == false then return end


end

return AmputationHandler