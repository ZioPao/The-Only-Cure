-- 6 skin tones or 5?

function TocSetCorrectTextureForAmputation(item, player)
    local human_visual = player:getHumanVisual()
    local texture_string = human_visual:getSkinTexture()
    local matched_index = string.match(texture_string, "%d$")
    print("TOC: Setting texture " .. matched_index)
    item:getVisual():setTextureChoice(tonumber(matched_index - 1)) -- TODO why is it correct with -1?
end

function TocSetBloodOnAmputation(player, body_part)


    local body_part_type = body_part:getType()
    local blood_body_part_type
    if body_part_type == BodyPartType.Hand_R then
        blood_body_part_type = BloodBodyPartType.ForeArm_R
    elseif body_part_type == BodyPartType.Hand_L then
        blood_body_part_type = BloodBodyPartType.ForeArm_L
    elseif body_part_type == BodyPartType.Forearm_L or body_part_type == BodyPartType.UpperArm_L then
        blood_body_part_type = BloodBodyPartType.UpperArm_L
    elseif body_part_type == BodyPartType.Forearm_R or body_part_type == BodyPartType.UpperArm_R then
        blood_body_part_type = BloodBodyPartType.UpperArm_R
    end


    print("TOC: Adding blood based on " .. tostring(body_part_type))

    player:addBlood(blood_body_part_type, false, true, false)
    player:addBlood(BloodBodyPartType.Torso_Lower, false, true, false)

end