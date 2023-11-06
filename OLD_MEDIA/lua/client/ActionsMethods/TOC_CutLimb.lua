------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
----------- CUT LIMB FUNCTIONS -----------

-- Seems to be the first file loaded, so let's add this
if TOC == nil then
    TOC = {}
end



local function CheckIfStillInfected(limbsData)
    if limbsData == nil then
        return
    end
    -- Check ALL body part types to check if the player is still gonna die
    local check = false


    for _, v in pairs(TOC_Common.GetPartNames()) do
        if limbsData[v].isInfected then
            check = true
        end
    end

    if limbsData.isOtherBodypartInfected then
        check = true
    end

    return check
end

local function CureInfection(bodyDamage, partName)

    local bodyPartType = bodyDamage:getBodyPart(TOC_Common.GetBodyPartFromPartName(partName))

    bodyDamage:setInfected(false)
    bodyPartType:SetInfected(false)
    bodyDamage:setInfectionMortalityDuration(-1)
    bodyDamage:setInfectionTime(-1)
    bodyDamage:setInfectionLevel(0)
    local bodypartTypesTable = bodyDamage:getBodyParts()

    -- TODO I think this is enough... we should just cycle if with everything instead of that crap up there
    for i = bodypartTypesTable:size() - 1, 0, -1 do
        local bodyPart = bodypartTypesTable:get(i)
        bodyPart:SetInfected(false)
    end
    
    if bodyPartType:scratched() then bodyPartType:setScratched(false, false) end
    if bodyPartType:haveGlass() then bodyPartType:setHaveGlass(false) end
    if bodyPartType:haveBullet() then bodyPartType:setHaveBullet(false, 0) end
    if bodyPartType:isInfectedWound() then bodyPartType:setInfectedWound(false) end
    if bodyPartType:isBurnt() then bodyPartType:setBurnTime(0) end
    if bodyPartType:isCut() then bodyPartType:setCut(false, false) end --Lacerations
    if bodyPartType:getFractureTime() > 0 then bodyPartType:setFractureTime(0) end
end

local function DeleteOtherAmputatedLimbs(side)
    -- if left hand is cut and we cut left lowerarm, then delete hand
    for _, limb in pairs(TOC.limbNames) do
        local partName = "TOC.Amputation_" .. TOC_Common.ConcatPartName(side, limb)
        local amputatedLimbItem = getPlayer():getInventory():FindAndReturn(partName)
        if amputatedLimbItem then
            getPlayer():getInventory():Remove(amputatedLimbItem)
        end

    end

end

---@param player any
---@param perk any The perk to scale down
local function LosePerkLevel(player, perk)
    player:LoseLevel(perk)
    local actualLevel = player:getPerkLevel(perk)
    local perkXp = player:getXp()
    perkXp:setXPToLevel(perk, actualLevel)
    SyncXp(player)

end

---@param isHealingBite boolean
local function SetParametersForMissingLimb(bodyPart, isHealingBite)
    bodyPart:setBleeding(false)
    bodyPart:setBleedingTime(0)
    bodyPart:setDeepWounded(false)
    bodyPart:setDeepWoundTime(0)
    bodyPart:setScratched(false, false)        -- why the fuck are there 2 booleans TIS?
    bodyPart:setScratchTime(0)
    bodyPart:setCut(false)
    bodyPart:setCutTime(0)

    if isHealingBite then
        bodyPart:SetBitten(false)
        bodyPart:setBiteTime(0)
    end

end

function TOC.DamagePlayerDuringAmputation(patient, partName)

    -- Since we're cutting that specific part, it only makes sense that the bleeding starts from there. 
    -- Then, we just delete the bleeding somewhere else before applying the other damage to to upper part of the limb
    local bodyPartType = TOC_Common.GetBodyPartFromPartName(partName)
    local bodyDamage = patient:getBodyDamage()
    local bodyDamagePart = bodyDamage:getBodyPart(bodyPartType)


    bodyDamagePart:setBleeding(true)
    bodyDamagePart:setCut(true)
    bodyDamagePart:setBleedingTime(ZombRand(10, 20))
end

local function FindTourniquetInWornItems(patient, side)
    
    local checkString = "Surgery_" .. side .. "_Tourniquet"
    local item = TOC_Common.FindItemInWornItems(patient, checkString)
    return item

end

local function FindWristWatchInWornItems(patient, side)
    local checkString = "Watch_" .. side
    local item = TOC_Common.FindItemInWornItems(patient, checkString)
    return item

end
----------------------------------------------------------------------------------






--- Main function for cutting a limb
---@param partName string the part name to amputate
---@param surgeonFactor any the surgeon factor, which will determine some stats for the inflicted wound
---@param bandageTable any bandages info
---@param painkillerTable any painkillers info, not used
TOC.CutLimb = function(partName, surgeonFactor, bandageTable, painkillerTable)

    -- TODO Separate Cut Limb in side and limb instead of single part_name

    -- Items get unequipped in ISCutLimb.Start
    local player = getPlayer()

    local TOCModData = player:getModData().TOC
    local limbParameters = TOC.limbParameters
    local limbsData = TOCModData.limbs


    -- Cut Hand -> Damage in forearm
    -- Cut Forearm -> Damage in Upperarm
    -- Cut UpperArm -> Damage to torso
    local bodyDamage = player:getBodyDamage()
    local bodyPart = bodyDamage:getBodyPart(TOC_Common.GetBodyPartFromPartName(partName))
    local adjacentBodyPart = player:getBodyDamage():getBodyPart(TOC_Common.GetAdjacentBodyPartFromPartName(partName))

    local stats = player:getStats()
    local side = TOC_Common.GetSideFromPartName(partName)



    -- Reset the status of the first body part, since we just cut it off it shouldn't be bleeding anymore
    -- The bit will be checked later since we're not sure if the player is not infected from another wound
    SetParametersForMissingLimb(bodyPart, false)

    -- Use a tourniquet if available
    local tourniquetItem = FindTourniquetInWornItems(player, side)

    local baseDamageValue = 100

    if tourniquetItem ~= nil then
        baseDamageValue = 50  -- TODO Decrease mostly blood and damage, add pain, not everything else

        if partName == TOC_Common.ConcatPartName(side, "UpperArm") then
            player:removeWornItem(tourniquetItem)
        end
    end


    -- Removes wrist watches in case they're amputating the same side where they equipped it
    local wristWatchItem = FindWristWatchInWornItems(player, side)

    if wristWatchItem ~= nil then
        if partName == side .. "_LowerArm" or partName == side .. "_UpperArm" then
            player:removeWornItem(wristWatchItem)
        end
    end





    -- Set damage, stress, and low endurance after amputation
    adjacentBodyPart:AddDamage(baseDamageValue - surgeonFactor)
    adjacentBodyPart:setAdditionalPain(baseDamageValue - surgeonFactor)
    adjacentBodyPart:setBleeding(true)
    adjacentBodyPart:setBleedingTime(baseDamageValue - surgeonFactor)
    adjacentBodyPart:setDeepWounded(true)
    adjacentBodyPart:setDeepWoundTime(baseDamageValue - surgeonFactor)
    stats:setEndurance(surgeonFactor)
    stats:setStress(baseDamageValue - surgeonFactor)


    -- Set malus for strength and fitness
    -- TODO Make it more "random" with just some XP scaling down instead of a whole level, depending on the limb that we're cutting
    LosePerkLevel(player, Perks.Fitness)
    LosePerkLevel(player, Perks.Strength)



    -- If bandages are available, use them
    adjacentBodyPart:setBandaged(bandageTable.useBandage, 10, bandageTable.isBandageSterilized,
        bandageTable.bandageType)



    -- If painkillers are available, use them
    -- TODO add painkiller support



    -- A check for isCut shouldn't be necessary here since if we've got here we've already checked it out enough

    if limbsData[partName].isCut == false then
        limbsData[partName].isCut = true
        limbsData[partName].isAmputationShown = true
        limbsData[partName].cicatrizationTime = limbParameters[partName].cicatrizationBaseTime - surgeonFactor * 50

        for _, depended_v in pairs(limbParameters[partName].dependsOn) do
            limbsData[depended_v].isCut = true
            limbsData[depended_v].isAmputationShown = false
            limbsData[depended_v].cicatrizationTime = limbParameters[partName].cicatrizationBaseTime -
                surgeonFactor * 50

            local canHealDependedV = limbsData[depended_v].isInfected and
                bodyDamage:getInfectionLevel() < 20
            local depended_body_part = bodyDamage:getBodyPart(TOC_Common.GetBodyPartFromPartName(depended_v))
            SetParametersForMissingLimb(depended_body_part, canHealDependedV)

            if canHealDependedV then
                limbsData[depended_v].isInfected = false
            end


            
        end


        -- Heal the infection here
        local body_damage = player:getBodyDamage()
        if limbsData[partName].isInfected and body_damage:getInfectionLevel() < 20 then
            limbsData[partName].isInfected = false

            -- NOT THE ADIACENT ONE!!!
            bodyPart:SetBitten(false)
            bodyPart:setBiteTime(0)

            -- Second check, let's see if there is any other infected limb.
            if CheckIfStillInfected(limbsData) == false then
                CureInfection(body_damage, partName)
                getPlayer():Say("I'm gonna be fine...")         -- TODO Make it visible to other players, check True Actions as reference
            else
                getPlayer():Say("I'm still gonna die...")
            end
        end



        -- Check for older amputation models and deletes them from player's inventory
        local side = string.match(partName, '(%w+)_')
        DeleteOtherAmputatedLimbs(side)

        --Equip new model for amputation
        local amputation_clothing_item_name = TOC_Common.FindAmputatedClothingName(partName)
        print(amputation_clothing_item_name)

        local amputation_clothing_item = player:getInventory():AddItem(amputation_clothing_item_name)
        TOC_Visuals.SetTextureForAmputation(amputation_clothing_item, player, false)
        player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)


        -- Set blood on the amputated limb
        TOC_Visuals.SetBloodOnAmputation(getPlayer(), adjacentBodyPart)

        if partName == "Left_Foot" or partName == "Right_Foot" then
            TOC_Anims.SetMissingFootAnimation(true)
        end
    end

end
