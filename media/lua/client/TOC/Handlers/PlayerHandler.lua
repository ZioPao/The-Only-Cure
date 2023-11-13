local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
-----------

-- TODO We should instantiate this anyway if we want to keep track of cut limbs here. Doing so, we would be able to handle other players too

-- LIST OF STUFF THAT THIS CLASS NEEDS TO DO
-- Keep track of cut limbs so that we don't have to loop through all of them all the time
-- Update current player status (infection checks)
-- handle stats increase\decrease

---@class PlayerHandler
---@field modDataHandler ModDataHandler
---@field playerObj IsoPlayer
local PlayerHandler = {}

PlayerHandler.amputatedLimbs = {}


---Setup the Player Handler and modData, only for local client
---@param playerObj IsoPlayer
---@param isForced boolean?
function PlayerHandler.InitializePlayer(playerObj, isForced)

    local username = playerObj:getUsername()
    TOC_DEBUG.print("initializing " .. username)
    local modDataHandler = ModDataHandler:new(username, isForced)
    PlayerHandler.playerObj = playerObj

    -- Calculate amputated limbs at startup
    PlayerHandler.CacheAmputatedLimbs(username)

    -- Since isForced is used to reset an existing player data, we're gonna clean their ISHealthPanel table too
    if isForced then
        --ISHealthPanel.highestAmputations = {}
        local ItemsHandler = require("TOC/Handlers/ItemsHandler")
        ItemsHandler.DeleteAllOldAmputationItems(playerObj)
    end
end

---Handles the traits
---@param playerObj IsoPlayer
function PlayerHandler.ManageTraits(playerObj)
    local AmputationHandler = require("Handlers/TOC_AmputationHandler")
    for k, v in pairs(StaticData.TRAITS_BP) do
        if playerObj:HasTrait(k) then
            -- Once we find one, we should be done.
            local tempHandler = AmputationHandler:new(v)
            tempHandler:execute(false)      -- No damage
            tempHandler:close()
            return
        end
    end
end

---Cycle through all the limbs and caches the ones that the player cut off
---@param username string
function PlayerHandler.CacheAmputatedLimbs(username)
    PlayerHandler.amputatedLimbs[username] = {}
    local modDataHandler = ModDataHandler.GetInstance(username)
    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        if modDataHandler:getIsCut(limbName) then
            PlayerHandler.AddLocalAmputatedLimb(username, limbName)
        end
    end
end


---Cache the currently amputated limbs
---@param limbName string
---@private
function PlayerHandler.AddLocalAmputatedLimb(username, limbName)
    TOC_DEBUG.print("added " .. limbName .. " to known amputated limbs for " .. username)
    table.insert(PlayerHandler.amputatedLimbs[username], limbName)        -- TODO This should be player specific, not generic
end

--* Getters *--

---Get a table with the strings of the cached amputated limbs
---@return table
function PlayerHandler.GetAmputatedLimbs()
    return PlayerHandler.amputatedLimbs or {}
end

--* Events *--

---Check if the player has an infected (as in, zombie infection) body part
---@param character IsoGameCharacter
function PlayerHandler.CheckInfection(character)
    -- This fucking event barely works. Bleeding seems to be the only thing that triggers it
    if character ~= getPlayer() then return end
    local bd = character:getBodyDamage()
    local modDataHandler = ModDataHandler.GetInstance()

    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        local bptEnum = StaticData.BODYPARTSTYPES_ENUM[limbName]
        local bodyPart = bd:getBodyPart(bptEnum)

        if bodyPart:bitten() or bodyPart:IsInfected() then
            if modDataHandler:getIsCut(limbName) then
                bodyPart:SetBitten(false)
            else
                modDataHandler:setIsInfected(limbName, true)
            end
        end
    end

    -- Check other body parts that are not included in the mod, if there's a bite there then the player is fucked
    -- We can skip this loop if the player has been infected. The one before we kinda need it to handle correctly the bites in case the player wanna cut stuff off anyway
    if ModDataHandler.GetInstance():getIsIgnoredPartInfected() then return end

    for i=1, #StaticData.IGNORED_PARTS_STRINGS do
        local bodyPartType = BodyPartType[StaticData.IGNORED_PARTS_STRINGS[i]]
        local bodyPart = bd:getBodyPart(bodyPartType)
        if bodyPart and (bodyPart:bitten() or bodyPart:IsInfected()) then
            ModDataHandler.GetInstance():setIsIgnoredPartInfected(true)
        end
    end
end

Events.OnPlayerGetDamage.Add(PlayerHandler.CheckInfection)


--* Overrides *--

local og_ISBaseTimedAction_adjustMaxTime = ISBaseTimedAction.adjustMaxTime
--- Adjust time
---@diagnostic disable-next-line: duplicate-set-field
function ISBaseTimedAction:adjustMaxTime(maxTime)
    local time = og_ISBaseTimedAction_adjustMaxTime(self, maxTime)
    local modDataHandler = ModDataHandler.GetInstance()
    if time ~= -1 and modDataHandler and modDataHandler:getIsAnyLimbCut() then
        local pl = getPlayer()

        for i=1, #PlayerHandler.amputatedLimbs do
            local limbName = PlayerHandler.amputatedLimbs[i]
            if modDataHandler:getIsCut(limbName) then
                local perk = Perks["Side_" .. CommonMethods.GetSide(limbName)]
                local perkLevel = pl:getPerkLevel(perk)
                local perkLevelScaled
                if perkLevel ~= 0 then perkLevelScaled = perkLevel / 10 else perkLevelScaled = 0 end
                time = time * (StaticData.LIMBS_TIME_MULTIPLIER[limbName] - perkLevelScaled)
            end
        end
    end
    return time
end

local og_ISBaseTimedAction_perform = ISBaseTimedAction.perform
--- After each action, level up perks
---@diagnostic disable-next-line: duplicate-set-field
function ISBaseTimedAction:perform()
	og_ISBaseTimedAction_perform(self)

    if ModDataHandler.GetInstance():getIsAnyLimbCut() then
        for side, _ in pairs(StaticData.SIDES_STRINGS) do
            local limbName = "Hand_" .. side
            if ModDataHandler.GetInstance():getIsCut(limbName) then
                PlayerHandler.playerObj:getXp():AddXP(Perks["Side_" .. side], 2)       -- TODO Make it dynamic
            end
        end
    end
end


return PlayerHandler