------------------------------------------
------------- JUST CUT IT OUT ------------
------------------------------------------
------------ VISUALS FUNCTIONS -----------


if JCIO_Visuals == nil then
    JCIO_Visuals = {}
end


JCIO_Visuals.SetTextureForAmputation = function(item, player, cicatrized)
    local humanVisual = player:getHumanVisual()
    local textureString = humanVisual:getSkinTexture()

    local isHairy = string.find(textureString, "a$")
    -- Hairy bodies
    if isHairy then
        textureString = textureString:sub(1, -2)      -- Removes b at the end to make it compatible
    end


    local matchedIndex = string.match(textureString, "%d$")

    if isHairy then
        matchedIndex = matchedIndex + 5
    end


    if cicatrized then
        if isHairy then
            matchedIndex = matchedIndex + 5           -- to use the cicatrized texture on hairy bodies
        else
            matchedIndex = matchedIndex + 10          -- cicatrized texture only, no hairs
        end
    end

    --print("JCIO: Setting texture " .. matched_index)
    item:getVisual():setTextureChoice(tonumber(matchedIndex - 1)) -- it counts from 0, so we have to subtract 1

end

JCIO_Visuals.SetBloodOnAmputation = function(player, bodyPart)

    local bodyPartType = bodyPart:getType()
    local bloodBodyPartType

    if bodyPartType == BodyPartType.Hand_R then
        bloodBodyPartType = BloodBodyPartType.ForeArm_R
    elseif bodyPartType == BodyPartType.Hand_L then
        bloodBodyPartType = BloodBodyPartType.ForeArm_L
    elseif bodyPartType == BodyPartType.Forearm_L or bodyPartType == BodyPartType.UpperArm_L then
        bloodBodyPartType = BloodBodyPartType.UpperArm_L
    elseif bodyPartType == BodyPartType.Forearm_R or bodyPartType == BodyPartType.UpperArm_R then
        bloodBodyPartType = BloodBodyPartType.UpperArm_R
    end

    player:addBlood(bloodBodyPartType, false, true, false)
    player:addBlood(BloodBodyPartType.Torso_Lower, false, true, false)
end