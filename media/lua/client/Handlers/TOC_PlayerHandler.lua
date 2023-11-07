local ModDataHandler = require("Handlers/TOC_ModDataHandler")
local AmputationHandler = require("Handlers/TOC_AmputationHandler")
local StaticData = require("TOC_StaticData")
-----------


-- LIST OF STUFF THAT THIS CLASS NEEDS TO DO

-- Main thing, should contain the other handlers when needed
-- Handling Items (as in amputations spawns)
-- Update current player status (infection checks)
-- handle stats increase\decrease


---@class PlayerHandler
local PlayerHandler = {}

-- TODO This should be instanceable for a player. Separate handlers not

---Setup player modData
---@param _ nil
---@param playerObj IsoPlayer
---@param isForced boolean?
function PlayerHandler.InitializePlayer(_, playerObj, isForced)
    PlayerHandler.modDataHandler = ModDataHandler:new(playerObj)
    PlayerHandler.modDataHandler:setup(isForced)

    -- Since isForced is used to reset an existing player data, we're gonna clean their ISHealthPanel table too
    if isForced then
        ISHealthPanel.highestAmputations = {}
    end
end

---Handles the traits
---@param playerObj IsoPlayer
function PlayerHandler.ManageTraits(playerObj)
    for k, v in pairs(StaticData.TRAITS_BP) do
        if playerObj:HasTrait(k) then
            -- Once we find one, we should be done.
            local tempHandler = AmputationHandler:new(v)
            tempHandler:executeForTrait()
            tempHandler:close()
            return
        end
    end
end


--* Events *--

---Check if the player has an infected (as in, zombie infection) body part
---@param character IsoGameCharacter
---@param damageType string
---@param damage number
function PlayerHandler.CheckInfection(character)
    
    -- This fucking event barely works. Bleeding seems to be the only thing that triggers it
    if character ~= getPlayer() then return end

    local bd = character:getBodyDamage()

    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        local bptEnum = StaticData.BODYPARTSTYPES_ENUM[limbName]
        local bodyPart = bd:getBodyPart(bptEnum)

        if bodyPart:bitten() or bodyPart:IsInfected() then
            if PlayerHandler.modDataHandler:getIsCut(limbName) then
                bodyPart:SetBitten(false)
            else
                PlayerHandler.modDataHandler:setIsInfected(limbName, true)
            end
        end
    end

    -- Check other body parts that are not included in the mod, if there's a bite there then the player is fucked
    -- We can skip this loop if the player has been infected. The one before we kinda need it to handle correctly the bites in case the player wanna cut stuff off anyway
    if PlayerHandler.modDataHandler:getIsIgnoredPartInfected() then return end

    for i=1, #StaticData.IGNORED_PARTS_STRINGS do
        local bodyPartType = BodyPartType[StaticData.IGNORED_PARTS_STRINGS[i]]
        local bodyPart = bd:getBodyPart(bodyPartType)
        if bodyPart:bitten() or bodyPart:IsInfected() then
            PlayerHandler.modDataHandler:setIsIgnoredPartInfected(true)
        end
    end

end

Events.OnPlayerGetDamage.Add(PlayerHandler.CheckInfection)

return PlayerHandler