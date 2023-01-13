-- CutLimb
function TheOnlyCure.CheckIfStillInfected(toc_data)
    if toc_data == nil then
        return
    end
    -- Check ALL body part types to check if the player is still gonna die
    local check = false


    for _, v in ipairs(GetBodyParts()) do
        if toc_data[v].is_infected then
            check = true
        end
    end

    if toc_data.is_other_bodypart_infected then
        check = true
    end

    return check
end


function TheOnlyCure.CureInfection(body_damage)
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


-- OperateLimb
function TheOnlyCure.SetBodyPartsStatusAfterOperation(player, toc_data, part_name, use_oven)
    --for _, v in ipairs(GetBodyParts()) do


    local body_part_type = player:getBodyDamage():getBodyPart(TheOnlyCure.GetBodyPartTypeFromBodyPart(part_name))
    FixSingleBodyPartType(body_part_type, use_oven)

    for _, v in ipairs(toc_data[part_name].depends_on) do
        local depended_body_part_type = player:getBodyDamage():getBodyPart(TheOnlyCure.GetBodyPartTypeFromBodyPart(v))
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
        -- TODO Think a little better about this
        body_part_type:setBleeding(false)
        
        --body_part_type:setBleedingTime(ZombRand(1, 5))   -- Reset the bleeding, maybe make it random
    end
end
