local ModDataHandler = require("TOC_ModDataHandler")
local StaticData = require("TOC_StaticData")
-----------


---@class PlayerHandler
local PlayerHandler = {}


---Setup player modData
---@param _ nil
---@param playerObj IsoPlayer
function PlayerHandler.InitializePlayer(_, playerObj)
    PlayerHandler.modDataHandler = ModDataHandler:new(playerObj)
    PlayerHandler.modDataHandler:setup()
end

---Cut a limb for a trait
---@param playerObj IsoPlayer
function PlayerHandler.ManageTraits(playerObj)
    for k, v in pairs(StaticData.TRAITS_BP) do
        if playerObj:HasTrait(k) then
            -- Once we find one, we should be done.
            PlayerHandler.ForceCutLimb(v)
            return
        end
    end
end


---comment
---@param patient IsoPlayer
---@param surgeon IsoPlayer
---@param limbName string
---@param surgeryHelpItems table
function PlayerHandler.CutLimb(patient, surgeon, limbName, surgeryHelpItems)

    -- TODO Start bleeding and crap like that

    local patientStats = patient:getStats()

    -- TODO Get surgeon ability from his aid skill
    local surgeonSkill = 50

    local bd = patient:getBodyDamage()
    local bodyPart = bd:getBodyPart(BodyPartType[limbName])
    local baseDamage = StaticData.LIMBS_BASE_DAMAGE[limbName]

    -- Set the bleeding and all the damage stuff in that part
    bodyPart:AddDamage(baseDamage - surgeonSkill)
    bodyPart:setAdditionalPain(baseDamage - surgeonSkill)
    bodyPart:setBleeding(true)
    bodyPart:setBleedingTime(baseDamage - surgeonSkill)
    bodyPart:setDeepWounded(true)
    bodyPart:setDeepWoundTime(baseDamage - surgeonSkill)
    patientStats:setEndurance(surgeonSkill)
    patientStats:setStress(baseDamage - surgeonSkill)

    ---@type amputationTable
    local amputationValues = {isOperated = false, isCicatrized = false, isCauterized = false}
    PlayerHandler.modDataHandler:setCutLimb(limbName, amputationValues)

end


---Set an already cut limb, for example for a trait.
---@param limbName string
function PlayerHandler.ForceCutLimb(limbName)
    PlayerHandler.modDataHandler:setCutLimb(limbName, true, true, true)
    -- TODO Spawn amputation item
end

return PlayerHandler
