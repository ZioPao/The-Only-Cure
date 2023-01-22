-- Helper for DropItem
function TheOnlyCure.CheckIfCanPickUpItem(toc_data, side, limb, secondary_limb)


    -- TODO we can use this when uninstall prost or when cutting
    local full_primary_limb = side .. limb
    local full_secondary_limb = side .. secondary_limb


    return toc_data[full_primary_limb].is_cut and
        not (toc_data[full_primary_limb].is_prosthesis_equipped or toc_data[full_secondary_limb]) or
        (toc_data[full_secondary_limb].is_cut and not toc_data[full_secondary_limb].is_prosthesis_equipped)


end

function TheOnlyCure.CheckIfPlayerIsInfected(player, toc_data)

    local body_damage = player:getBodyDamage()

    for _, v in ipairs(GetLimbsBodyPartTypes()) do
        local part_name = TocGetPartNameFromBodyPartType(v)
        local part_data = toc_data.Limbs[part_name]


        if body_damage:getBodyPart(v):bitten() and part_data ~= nil then
            if part_data.is_cut == false then
                part_data.is_infected = true
            end

        end
    end

    for _, v in ipairs(GetOtherBodyPartTypes()) do
        if body_damage:getBodyPart(v):bitten() then
            toc_data.Limbs.is_other_bodypart_infected = true -- Even one is enough, stop cycling if we find it
            break
        end
    end
end

function TheOnlyCure.UpdatePlayerHealth(player, part_data)
    local body_damage = player:getBodyDamage()



    if player:HasTrait("Insensitive") then body_damage:setPainReduction(49) end

    for i, part_name in pairs(GetBodyParts()) do
        if part_data[part_name].is_cut then
            TheOnlyCure.SetHealthStatusForBodyPart(part_data, part_name, player)

        end
    end



end

--Helper function for UpdatePlayerHealth
function TheOnlyCure.SetHealthStatusForBodyPart(part_data, part_name, player)

    -- TODO this can be moved away from updates

    local body_damage = player:getBodyDamage()
    local body_part_type = body_damage:getBodyPart(TocGetBodyPartTypeFromPartName(part_name))
    if not body_part_type then
        print("TOC ERROR : Can't update health of " .. part_name);
        return false
    end

    -- Check bandages
    local is_bandaged = false
    local bandage_life = 0
    local bandage_type = ""

    -- TODO Bandages should have some disadvantage when not operated... Like getting drenched or something
    if body_part_type:bandaged() then
        is_bandaged = true -- this is useless
        bandage_life = body_part_type:getBandageLife()
        bandage_type = body_part_type:getBandageType()

    end

    -- Set max health for body part
    if part_data[part_name].is_cicatrized and body_part_type:getHealth() > 80 then
        body_part_type:SetHealth(80)
    elseif body_part_type:getHealth() > 40 then
        body_part_type:SetHealth(40)
    end

    -- Cicatrization check
    if part_data[part_name].is_cut and not part_data[part_name].is_cicatrized then
        if part_data[part_name].cicatrization_time < 0 then
            part_data[part_name].is_cicatrized = true

            -- TODO make this random if the player gets it or not

            if (not player:HasTrait("Brave")) and ZombRand(1, 11) > 5 then
                player:getTraits():add("Brave")

            end

            if (not player:HasTrait("Insensitive")) and ZombRand(1, 11) > 5 then
                player:getTraits():add("Insensitive")
            end

            body_part_type:setBleeding(false);
            body_part_type:setDeepWounded(false)
            body_part_type:setBleedingTime(0)
            body_part_type:setDeepWoundTime(0)
        end
    end

    -- Phantom Pain
    if part_data[part_name].is_amputation_shown and ZombRand(1, 100) < 10 then
        local added_pain
        if part_data[part_name].is_cauterized then added_pain = 60 else added_pain = 30 end
        body_part_type:setAdditionalPain(ZombRand(1, added_pain))
    end

    -- Reapplies bandages after the whole ordeal
    -- TODO not sure if this still works
    --body_part_type:setBandaged(true, bandage_life, false, bandage_type)
end

--Helper function for UpdatePlayerHealth
function TheOnlyCure.CheckIfOtherLimbsAreInfected(part_data, part_name)


    local body_parts = GetBodyParts()
    body_parts[part_name] = nil

    for _, v in pairs(body_parts) do
        if part_data[v].is_infected then
            return true
        end
    end
    return false
end

-- MAIN UPDATE FUNCTIONS

function TheOnlyCure.UpdateEveryOneMinute()

    local player = getPlayer()
    -- To prevent errors during loading
    if player == nil then
        return
    end

    local toc_data = player:getModData().TOC

    if toc_data ~= nil then
        TheOnlyCure.CheckIfPlayerIsInfected(player, toc_data)
        TheOnlyCure.UpdatePlayerHealth(player, toc_data.Limbs)
    end



    if toc_data ~= nil then
        sendClientCommand(player, 'TOC', 'ChangePlayerState', { toc_data.Limbs } )
    end





end

function TheOnlyCure.UpdateEveryTenMinutes()

    local player = getPlayer()

    if player == nil then
        return
    end
    local toc_data = player:getModData().TOC
    local part_data = toc_data.Limbs

    --Experience for prosthesis user
    for _, side in ipairs(TOC_sides) do
        if part_data[side .. "_Hand"].is_prosthesis_equipped or part_data[side .. "_LowerArm"].is_prosthesis_equipped then
            player:getXp():AddXP(Perks[side .. "_Hand"], 4)
        end

    end

    -- Updates the cicatrization time
    for _, part_name in pairs(GetBodyParts()) do
        if part_data[part_name].is_cut and not part_data[part_name].is_cicatrized then
            part_data[part_name].cicatrization_time = part_data[part_name].cicatrization_time - 1 -- TODO Make it more "dynamic"
        end
    end

end

Events.EveryTenMinutes.Add(TheOnlyCure.UpdateEveryTenMinutes)
Events.EveryOneMinute.Add(TheOnlyCure.UpdateEveryOneMinute)
