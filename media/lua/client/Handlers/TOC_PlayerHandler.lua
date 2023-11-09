local ModDataHandler = require("Handlers/TOC_ModDataHandler")
local AmputationHandler = require("Handlers/TOC_AmputationHandler")
local ItemsHandler = require("Handlers/TOC_ItemsHandler")
local StaticData = require("TOC_StaticData")
-----------


-- LIST OF STUFF THAT THIS CLASS NEEDS TO DO
-- Update current player status (infection checks)
-- handle stats increase\decrease

---@class PlayerHandler
local PlayerHandler = {}

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
        ItemsHandler.DeleteAllOldAmputationItems(playerObj)
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
        if bodyPart and (bodyPart:bitten() or bodyPart:IsInfected()) then
            PlayerHandler.modDataHandler:setIsIgnoredPartInfected(true)
        end
    end

end

Events.OnPlayerGetDamage.Add(PlayerHandler.CheckInfection)

---comment
---@param player IsoPlayer
function PlayerHandler.UpdatePerks(player)
    -- TODO If player has an amputated limb, they're gonna level up them while doing normal stuff, getting better at it dynamically
    -- TODO We should have a way to check if the player has done any amputation at all instead of having to check manually each time

    -- TODO Should be run when player is doing stuff like picking up objects, not randomly
    for side, _ in pairs(StaticData.SIDES_STRINGS) do
        local limbName = "Hand_" .. side
        if ModDataHandler.GetInstance():getIsCut(limbName) then
            player:getXp():AddXP(Perks[limbName], 0.1)
        end
    end
end

Events.OnPlayerUpdate.Add(PlayerHandler.UpdatePerks)

return PlayerHandler