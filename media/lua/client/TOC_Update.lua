-- Makes the player drop an item if they don't have a limb or haven't equipped a prosthesis
function TheOnlyCure.TryDropItem(player, toc_data)
    if TheOnlyCure.CheckIfCanPickUpItem(toc_data, Right, Hand, Forearm) and player:getPrimaryHandItem() ~= nil then
        if player:getPrimaryHandItem():getName() ~= "Bare Hands" then
            player:dropHandItems()
        end
    end

    if TheOnlyCure.CheckIfCanPickUpItem(toc_data, Left, Hand, Forearm) and player:getSecondaryHandItem() ~= nil then
        if player:getSecondaryHandItem():getName() ~= "Bare Hands" then
            player:dropHandItems()
        end
    end

    
end

-- Helper for DropItem
function TheOnlyCure.CheckIfCanPickUpItem(toc_data, side, limb, secondary_limb)
    
    local full_primary_limb = side .. limb
    local full_secondary_limb = side .. secondary_limb


    return toc_data[full_primary_limb].is_cut and not (toc_data[full_primary_limb].is_prosthesis_equipped or toc_data[full_secondary_limb]) or
            (toc_data[full_secondary_limb].is_cut and not toc_data[full_secondary_limb].is_prosthesis_equipped)

    
end

function TheOnlyCure.CheckIfPlayerIsInfected(player, toc_data)

    local body_damage = player:getBodyDamage()

    for _, v in ipairs(GetLimbsBodyPartTypes()) do
        local toc_bodypart = FindTocDataPartNameFromBodyPartType(toc_data.Limbs, v)
        if body_damage:getBodyPart(v):bitten() and toc_bodypart ~= nil then
            if toc_bodypart.is_cut == false then
                toc_bodypart.is_infected = true
                player:transmitModData()
            end
 
        end
    end

    for _, v in ipairs(GetOtherBodyPartTypes()) do
        if body_damage:getBodyPart(v):bitten() then 
            toc_data.is_other_bodypart_infected = true      -- Even one is enough, stop cycling if we find it
            player:transmitModData()
            break
        end
    end
end

function TheOnlyCure.UpdatePlayerHealth(player, toc_data)
    local body_damage = player:getBodyDamage()



    if player:HasTrait("Insensitive") then body_damage:setPainReduction(49) end

    for i, part_name in pairs(GetBodyParts()) do
        if toc_data[part_name].is_cut then
            TheOnlyCure.HealSpecificPart(toc_data, part_name, player)
                
        end
    end

    player:transmitModData()


end

--Helper function for UpdatePlayerHealth
function TheOnlyCure.HealSpecificPart(toc_data, part_name, player)


    local body_damage = player:getBodyDamage()
    local body_part_type = body_damage:getBodyPart(TocGetBodyPartTypeFromBodyPart(part_name))
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
        is_bandaged = true      -- this is useless 
        bandage_life = body_part_type:getBandageLife()
        bandage_type = body_part_type:getBandageType()

    end



    -- Set max health
    if toc_data[part_name].is_cicatrized and body_part_type:getHealth() > 80 then
        body_part_type:SetHealth(80)
    elseif body_part_type:getHealth() > 40 then
        body_part_type:SetHealth(40)
    end

    -- This is useless here. We don't need to do this every single time, only after operation
--   if modData_part.is_cicatrized then
--         if bodyPart:deepWounded()   then bodyPart:setDeepWounded(false) end
--         if bodyPart:bleeding()      then bodyPart:setBleeding(false) end
--     end


    -- Check if we can heal the infection
    if body_part_type:bitten() then
        body_part_type:SetBitten(false)
        if not toc_data[part_name].is_other_bodypart_infected and not TheOnlyCure.CheckIfOtherLimbsAreInfected(toc_data, part_name) then
            body_part_type:setInfected(false)
            body_part_type:setInfectionMortalityDuration(-1)
            body_part_type:setInfectionTime(-1)
            body_part_type:setInfectionLevel(0)
            local body_part_types = body_damage:getBodyParts()

            -- TODO I think this is enough... we should just cycle if with everything instead of that crap up there
            for i=body_part_types:size()-1, 0, -1  do
                local bodyPart = body_part_types:get(i);
                bodyPart:SetInfected(false);
            end
        end
    end

    if body_part_type:scratched()         then body_part_type:setScratched(false, false) end
    if body_part_type:haveGlass()         then body_part_type:setHaveGlass(false)        end
    if body_part_type:haveBullet()        then body_part_type:setHaveBullet(false, 0)    end
    if body_part_type:isInfectedWound()   then body_part_type:setInfectedWound(false)    end
    if body_part_type:isBurnt()           then body_part_type:setBurnTime(0)             end
    if body_part_type:isCut()             then body_part_type:setCut(false, false)       end        --Lacerations
    if body_part_type:getFractureTime()>0 then body_part_type:setFractureTime(0)         end

    -- Cicatrization check
    if toc_data[part_name].is_cut and not toc_data[part_name].is_cicatrized then
        if toc_data[part_name].cicatrization_time < 0 then
            toc_data[part_name].is_cicatrized = true

            -- TODO make this random if the player gets it or not
            --FIXME they're gonna stack!!!!

            -- if player does not have brave then add it 
            -- if player does not have insensitve then add it 

            player:getTraits():add("Brave")
            player:getTraits():add("Insensitive")
            body_part_type:setBleeding(false);
            body_part_type:setDeepWounded(false)
            body_part_type:setBleedingTime(0)
            body_part_type:setDeepWoundTime(0)
        end
    end

    -- Phantom Pain
    if toc_data[part_name].is_amputation_shown and ZombRand(1, 100) < 10 then
        local added_pain
        if toc_data[part_name].is_cauterized then added_pain = 60 else added_pain = 30 end
        body_part_type:setAdditionalPain(ZombRand(1, added_pain))
    end

    -- Reapplies bandages after the whole ordeal
    -- TODO not sure if this still works
    --body_part_type:setBandaged(true, bandage_life, false, bandage_type)
end

--Helper function for UpdatePlayerHealth
function TheOnlyCure.CheckIfOtherLimbsAreInfected(toc_data, part_name)


    local body_parts = GetBodyParts()
    body_parts[part_name] = nil

    for _,v in pairs(body_parts) do
        if toc_data[v].is_infected then
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
        --TheOnlyCure.TryDropItem(player, toc_data)       -- TODO this must be set only in the cut\equipping function, not here
        TheOnlyCure.CheckIfPlayerIsInfected(player, toc_data)
        TheOnlyCure.UpdatePlayerHealth(player, toc_data)
    end

end

function TheOnlyCure.UpdateEveryTenMinutes()

    local player = getPlayer()

    if player == nil then
        return
    end
    local part_data = player:getModData().TOC.Limbs


    --Experience for prosthesis user
    for _, side in ipairs({"Left", "Right"}) do
        if part_data[side .. "_Hand"].is_prosthesis_equipped or part_data[side .. "_LowerArm"].is_prosthesis_equipped then
            player:getXp():AddXP(Perks[side .. "_Hand"], 4)
        end

    end

    -- Updates the cicatrization time
    for _, part_name in pairs(GetBodyParts()) do
        if part_data[part_name].is_cut and not part_data[part_name].is_cicatrized then
            part_data[part_name].cicatrization_time = part_data[part_name].cicatrization_time - 1     -- TODO Make it more "dynamic"

            
        end
    end
    
    player:transmitModData()
end


Events.EveryTenMinutes.Add(TheOnlyCure.UpdateEveryTenMinutes)
Events.EveryOneMinute.Add(TheOnlyCure.UpdateEveryOneMinute)