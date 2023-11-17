local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local CommonMethods = require("TOC/CommonMethods")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local StaticData = require("TOC/StaticData")
-----------

-- THIS SHOULD BE LOCAL ONLY! WE'RE MANAGING EVENTS AND INITIALIZATION STUFF!

-- LIST OF STUFF THAT THIS CLASS NEEDS TO DO
-- Keep track of cut limbs so that we don't have to loop through all of them all the time
-- Update current player status (infection checks)
-- handle stats increase\decrease

---@class PlayerHandler
---@field playerObj IsoPlayer
---@field username string
---@field hasBeenDamaged boolean
local PlayerHandler = {}

---Setup the Player Handler and modData, only for local client
---@param playerObj IsoPlayer
---@param isForced boolean?
function PlayerHandler.InitializePlayer(playerObj, isForced)
    local username = playerObj:getUsername()
    TOC_DEBUG.print("initializing local player: " .. username)

    ModDataHandler:new(username, isForced)
    PlayerHandler.playerObj = playerObj
    PlayerHandler.username = username

    -- Calculate amputated limbs and highest point of amputations at startup
    CachedDataHandler.CalculateAmputatedLimbs(username)
    CachedDataHandler.CalculateHighestAmputatedLimbs(username)

    --Setup the CicatrizationUpdate event
    Events.OnAmputatedLimb.Add(PlayerHandler.ToggleCicatrizationUpdate)

    -- Since isForced is used to reset an existing player data, we're gonna clean their ISHealthPanel table too
    if isForced then
        --ISHealthPanel.highestAmputations = {}
        local ItemsHandler = require("TOC/Handlers/ItemsHandler")
        ItemsHandler.Player.DeleteAllOldAmputationItems(playerObj)
        CachedDataHandler.Reset(username)
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

--* Health management *--

---Used to heal an area that has been cut previously. There's an exception for bites, those are managed differently
---@param bodyPart BodyPart
function PlayerHandler.HealArea(bodyPart)
    bodyPart:setBleeding(false)
    bodyPart:setBleedingTime(0)

    bodyPart:SetBitten(false)
    bodyPart:setBiteTime(0)

    bodyPart:setCut(false)
    bodyPart:setCutTime(0)

    bodyPart:setDeepWounded(false)
    bodyPart:setDeepWoundTime(0)

    bodyPart:setHaveBullet(false, 0)
    bodyPart:setHaveGlass(false)
    bodyPart:setSplint(false, 0)
end

---comment
---@param bodyDamage BodyDamage
---@param bodyPart BodyPart
---@param limbName string
---@param modDataHandler ModDataHandler
function PlayerHandler.HealZombieInfection(bodyDamage, bodyPart, limbName, modDataHandler)
    if bodyDamage:isInfected() == false then return end

    bodyDamage:setInfected(false)
    bodyDamage:setInfectionMortalityDuration(-1)
    bodyDamage:setInfectionTime(-1)
    bodyDamage:setInfectionLevel(-1)
    bodyPart:SetInfected(false)

    modDataHandler:setIsInfected(limbName, false)
    modDataHandler:apply()
end

---comment
---@param character IsoPlayer
---@param limbName string
function PlayerHandler.TryRandomBleed(character, limbName)
    -- Chance should be determined by the cicatrization time
    local cicTime = ModDataHandler.GetInstance():getCicatrizationTime(limbName)
    if cicTime == 0 then return end
    -- TODO Sometimes we get cicTime = 0... Shouldn't really do it

    local normCicTime = CommonMethods.Normalize(cicTime, 0, 100)
    TOC_DEBUG.print("OG cicTime: " .. tostring(cicTime))
    TOC_DEBUG.print("Normalized cic time : " .. tostring(normCicTime))

    local chance = ZombRand(0,100)
    if chance > normCicTime then
        TOC_DEBUG.print("Triggered bleeding from non cicatrized wound")
        local adjacentBodyPartType = BodyPartType[StaticData.LIMBS_ADJACENT_IND_STR[limbName]]
        character:getBodyDamage():getBodyPart(adjacentBodyPartType):setBleeding(true)
        character:getBodyDamage():getBodyPart(adjacentBodyPartType):setBleedingTime(20)
    end
end
-------------------------
--* Events *--
--- Locks OnPlayerGetDamage event, to prevent it from getting spammed constantly
PlayerHandler.hasBeenDamaged = false


---Check if the player has in infected body part or if they have been hit in a cut area
---@param character IsoPlayer
function PlayerHandler.HandleDamage(character)
    -- TOC_DEBUG.print("Player got hit!")
    -- TOC_DEBUG.print(damageType)
    if character ~= getPlayer() then return end
    local bd = character:getBodyDamage()
    local modDataHandler = ModDataHandler.GetInstance()
    local modDataNeedsUpdate = false
    for i=1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        local bptEnum = StaticData.BODYLOCS_IND_BPT[limbName]
        local bodyPart = bd:getBodyPart(bptEnum)
        if modDataHandler:getIsCut(limbName) then

            -- Generic injury, let's heal it since they already cut the limb off
            if bodyPart:HasInjury() then
                PlayerHandler.HealArea(bodyPart)
            end

            -- Special case for bites\zombie infections
            if bodyPart:IsInfected() then
                TOC_DEBUG.print("Healed from zombie infection " .. tostring(bodyPart))
                PlayerHandler.HealZombieInfection(bd, bodyPart, limbName, modDataHandler)
            end
        else
            if bodyPart:bitten() or bodyPart:IsInfected() then
                modDataHandler:setIsInfected(limbName, true)
                modDataNeedsUpdate = true
            end
        end
    end

    -- Check other body parts that are not included in the mod, if there's a bite there then the player is fucked
    -- We can skip this loop if the player has been infected. The one before we kinda need it to handle correctly the bites in case the player wanna cut stuff off anyway
    if modDataHandler:getIsIgnoredPartInfected() then return end

    for i=1, #StaticData.IGNORED_BODYLOCS_BPT do
        local bodyPartType = StaticData.IGNORED_BODYLOCS_BPT[i]
        local bodyPart = bd:getBodyPart(bodyPartType)
        if bodyPart and (bodyPart:bitten() or bodyPart:IsInfected()) then
            modDataHandler:setIsIgnoredPartInfected(true)
            modDataNeedsUpdate = true
        end
    end

    -- TODO in theory  should sync modData, but it's gonna be expensive as fuck. Figure it out
    if modDataNeedsUpdate then
        modDataHandler:apply()
    end

    -- Disable the lock
    PlayerHandler.hasBeenDamaged = false

end

---Setup HandleDamage, triggered by OnPlayerGetDamage
---@param character IsoGameCharacter
---@param damageType string
---@param damageAmount number
function PlayerHandler.OnGetDamage(character, damageType, damageAmount)

    -- TODO Check if other players in the online triggers this

    if PlayerHandler.hasBeenDamaged == false then
        -- Start checks

        -- TODO Add a timer before we can re-enable this bool?
        PlayerHandler.hasBeenDamaged = true
        PlayerHandler.HandleDamage(character)
    end
end

Events.OnPlayerGetDamage.Add(PlayerHandler.OnGetDamage)

---Updates the cicatrization process, run when a limb has been cut. Run it every 1 hour
function PlayerHandler.UpdateCicatrization()
    local modDataHandler = ModDataHandler.GetInstance()
    if modDataHandler:getIsAnyLimbCut() == false then
        Events.EveryHours.Remove(PlayerHandler.UpdateCicatrization)
    end

    local pl = PlayerHandler.playerObj
    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(pl:getUsername())
    local needsUpdate = false

    for i=1, #amputatedLimbs do
        local limbName = amputatedLimbs[i]
        local isCicatrized = modDataHandler:getIsCicatrized(limbName)
        if not isCicatrized then
            needsUpdate = true
            local cicTime = modDataHandler:getCicatrizationTime(limbName)
            TOC_DEBUG.print("updating cicatrization for " .. tostring(limbName))

            if cicTime > 0 then
                cicTime = cicTime - (SandboxVars.TOC.CicatrizationSpeed)
                modDataHandler:setCicatrizationTime(limbName, cicTime)
                TOC_DEBUG.print("new cicatrization time: " .. tostring(cicTime))
                if cicTime < 0 then
                    modDataHandler:setIsCicatrized(limbName, true)
                end
            end
        end
    end

    if needsUpdate then
        TOC_DEBUG.print("updating modData from cicatrization loop")
        modDataHandler:apply()      -- TODO This is gonna be heavy. Not entirely sure
    else
        Events.EveryHours.Remove(PlayerHandler.UpdateCicatrization)     -- We can remove it safely, no cicatrization happening here boys
    end
    TOC_DEBUG.print("updating cicatrization!")

end

---Starts safely the loop to update cicatrzation
function PlayerHandler.ToggleCicatrizationUpdate()
    TOC_DEBUG.print("activating cicatrization loop (if it wasn't active before)")
    CommonMethods.SafeStartEvent("EveryHours", PlayerHandler.UpdateCicatrization)
end


------------------------------------------
--* OVERRIDES *--

--* Time to perform actions overrides *--

local og_ISBaseTimedAction_adjustMaxTime = ISBaseTimedAction.adjustMaxTime
--- Adjust time
---@diagnostic disable-next-line: duplicate-set-field
function ISBaseTimedAction:adjustMaxTime(maxTime)
    local time = og_ISBaseTimedAction_adjustMaxTime(self, maxTime)

    -- Exceptions handling, if we find that parameter then we just use the original time
    local queue = ISTimedActionQueue.getTimedActionQueue(getPlayer())
    if queue and queue.current and queue.current.skipTOC then return time end

    -- Action is valid, check if we have any cut limb and then modify maxTime
    local modDataHandler = ModDataHandler.GetInstance()
    if time ~= -1 and modDataHandler and modDataHandler:getIsAnyLimbCut() then
        local pl = getPlayer()
        local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(pl:getUsername())
        for i=1, #amputatedLimbs do
            local limbName = amputatedLimbs[i]
            --if modDataHandler:getIsCut(limbName) then
            local perk = Perks["Side_" .. CommonMethods.GetSide(limbName)]
            local perkLevel = pl:getPerkLevel(perk)
            local perkLevelScaled
            if perkLevel ~= 0 then perkLevelScaled = perkLevel / 10 else perkLevelScaled = 0 end
            time = time * (StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[limbName] - perkLevelScaled)
            --end
        end
    end
    return time
end


--* Random bleeding during cicatrization + Perks leveling override *--
local og_ISBaseTimedAction_perform = ISBaseTimedAction.perform
--- After each action, level up perks
---@diagnostic disable-next-line: duplicate-set-field
function ISBaseTimedAction:perform()
	og_ISBaseTimedAction_perform(self)

    local modDataHandler = ModDataHandler.GetInstance()
    if not modDataHandler:getIsAnyLimbCut() then return end

    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(PlayerHandler.username)
    for i=1, #amputatedLimbs do
        local limbName = amputatedLimbs[i]
        if modDataHandler:getIsCut(limbName) then
            local side = CommonMethods.GetSide(limbName)
            PlayerHandler.playerObj:getXp():AddXP(Perks["Side_" .. side], 1)       -- TODO Make it dynamic
            local prostGroup = StaticData.LIMBS_TO_PROST_GROUP_MATCH_IND_STR[limbName]
            if not modDataHandler:getIsCicatrized(limbName) and modDataHandler:getIsProstEquipped(prostGroup) then
                TOC_DEBUG.print("Trying for bleed, player met the criteria")
                -- TODO If we have cut a forearm, it will try to check the hand too, with cicatrization time = 0. We should skip this
                PlayerHandler.TryRandomBleed(self.character, limbName)
            end
        end
    end
end

--* Equipping items overrides *--

local equipPrimaryText = getText("ContextMenu_Equip_Primary")
local equipSecondaryText = getText("ContextMenu_Equip_Secondary")

local primaryHand = StaticData.PARTS_IND_STR.Hand .. "_" .. StaticData.SIDES_IND_STR.R
local secondaryHand = StaticData.PARTS_IND_STR.Hand .. "_" .. StaticData.SIDES_IND_STR.L

local prostTopR = StaticData.PROSTHESES_GROUPS_IND_STR.Top_R
local prostTopL = StaticData.PROSTHESES_GROUPS_IND_STR.Top_L

local og_ISEquipWeaponAction_isValid = ISEquipWeaponAction.isValid
---Add a condition to check the feasibility of having 2 handed weapons or if both arms are cut off
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function ISEquipWeaponAction:isValid()
    local isValid = og_ISEquipWeaponAction_isValid(self)
    local modDataHandler = ModDataHandler.GetInstance(self.character:getUsername())
    if isValid and modDataHandler:getIsAnyLimbCut() then

        -- TODO We need to consider amputating legs, this won't be correct anymore
        -- TODO Cache this!
        local isPrimaryHandValid = not modDataHandler:getIsCut(primaryHand) or modDataHandler:getIsProstEquipped(prostTopR)
        local isSecondaryHandValid = not modDataHandler:getIsCut(secondaryHand) or modDataHandler:getIsProstEquipped(prostTopL)

        --TOC_DEBUG.print("isPrimaryHandValid: " .. tostring(isPrimaryHandValid))
        --TOC_DEBUG.print("isSecondaryHandValid: " .. tostring(isSecondaryHandValid))

        -- Both hands are cut off 
        if not isPrimaryHandValid and not isSecondaryHandValid then
            --TOC_DEBUG.print("Both hands invalid")
            isValid = false
        end

        -- Equip primary and no right hand (with no prost)
        if self.jobType:contains(equipPrimaryText) and not isPrimaryHandValid then
            --TOC_DEBUG.print("Equip primary, no right hand, not valid")
            isValid = false
        end

        -- Equip secondary and no left hand (with no prost)
        if self.jobType:contains(equipSecondaryText) and not isSecondaryHandValid then
            --TOC_DEBUG.print("Equip secondary, no left hand, not valid")
            isValid = false
        end
    end

    --TOC_DEBUG.print("isValid to return -> " .. tostring(isValid))
    --print("_________________________________")
    return isValid
end


---@class ISEquipWeaponAction
---@field character IsoPlayer

---A recreation of the original method, but with amputations in mind
---@param modDataHandler ModDataHandler
function ISEquipWeaponAction:performWithAmputation(modDataHandler)

    -- TODO Simplify this
    local hand = nil
    local prostGroup = nil
    local otherHand = nil
    local otherProstGroup = nil
    local getMethodFirst = nil
    local setMethodFirst = nil
    local getMethodSecond = nil
    local setMethodSecond = nil

    if self.primary then
        hand = StaticData.LIMBS_IND_STR.Hand_R
        prostGroup = StaticData.PROSTHESES_GROUPS_IND_STR.Top_R
        otherHand = StaticData.LIMBS_IND_STR.Hand_L
        otherProstGroup = StaticData.PROSTHESES_GROUPS_IND_STR.Top_L
        getMethodFirst = self.character.getSecondaryHandItem
        setMethodFirst = self.character.setSecondaryHandItem
        getMethodSecond = self.character.getPrimaryHandItem
        setMethodSecond = self.character.setPrimaryHandItem
    else
        hand = StaticData.LIMBS_IND_STR.Hand_L
        prostGroup = StaticData.PROSTHESES_GROUPS_IND_STR.Top_L
        otherHand = StaticData.LIMBS_IND_STR.Hand_R
        otherProstGroup = StaticData.PROSTHESES_GROUPS_IND_STR.Top_R
        getMethodFirst = self.character.getPrimaryHandItem
        setMethodFirst = self.character.setPrimaryHandItem
        getMethodSecond = self.character.getSecondaryHandItem
        setMethodSecond = self.character.setSecondaryHandItem
    end


    if not self.twoHands then
        if getMethodFirst(self.character) and getMethodFirst(self.character):isRequiresEquippedBothHands() then
            setMethodFirst(self.character, nil)
        end
        -- if this weapon is already equiped in the 2nd hand, we remove it
        if(getMethodFirst(self.character) == self.item or getMethodFirst(self.character) == getMethodSecond(self.character)) then
            setMethodFirst(self.character, nil)
        end
        -- if we are equipping a handgun and there is a weapon in the secondary hand we remove it
        if instanceof(self.item, "HandWeapon") and self.item:getSwingAnim() and self.item:getSwingAnim() == "Handgun" then
            if getMethodFirst(self.character) and instanceof(getMethodFirst(self.character), "HandWeapon") then
                setMethodFirst(self.character, nil)
            end
        end
        if not getMethodSecond(self.character) or getMethodSecond(self.character) ~= self.item then
            setMethodSecond(self.character, nil)

            -- TODO We should use the CachedData indexable instead of modDataHandler

            if not modDataHandler:getIsCut(hand) then
                setMethodSecond(self.character, self.item)
            else
                setMethodFirst(self.character, self.item)
            end
        end
    else
        setMethodFirst(self.character, nil)
        setMethodSecond(self.character, nil)


        local isFirstValid = not modDataHandler:getIsCut(hand) or modDataHandler:getIsProstEquipped(prostGroup)
        local isSecondValid = not modDataHandler:getIsCut(otherHand) or modDataHandler:getIsProstEquipped(otherProstGroup)
        -- TOC_DEBUG.print("First Hand: " .. tostring(hand))
        -- TOC_DEBUG.print("Prost Group: " .. tostring(prostGroup))
        -- TOC_DEBUG.print("Other Hand: " .. tostring(otherHand))
        -- TOC_DEBUG.print("Other Prost Group: " .. tostring(otherProstGroup))

        -- TOC_DEBUG.print("isPrimaryHandValid: " .. tostring(isFirstValid))
        -- TOC_DEBUG.print("isSecondaryHandValid: " .. tostring(isSecondValid))


        if isFirstValid then
            setMethodSecond(self.character, self.item)
        end

        if isSecondValid then
            setMethodFirst(self.character, self.item)
        end
    end
end

local og_ISEquipWeaponAction_perform = ISEquipWeaponAction.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISEquipWeaponAction:perform()
    og_ISEquipWeaponAction_perform(self)

    -- TODO Can we do it earlier?
    local modDataHandler = ModDataHandler.GetInstance(self.character:getUsername())

    -- Just check it any limb has been cut. If not, we can just return from here
    if modDataHandler:getIsAnyLimbCut() == true then
        self:performWithAmputation(modDataHandler)
    end
end



return PlayerHandler