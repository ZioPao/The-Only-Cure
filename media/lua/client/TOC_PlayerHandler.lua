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
    local surgeonFactor = surgeonSkill - 1      -- TODO Should be decided by surgeryHelpItems

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

    PlayerHandler.modDataHandler:setCutLimb(limbName, false, false, false, surgeonFactor)

end


---Set an already cut limb, for example for a trait.
---@param limbName string
function PlayerHandler.ForceCutLimb(limbName)
    PlayerHandler.modDataHandler:setCutLimb(limbName, true, true, true, 0)
    -- TODO Spawn amputation item
end



--* Events *--

---Check if the player has an infected (as in, zombie infection) body part
---@param character IsoGameCharacter
---@param damageType string
---@param damage number
function PlayerHandler.CheckInfection(character, damageType, damage)

    -- This fucking event barely works. Bleeding seems to be the only thing that triggers it
    -- TODO Check other body parts that are not included in the mod, if there's a bite there then the player is fucked
    local bd = character:getBodyDamage()

    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        local bptEnum = StaticData.BODYPARTSTYPES_ENUM[limbName]
        local bodyPart = bd:getBodyPart(bptEnum)

        if bodyPart:bitten() then
            if PlayerHandler.modDataHandler:getIsCut(limbName) then
                bodyPart:SetBitten(false)
            else
                PlayerHandler.modDataHandler:setIsInfected(limbName, true)
            end
        end
    end

end

Events.OnPlayerGetDamage.Add(PlayerHandler.CheckInfection)

return PlayerHandler