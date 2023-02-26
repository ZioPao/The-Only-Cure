------------------------------------------
------------- JUST CUT IT OFF ------------
------------------------------------------
----------- CUT LIMB FUNCTIONS -----------

-- Seems to be the first file loaded, so let's add this
if JCIO == nil then
    JCIO = {}
end







local function TocCheckIfStillInfected(limbs_data)
    if limbs_data == nil then
        return
    end
    -- Check ALL body part types to check if the player is still gonna die
    local check = false


    for _, v in pairs(JCIO_Common.GetPartNames()) do
        if limbs_data[v].is_infected then
            check = true
        end
    end

    if limbs_data.is_other_bodypart_infected then
        check = true
    end

    return check
end

local function TocCureInfection(body_damage, part_name)

    local body_part_type = body_damage:getBodyPart(JCIO_Common.GetBodyPartFromPartName(part_name))

    body_damage:setInfected(false)
    body_part_type:SetInfected(false)
    body_damage:setInfectionMortalityDuration(-1)
    body_damage:setInfectionTime(-1)
    body_damage:setInfectionLevel(0)
    local body_part_types = body_damage:getBodyParts()

    -- TODO I think this is enough... we should just cycle if with everything instead of that crap up there
    for i = body_part_types:size() - 1, 0, -1 do
        local bodyPart = body_part_types:get(i)
        bodyPart:SetInfected(false)
    end
    
    if body_part_type:scratched() then body_part_type:setScratched(false, false) end
    if body_part_type:haveGlass() then body_part_type:setHaveGlass(false) end
    if body_part_type:haveBullet() then body_part_type:setHaveBullet(false, 0) end
    if body_part_type:isInfectedWound() then body_part_type:setInfectedWound(false) end
    if body_part_type:isBurnt() then body_part_type:setBurnTime(0) end
    if body_part_type:isCut() then body_part_type:setCut(false, false) end --Lacerations
    if body_part_type:getFractureTime() > 0 then body_part_type:setFractureTime(0) end
end

local function TocDeleteOtherAmputatedLimbs(side)

    -- if left hand is cut and we cut left lowerarm, then delete hand


    for _, limb in pairs(JCIO.limbNames) do
        local part_name = "TOC.Amputation_" .. side .. "_" .. limb
        local amputated_limb = getPlayer():getInventory():FindAndReturn(part_name)
        if amputated_limb then
            getPlayer():getInventory():Remove(amputated_limb)
        end

    end

end

---@param player any
---@param perk any The perk to scale down
local function LosePerkLevel(player, perk)
    player:LoseLevel(perk)
    local actual_level = player:getPerkLevel(perk)
    local perk_xp = player:getXp()
    perk_xp:setXPToLevel(perk, actual_level)
    SyncXp(player)

end

---@param heal_bite boolean
local function TocSetParametersForMissingLimb(body_part, heal_bite)
    body_part:setBleeding(false)
    body_part:setBleedingTime(0)
    body_part:setDeepWounded(false)
    body_part:setDeepWoundTime(0)
    body_part:setScratched(false, false)        -- why the fuck are there 2 booleans TIS?
    body_part:setScratchTime(0)
    body_part:setCut(false)
    body_part:setCutTime(0)

    if heal_bite then
        body_part:SetBitten(false)
        body_part:setBiteTime(0)
    end

end

function TocDamagePlayerDuringAmputation(patient, part_name)

    -- Since we're cutting that specific part, it only makes sense that the bleeding starts from there. 
    -- Then, we just delete the bleeding somewhere else before applying the other damage to to upper part of the limb
    local body_part_type = JCIO_Common.GetBodyPartFromPartName(part_name)
    local body_damage = patient:getBodyDamage()
    local body_damage_part = body_damage:getBodyPart(body_part_type)


    body_damage_part:setBleeding(true)
    body_damage_part:setCut(true)
    body_damage_part:setBleedingTime(ZombRand(10, 20))
end

local function FindTourniquetInWornItems(patient, side)
    local worn_items = patient:getWornItems()

    for i = 1, worn_items:size() - 1 do -- Maybe wornItems:size()-1
        local item = worn_items:get(i):getItem()
        local item_full_type = item:getFullType()
        if string.find(item_full_type, "Surgery_" .. side .. "_Tourniquet") then
            return item
        end
    end

    return nil

end
----------------------------------------------------------------------------------






--- Main function for cutting a limb
---@param partName string the part name to amputate
---@param surgeonFactor any the surgeon factor, which will determine some stats for the inflicted wound
---@param bandageTable any bandages info
---@param painkillerTable any painkillers info, not used
JCIO.CutLimb = function(partName, surgeonFactor, bandageTable, painkillerTable)

    -- TODO Separate Cut Limb in side and limb instead of single part_name

    -- Items get unequipped in ISCutLimb.Start
    local player = getPlayer()

    local jcioModData = player:getModData().JCIO
    local partsParameters = jcioModData.limbParameters
    local limbsData = jcioModData.Limbs


    -- Cut Hand -> Damage in forearm
    -- Cut Forearm -> Damage in Upperarm
    -- Cut UpperArm -> Damage to torso
    local bodyDamage = player:getBodyDamage()
    local bodyPart = bodyDamage:getBodyPart(JCIO_Common.GetBodyPartFromPartName(partName))
    local adjacentBodyPart = player:getBodyDamage():getBodyPart(JCIO_Common.GetAdjacentBodyPartFromPartName(partName))

    local stats = player:getStats()



    -- Reset the status of the first body part, since we just cut it off it shouldn't be bleeding anymore
    -- The bit will be checked later since we're not sure if the player is not infected from another wound
    TocSetParametersForMissingLimb(bodyPart, false)

    -- Use a tourniquet if available
    local tourniquetItem = FindTourniquetInWornItems(player, JCIO_Common.GetSideFromPartName(partName))

    local baseDamageValue = 100

    if tourniquetItem ~= nil then
        baseDamageValue = 50  -- TODO Decrease mostly blood and damage, add pain, not everything else

        if partName == "Left_UpperArm" or partName == "Right_UpperArm" then
            player:removeWornItem(tourniquetItem)
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
    adjacentBodyPart:setBandaged(bandageTable.use_bandage, 10, bandageTable.is_bandage_sterilized,
        bandageTable.bandage_type)



    -- If painkillers are available, use them
    -- TODO add painkiller support



    -- A check for isCut shouldn't be necessary here since if we've got here we've already checked it out enough

    if limbsData[partName].isCut == false then
        limbsData[partName].isCut = true
        limbsData[partName].isAmputationShown = true
        limbsData[partName].cicatrizationTime = partsParameters[partName].cicatrizationBaseTime - surgeonFactor * 50

        for _, depended_v in pairs(limbsData[partName].depends_on) do
            limbsData[depended_v].isCut = true
            limbsData[depended_v].isAmputationShown = false
            limbsData[depended_v].cicatrizationTime = partsParameters[partName].cicatrizationBaseTime -
                surgeonFactor * 50

            local canHealDependedV = limbsData[depended_v].isInfected and
                bodyDamage:getInfectionLevel() < 20
            local depended_body_part = bodyDamage:getBodyPart(JCIO_Common.GetBodyPartFromPartName(depended_v))
            TocSetParametersForMissingLimb(depended_body_part, canHealDependedV)

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
            if TocCheckIfStillInfected(limbsData) == false then
                TocCureInfection(body_damage, partName)
                getPlayer():Say("I'm gonna be fine...")         -- TODO Make it visible to other players, check True Actions as reference
            else
                getPlayer():Say("I'm still gonna die...")
            end
        end



        -- Check for older amputation models and deletes them from player's inventory
        local side = string.match(partName, '(%w+)_')
        TocDeleteOtherAmputatedLimbs(side)

        --Equip new model for amputation
        local amputation_clothing_item_name = JCIO_Common.FindAmputatedClothingName(partName)
        print(amputation_clothing_item_name)

        local amputation_clothing_item = player:getInventory():AddItem(amputation_clothing_item_name)
        TocSetCorrectTextureForAmputation(amputation_clothing_item, player, false)
        player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)


        -- Set blood on the amputated limb
        TocSetBloodOnAmputation(getPlayer(), adjacentBodyPart)

        if partName == "Left_Foot" or partName == "Right_Foot" then
            JCIO_Anims.SetMissingFootAnimation(true)
        end
    end

end
