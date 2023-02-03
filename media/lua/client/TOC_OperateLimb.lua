------------------------------------------
-------- THE ONLY CURE BUT BETTER --------
------------------------------------------
--------- OPERATE LIMB FUNCTIONS ---------

local function FixSingleBodyPartType(body_part_type, use_oven)
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

local function SetBodyPartsStatusAfterOperation(player, limbs_data, part_name, use_oven)
    --for _, v in ipairs(GetBodyParts()) do


    local body_part_type = player:getBodyDamage():getBodyPart(TocGetAdiacentBodyPartFromPartName(part_name))
    FixSingleBodyPartType(body_part_type, use_oven)

    for _, v in ipairs(limbs_data[part_name].depends_on) do
        local depended_body_part_type = player:getBodyDamage():getBodyPart(TocGetAdiacentBodyPartFromPartName(v))
        FixSingleBodyPartType(depended_body_part_type, use_oven)

    end
end

----------------------------------------------------------------------------------


---Main function to operate a limb after amputation
---@param part_name any
---@param surgeon_factor any
---@param use_oven boolean wheter using oven instead of a kit or not
function TocOperateLimb(part_name, surgeon_factor, use_oven)

    local player = getPlayer()
    local limbs_data = player:getModData().TOC.Limbs

    if use_oven then
        local stats = player:getStats()
        stats:setEndurance(100)
        stats:setStress(100)
    end

    if limbs_data[part_name].is_operated == false and limbs_data[part_name].is_cut == true then
        limbs_data[part_name].is_operated = true
        limbs_data[part_name].cicatrization_time = limbs_data[part_name].cicatrization_time - (surgeon_factor * 200)
        if use_oven then limbs_data[part_name].is_cauterized = true end
        for _, depended_v in pairs(limbs_data[part_name].depends_on) do
            limbs_data[depended_v].is_operated = true
            limbs_data[depended_v].cicatrization_time = limbs_data[depended_v].cicatrization_time -
                (surgeon_factor * 200)
            if use_oven then limbs_data[depended_v].is_cauterized = true end -- TODO does this make sense?

        end

    end

    SetBodyPartsStatusAfterOperation(player, limbs_data, part_name, use_oven)
end
