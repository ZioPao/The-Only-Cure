local DataController = require("TOC/Controllers/DataController")
local CommonMethods = require("TOC/CommonMethods")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local StaticData = require("TOC/StaticData")
require("TOC/Events")
-----------




-- Handle ONLY stuff for the local client

---@class LocalPlayerController
---@field playerObj IsoPlayer
---@field username string
---@field hasBeenDamaged boolean
local LocalPlayerController = {}


--* Initialization

---Setup the Player Handler and modData, only for local client
---@param isForced boolean?
function LocalPlayerController.InitializePlayer(isForced)
    local playerObj = getPlayer()
    local username = playerObj:getUsername()

    TOC_DEBUG.print("Initializing local player: " .. username)

    DataController:new(username, isForced)
    LocalPlayerController.playerObj = playerObj
    LocalPlayerController.username = username

    --Setup the CicatrizationUpdate event and triggers it once
    Events.OnAmputatedLimb.Add(LocalPlayerController.ToggleUpdateAmputations)
    LocalPlayerController.ToggleUpdateAmputations()

    -- Since isForced is used to reset an existing player data, we're gonna clean their ISHealthPanel table too
    if isForced then
        local ItemsController = require("TOC/Controllers/ItemsController")
        ItemsController.Player.DeleteAllOldAmputationItems(playerObj)
        CachedDataHandler.Setup(username)
    end

    -- Set a bool to use an overriding GetDamagedParts
    SetHealthPanelTOC()
end

---Handles the traits
---@param playerObj IsoPlayer
function LocalPlayerController.ManageTraits(playerObj)

    -- FIX This can fail if we haven't initialized TOC in time`

    local AmputationHandler = require("TOC/Handlers/AmputationHandler")
    for k, v in pairs(StaticData.TRAITS_BP) do
        if playerObj:HasTrait(k) then
            -- Once we find one, we should be done since they're exclusive
            local tempHandler = AmputationHandler:new(v, playerObj)
            tempHandler:execute(false) -- No damage
            tempHandler:close()

            -- The wound should be already cicatrized
            LocalPlayerController.HandleSetCicatrization(DataController.GetInstance(), playerObj, v)
            return
        end
    end
end

----------------------------------------------------------

--* Health *--

---Used to heal an area that has been cut previously. There's an exception for bites, those are managed differently
---@param bodyPart BodyPart
function LocalPlayerController.HealArea(bodyPart)
    bodyPart:setFractureTime(0)

    bodyPart:setScratched(false, true)
    bodyPart:setScratchTime(0)

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

---@param bodyDamage BodyDamage
---@param bodyPart BodyPart
---@param limbName string
---@param dcInst DataController
function LocalPlayerController.HealZombieInfection(bodyDamage, bodyPart, limbName, dcInst)
    if bodyDamage:isInfected() == false then return end

    bodyDamage:setInfected(false)
    bodyDamage:setInfectionMortalityDuration(-1)
    bodyDamage:setInfectionTime(-1)
    bodyDamage:setInfectionLevel(-1)
    bodyPart:SetInfected(false)

    dcInst:setIsInfected(limbName, false)
    dcInst:apply()
end

---@param character IsoPlayer
---@param limbName string
function LocalPlayerController.TryRandomBleed(character, limbName)
    -- Chance should be determined by the cicatrization time
    local cicTime = DataController.GetInstance():getCicatrizationTime(limbName)
    if cicTime == 0 then return end

    -- TODO This is just a placeholder, we need to figure out a better way to calculate this chance
    local normCicTime = CommonMethods.Normalize(cicTime, 0, StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[limbName]) / 2
    TOC_DEBUG.print("OG cicTime: " .. tostring(cicTime))
    TOC_DEBUG.print("Normalized cic time : " .. tostring(normCicTime))

    local chance = ZombRandFloat(0.0, 1.0)
    if chance > normCicTime then
        TOC_DEBUG.print("Triggered bleeding from non cicatrized wound")
        local adjacentBodyPartType = BodyPartType[StaticData.LIMBS_ADJACENT_IND_STR[limbName]]

        -- we need to check if the wound is already bleeding before doing anything else to prevent issues with bandages
        local bp = character:getBodyDamage():getBodyPart(adjacentBodyPartType)
        bp:setBleedingTime(20)      -- TODO Should depend on cicatrization instead of a fixed time
        -- ADD Could break bandages if bleeding is too much?


        --character:getBodyDamage():getBodyPart(adjacentBodyPartType):setBleeding(true)
    end
end

-------------------------
--* Damage handling  *--
--- Locks OnPlayerGetDamage event, to prevent it from getting spammed constantly
LocalPlayerController.hasBeenDamaged = false


---Check if the player has in infected body part or if they have been hit in a cut area
---@param character IsoPlayer|IsoGameCharacter
function LocalPlayerController.HandleDamage(character)
    --TOC_DEBUG.print("Player got hit!")
    -- TOC_DEBUG.print(damageType)
    if character ~= getPlayer() then
        -- Disable lock before doing anything else
        LocalPlayerController.hasBeenDamaged = false
        return
    end
    local bd = character:getBodyDamage()
    local dcInst = DataController.GetInstance()
    local modDataNeedsUpdate = false
    for i = 1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        local bptEnum = StaticData.LIMBS_TO_BODYLOCS_IND_BPT[limbName]
        local bodyPart = bd:getBodyPart(bptEnum)
        if dcInst:getIsCut(limbName) then
            -- Generic injury, let's heal it since they already cut the limb off
            if bodyPart:HasInjury() then
                TOC_DEBUG.print("Healing area - " .. limbName)
                LocalPlayerController.HealArea(bodyPart)
            end

            -- Special case for bites\zombie infections
            if bodyPart:IsInfected() then
                TOC_DEBUG.print("Healed from zombie infection - " .. limbName)
                LocalPlayerController.HealZombieInfection(bd, bodyPart, limbName, dcInst)
            end
        else
            if (bodyPart:bitten() or bodyPart:IsInfected()) and not dcInst:getIsInfected(limbName) then
                dcInst:setIsInfected(limbName, true)
                modDataNeedsUpdate = true
            end
        end
    end

    -- Check other body parts that are not included in the mod, if there's a bite there then the player is fucked
    -- We can skip this loop if the player has been infected. The one before we kinda need it to handle correctly the bites in case the player wanna cut stuff off anyway
    if not dcInst:getIsIgnoredPartInfected() then
        for i = 1, #StaticData.IGNORED_BODYLOCS_BPT do
            local bodyPartType = StaticData.IGNORED_BODYLOCS_BPT[i]
            local bodyPart = bd:getBodyPart(bodyPartType)
            if bodyPart and (bodyPart:bitten() or bodyPart:IsInfected()) then
                dcInst:setIsIgnoredPartInfected(true)
                modDataNeedsUpdate = true
            end
        end
    end

    if modDataNeedsUpdate then
        dcInst:apply()
    end

    -- Disable the lock
    LocalPlayerController.hasBeenDamaged = false
end

---Setup HandleDamage, triggered by OnPlayerGetDamage. To prevent a spam caused by this awful event, we use a bool lock
---@param character IsoPlayer|IsoGameCharacter
---@param damageType string
---@param damageAmount number
function LocalPlayerController.OnGetDamage(character, damageType, damageAmount)
    if LocalPlayerController.hasBeenDamaged == false then
        -- Start checks
        LocalPlayerController.hasBeenDamaged = true
        LocalPlayerController.HandleDamage(character)
    end
end

Events.OnPlayerGetDamage.Add(LocalPlayerController.OnGetDamage)

--* Amputation Loop handling *--

---Updates the cicatrization process, run when a limb has been cut. Run it every 1 hour
function LocalPlayerController.UpdateAmputations()
    local dcInst = DataController.GetInstance()
    if not dcInst:getIsDataReady() then
        TOC_DEBUG.print("Data not ready for UpdateAmputations, waiting next loop")
        return
    end
    if not dcInst:getIsAnyLimbCut() then
        Events.EveryHours.Remove(LocalPlayerController.UpdateAmputations)
    end

    local pl = LocalPlayerController.playerObj
    local visual = pl:getHumanVisual()
    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(pl:getUsername())
    local needsUpdate = false

    for k, _ in pairs(amputatedLimbs) do
        local limbName = k
        local isCicatrized = dcInst:getIsCicatrized(limbName)

        if not isCicatrized then
            needsUpdate = true
            local cicTime = dcInst:getCicatrizationTime(limbName)
            TOC_DEBUG.print("Updating cicatrization for " .. tostring(limbName))

            --* Dirtyness of the wound

            -- We need to get the BloodBodyPartType to find out how dirty the zone is
            local bbptEnum = BloodBodyPartType[limbName]
            local modifier = 0.01 * SandboxVars.TOC.WoundDirtynessMultiplier

            local dirtynessVis = visual:getDirt(bbptEnum) + visual:getBlood(bbptEnum)
            local dirtynessWound = dcInst:getWoundDirtyness(limbName) + modifier

            local dirtyness = dirtynessVis + dirtynessWound

            if dirtyness > 1 then
                dirtyness = 1
            end

            dcInst:setWoundDirtyness(limbName, dirtyness)
            TOC_DEBUG.print("Dirtyness for this zone: " .. tostring(dirtyness))

            --* Cicatrization

            local cicDec = SandboxVars.TOC.CicatrizationSpeed - dirtyness
            if cicDec <= 0 then cicDec = 0.1 end
            cicTime = cicTime - cicDec


            TOC_DEBUG.print("New cicatrization time: " .. tostring(cicTime))
            if cicTime <= 0 then
                LocalPlayerController.HandleSetCicatrization(dcInst, pl, limbName)
            else
                dcInst:setCicatrizationTime(limbName, cicTime)
            end
        end
    end

    if needsUpdate then
        TOC_DEBUG.print("updating modData from cicatrization loop")
        dcInst:apply() -- TODO This is gonna be heavy. Not entirely sure
    else
        TOC_DEBUG.print("Removing UpdateAmputations")
        Events.EveryHours.Remove(LocalPlayerController.UpdateAmputations) -- We can remove it safely, no cicatrization happening here boys
    end
    TOC_DEBUG.print("updating cicatrization and wound dirtyness!")
end

---Starts safely the loop to update cicatrzation
function LocalPlayerController.ToggleUpdateAmputations()
    TOC_DEBUG.print("Activating amputation handling loop (if it wasn't active before)")
    CommonMethods.SafeStartEvent("EveryHours", LocalPlayerController.UpdateAmputations)
end


--* Cicatrization and cicatrization visuals *--

---Set the boolean and cicTime in DCINST and the visuals for the amputated limb
---@param dcInst DataController
---@param playerObj IsoPlayer
---@param limbName string
function LocalPlayerController.HandleSetCicatrization(dcInst, playerObj, limbName)
    TOC_DEBUG.print(tostring(limbName) .. " is cicatrized")
    dcInst:setIsCicatrized(limbName, true)
    dcInst:setCicatrizationTime(limbName, 0)

    -- Set visuals for the amputation
    local ItemsController = require("TOC/Controllers/ItemsController")
    ItemsController.Player.OverrideAmputationItemVisuals(playerObj, limbName, true)
end

--* Object drop handling when amputation occurs


function LocalPlayerController.CanItemBeEquipped(itemObj, limbName)
    local bl = itemObj:getBodyLocation()
    local side = CommonMethods.GetSide(limbName)
    local sideStr = CommonMethods.GetSideFull(side)

    -- TODO Check from DataController

    if string.contains(limbName, "Hand_") and (bl == sideStr .. "_MiddleFinger" or bl == sideStr .. "_RingFinger") then
        return false
    end


    if string.contains(limbName, "ForeArm_") and (bl == sideStr .. "Wrist") then
        return false
    end

    return true
end

--- Drop all items from the affected limb
---@param limbName string
function LocalPlayerController.DropItemsAfterAmputation(limbName)
    TOC_DEBUG.print("Triggered DropItemsAfterAmputation")
    local side = CommonMethods.GetSide(limbName)
    local sideStr = CommonMethods.GetSideFull(side)

    local pl = getPlayer()
    local wornItems = pl:getWornItems()

    for i = 1, wornItems:size() do
        local it = wornItems:get(i - 1)
        if it then
            local wornItem = wornItems:get(i - 1):getItem()
            TOC_DEBUG.print(wornItem:getBodyLocation())

            local bl = wornItem:getBodyLocation()
            if string.contains(limbName, "Hand_") and (bl == sideStr .. "_MiddleFinger" or bl == sideStr .. "_RingFinger") then
                pl:removeWornItem(wornItem)
            end


            if string.contains(limbName, "ForeArm_") and (bl == sideStr .. "Wrist") then
                pl:removeWornItem(wornItem)
            end
        end
    end

    -- TODO Consider 2 handed weapons too

    -- equipped items too
    if side == "R" then
        pl:setPrimaryHandItem(nil)
    elseif side == "L" then
        pl:setSecondaryHandItem(nil)
    end

end

Events.OnAmputatedLimb.Add(LocalPlayerController.DropItemsAfterAmputation)
Events.OnProsthesisUnequipped.Add(LocalPlayerController.DropItemsAfterAmputation)



return LocalPlayerController
