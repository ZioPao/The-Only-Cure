-- CutLimb
-- TODO if TheONlyCure. triggers an errors
function TocCheckIfStillInfected(part_data)
    if part_data == nil then
        return
    end
    -- Check ALL body part types to check if the player is still gonna die
    local check = false


    for _, v in ipairs(GetBodyParts()) do
        if part_data[v].is_infected then
            check = true
        end
    end

    if part_data.is_other_bodypart_infected then
        check = true
    end

    return check
end

function TocCureInfection(body_damage, part_data, part_name)

    local body_part_type = body_damage:getBodyPart(TocGetBodyPartTypeFromPartName(part_name))

    -- Check if we can heal the infection
    local is_other_bodypart_infected = getPlayer():getModData().TOC.Limbs.is_other_bodypart_infected

    if not is_other_bodypart_infected and not TheOnlyCure.CheckIfOtherLimbsAreInfected(part_data, part_name) then
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
    end


    if body_part_type:scratched() then body_part_type:setScratched(false, false) end
    if body_part_type:haveGlass() then body_part_type:setHaveGlass(false) end
    if body_part_type:haveBullet() then body_part_type:setHaveBullet(false, 0) end
    if body_part_type:isInfectedWound() then body_part_type:setInfectedWound(false) end
    if body_part_type:isBurnt() then body_part_type:setBurnTime(0) end
    if body_part_type:isCut() then body_part_type:setCut(false, false) end --Lacerations
    if body_part_type:getFractureTime() > 0 then body_part_type:setFractureTime(0) end





end

function TocDeleteOtherAmputatedLimbs(side)

    -- if left hand is cut and we cut left lowerarm, then delete hand


    for _, limb in pairs(TOC_limbs) do
        local part_name = "TOC.Amputation_" .. side .. "_" .. limb
        local amputated_limb = getPlayer():getInventory():FindAndReturn(part_name)
        if amputated_limb then
            getPlayer():getInventory():Remove(amputated_limb)
        end

    end

end

function TocGetKitInInventory(surgeon)
    local playerInv = surgeon:getInventory();
    local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or
        playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
    return item

end

function TocGetSawInInventory(surgeon)

    local player_inv = surgeon:getInventory()
    local item = player_inv:getItemFromType("Saw") or player_inv:getItemFromType("GardenSaw") or
        player_inv:getItemFromType("Chainsaw")
    return item
end

-- OperateLimb
function SetBodyPartsStatusAfterOperation(player, part_data, part_name, use_oven)
    --for _, v in ipairs(GetBodyParts()) do


    local body_part_type = player:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromPartName(part_name))
    FixSingleBodyPartType(body_part_type, use_oven)

    for _, v in ipairs(part_data[part_name].depends_on) do
        local depended_body_part_type = player:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromPartName(v))
        FixSingleBodyPartType(depended_body_part_type, use_oven)

    end
end

function FixSingleBodyPartType(body_part_type, use_oven)
    body_part_type:setDeepWounded(false) --Basically like stitching
    body_part_type:setDeepWoundTime(0)
    if use_oven then
        body_part_type:AddDamage(100)
        body_part_type:setAdditionalPain(100);
        body_part_type:setBleeding(false)
        body_part_type:setBleedingTime(0) -- no bleeding since it's been cauterized
    else
        -- TODO Think a little better about this, do we want to trigger bleeding or not?
        body_part_type:setBleeding(false)

        --body_part_type:setBleedingTime(ZombRand(1, 5))   -- Reset the bleeding, maybe make it random
    end
end



-- Unequip Prosthesis

local function PartNameToBodyLocation(name)
    -- This is still correct but naming sucks
    if name == "Right_Hand" then return "ArmRight_Prot" end
    if name == "Right_LowerArm" then return "ArmRight_Prot" end
    if name == "Right_UpperArm" then return "ArmRight_Prot" end
    if name == "Left_Hand" then return "ArmLeft_Prot" end
    if name == "Left_LowerArm" then return "ArmLeft_Prot" end
    if name == "Left_UpperArm" then return "ArmLeft_Prot" end
end

function TocFindItemInProstBodyLocation(part_name, patient)
    -- FIXME this can return even amputated limbs, and we're using it only for prosthetics. This is gonna break sooner or later

    -- Can't be used for online purposes, since we can't get the online inventory of another player
    local worn_items = patient:getWornItems()

    for i = 1, worn_items:size() - 1 do -- Maybe wornItems:size()-1
        local item = worn_items:get(i):getItem()
        if item:getBodyLocation() == PartNameToBodyLocation(part_name) then
            return item
        end
    end

end



-------------------------------------
-- Override helper

function CheckIfItemIsAmputatedLimb(item)
    -- TODO Benchmark if this is faster
    local item_full_type = item:getFullType()


    if string.find(item_full_type, "TOC.Amputation_") then
        return true
    else
        return false
    end


end

-- function CheckIfItemIsAmputatedLimb(item)


--     local item_full_type = item:getFullType()

--     local sides = {"Left", "Right"}
--     local limbs_to_check = {"Hand", "LowerArm", "UpperArm"}

--     local is_amputated_limb = false

--     for _, part in ipairs(limbs_to_check) do
--         for _, side in ipairs(sides) do

--             local part_name = side .. "_" .. part

--             local check_name = "TOC.Amputation_" .. part_name
--             print(check_name)
--             if item_full_type == check_name then
--                 is_amputated_limb = true
--                 break
--             end

--         end

--     end


--     return is_amputated_limb

-- end

function CheckIfItemIsProsthesis(item)

    -- TODO find a cleaner way
    local item_full_type = item:getFullType()
    local prosthesis_list = GetProsthesisList()

    for _, v in pairs(prosthesis_list) do
        if v == item_full_type then
            return true
        end
    end

    return false

end

function CheckIfItemIsInstalledProsthesis(item)
    local item_full_type = item:getFullType()
    if string.find(item_full_type, "TOC.Prost_") then
        return true
    else
        return false
    end

end
