-- CutLimb
-- TODO if TheONlyCure. triggers an errors
function CheckIfStillInfected(part_data)
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


-- TODO this triggers an error
function CureInfection(body_damage)
    body_damage:setInfected(false)
    body_damage:setInfectionMortalityDuration(-1)
    body_damage:setInfectionTime(-1)
    body_damage:setInfectionLevel(0)
    local body_part_types = body_damage:getBodyParts()
    for i=body_part_types:size()-1, 0, -1  do
        local bodyPart = body_part_types:get(i)
        bodyPart:SetInfected(false)
    end

    getPlayer().Say("I'm gonna be fine")

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

-- OperateLimb
function SetBodyPartsStatusAfterOperation(player, part_data, part_name, use_oven)
    --for _, v in ipairs(GetBodyParts()) do


    local body_part_type = player:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromBodyPart(part_name))
    FixSingleBodyPartType(body_part_type, use_oven)

    for _, v in ipairs(part_data[part_name].depends_on) do
        local depended_body_part_type = player:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromBodyPart(v))
        FixSingleBodyPartType(depended_body_part_type, use_oven)

    end
end

function FixSingleBodyPartType(body_part_type, use_oven)
    body_part_type:setDeepWounded(false)        --Basically like stitching
    body_part_type:setDeepWoundTime(0)
    if use_oven then 
        body_part_type:AddDamage(100)
        body_part_type:setAdditionalPain(100);
        body_part_type:setBleeding(false)
        body_part_type:setBleedingTime(0)      -- no bleeding since it's been cauterized
    else
        -- TODO Think a little better about this, do we want to trigger bleeding or not?
        body_part_type:setBleeding(false)
        
        --body_part_type:setBleedingTime(ZombRand(1, 5))   -- Reset the bleeding, maybe make it random
    end
end


-------------------------------------
-- Override helper

function CheckIfItemIsAmputatedLimb(item)
    

    local item_full_type = item:getFullType()

    local sides = {"Left", "Right"}
    local limbs_to_check = {"Hand", "LowerArm", "UpperArm"}

    local is_amputated_limb = false

    for _, part in ipairs(limbs_to_check) do
        for _, side in ipairs(sides) do

            local part_name = side .. "_" .. part

            local check_name = "TOC.Amputation_" .. part_name
            print(check_name)
            if item_full_type == check_name then
                is_amputated_limb = true
                break
            end

        end

    end


    return is_amputated_limb

end

function CheckIfItemIsProsthesis(item)
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
    local installable_prosthesis_list = GetInstallableProsthesisList()

    print("Checking for " .. item_full_type)

    for _, v in pairs(installable_prosthesis_list)do
        print(v)
        if (v == item_full_type) then
            return true
        end
    end

    return false
end