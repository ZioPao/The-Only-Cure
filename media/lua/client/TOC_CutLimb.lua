------------------------------------------
-------- THE ONLY CURE BUT BETTER --------
------------------------------------------
----------- CUT LIMB FUNCTIONS -----------

local function TocCheckIfStillInfected(limbs_data)
    if limbs_data == nil then
        return
    end
    -- Check ALL body part types to check if the player is still gonna die
    local check = false


    for _, v in ipairs(GetBodyParts()) do
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

    local body_part_type = body_damage:getBodyPart(TocGetBodyPartFromPartName(part_name))

    body_damage:setInfected(false)
    body_part_type:SetInfected(false)
    body_damage:setInfectionMortalityDuration(-1)
    body_damage:setInfectionTime(-1)
    body_damage:setInfectionLevel(0)
    local body_part_types = body_damage:getBodyParts()

    -- TODO I think this is enough... we should just cycle if with everything instead of that crap up there
    for i = body_part_types:size() - 1, 0, -1 do
        local bodyPart = body_part_types:get(i);
        bodyPart:SetInfected(false);
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


    for _, limb in pairs(TOC_limbs) do
        local part_name = "TOC.Amputation_" .. side .. "_" .. limb
        local amputated_limb = getPlayer():getInventory():FindAndReturn(part_name)
        if amputated_limb then
            getPlayer():getInventory():Remove(amputated_limb)
        end

    end

end

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
    local body_part_type = TocGetBodyPartFromPartName(part_name)
    local body_damage = patient:getBodyDamage()
    local body_damage_part = body_damage:getBodyPart(body_part_type)


    body_damage_part:setBleeding(true)
    body_damage_part:setCut(true)
    body_damage_part:setBleedingTime(ZombRand(10, 20))
end

----------------------------------------------------------------------------------

--- Main function for cutting a limb
---@param part_name string the part name to amputate
---@param surgeon_factor any the surgeon factor, which will determine some stats for the inflicted wound
---@param bandage_table any bandages info
---@param painkiller_table any painkillers info, not used
function TocCutLimb(part_name, surgeon_factor, bandage_table, painkiller_table)

    -- TODO Separate Cut Limb in side and limb instead of single part_name

    -- Items get unequipped in ISCutLimb.Start

    local player = getPlayer()
    local toc_data = player:getModData().TOC
    local limbs_data = toc_data.Limbs



    -- TODO Stop for a bit,

    -- Cut Hand -> Damage in forearm
    -- Cut Forearm -> Damage in Upperarm
    -- Cut UpperArm -> Damage to torso

    local body_damage = player:getBodyDamage()
    local body_part = body_damage:getBodyPart(TocGetBodyPartFromPartName(part_name))
    local adiacent_body_part = player:getBodyDamage():getBodyPart(TocGetAdiacentBodyPartFromPartName(part_name))

    local stats = player:getStats()



    -- Reset the status of the first body part, since we just cut it off it shouldn't be bleeding anymore
    -- The bit will be checked later since we're not sure if the player is not infected from another wound
    TocSetParametersForMissingLimb(body_part, false)

    -- Set damage, stress, and low endurance after amputation
    adiacent_body_part:AddDamage(100 - surgeon_factor)
    adiacent_body_part:setAdditionalPain(100 - surgeon_factor)
    adiacent_body_part:setBleeding(true)
    adiacent_body_part:setBleedingTime(100 - surgeon_factor)
    adiacent_body_part:setDeepWounded(true)
    adiacent_body_part:setDeepWoundTime(100 - surgeon_factor)
    stats:setEndurance(surgeon_factor)
    stats:setStress(100 - surgeon_factor)


    -- Set malus for strength and fitness
    LosePerkLevel(player, Perks.Fitness)
    LosePerkLevel(player, Perks.Strength)

    -- If bandages are available, use them
    adiacent_body_part:setBandaged(bandage_table.use_bandage, 10, bandage_table.is_bandage_sterilized,
        bandage_table.bandage_type)


    -- If painkillers are available, use them
    -- TODO add painkiller support

    -- Use a tourniquet if available
    -- TODO add tourniquet

    if limbs_data[part_name].is_cut == false then
        limbs_data[part_name].is_cut = true
        limbs_data[part_name].is_amputation_shown = true
        limbs_data[part_name].cicatrization_time = limbs_data[part_name].cicatrization_base_time - surgeon_factor * 50

        for _, depended_v in pairs(limbs_data[part_name].depends_on) do
            limbs_data[depended_v].is_cut = true
            limbs_data[depended_v].is_amputation_shown = false
            limbs_data[depended_v].cicatrization_time = limbs_data[part_name].cicatrization_base_time -
                surgeon_factor * 50

            local should_depended_v_be_healed_of_bite = limbs_data[depended_v].is_infected and
                body_damage:getInfectionLevel() < 20
            local depended_body_part = body_damage:getBodyPart(TocGetBodyPartFromPartName(depended_v))
            TocSetParametersForMissingLimb(depended_body_part, should_depended_v_be_healed_of_bite)

            if should_depended_v_be_healed_of_bite then
                limbs_data[depended_v].is_infected = false
            end


            
        end


        -- Heal the infection here
        local body_damage = player:getBodyDamage()
        if limbs_data[part_name].is_infected and body_damage:getInfectionLevel() < 20 then
            limbs_data[part_name].is_infected = false

            -- NOT THE ADIACENT ONE!!!
            body_part:SetBitten(false)
            body_part:setBiteTime(0)

            -- Second check, let's see if there is any other infected limb.
            if TocCheckIfStillInfected(limbs_data) == false then
                TocCureInfection(body_damage, part_name)
                getPlayer():Say("I'm gonna be fine...")         -- TODO Make it visible to other players, check True Actions as reference
            else
                getPlayer():Say("I'm still gonna die...")
            end
        end



        -- Check for older amputation models and deletes them from player's inventory
        local side = string.match(part_name, '(%w+)_')
        TocDeleteOtherAmputatedLimbs(side)

        --Equip new model for amputation
        local amputation_clothing_item = player:getInventory():AddItem(TocFindAmputatedClothingFromPartName(part_name))
        TocSetCorrectTextureForAmputation(amputation_clothing_item, player, false)
        player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)


        -- Set blood on the amputated limb
        TocSetBloodOnAmputation(getPlayer(), adiacent_body_part)
    end

end
