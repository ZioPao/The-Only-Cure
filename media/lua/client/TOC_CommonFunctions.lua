function GetBodyParts()
    local bodyparts = { "Right_Hand", "Right_LowerArm", "Right_UpperArm",
                         "Left_Hand", "Left_LowerArm", "Left_UpperArm"}
    return bodyparts
end

function GetLimbsBodyPartTypes()

    return {BodyPartType.Hand_R, BodyPartType.ForeArm_R, BodyPartType.UpperArm_R,
            BodyPartType.Hand_L, BodyPartType.ForeArm_L, BodyPartType.UpperArm_L}

end

function GetOtherBodyPartTypes()

    return {BodyPartType.Torso_Upper, BodyPartType.Torso_Lower, BodyPartType.Head, BodyPartType.Neck, 
            BodyPartType.Groin, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R, BodyPartType.LowerLeg_L, 
            BodyPartType.LowerLeg_R, BodyPartType.Foot_L, BodyPartType.Foot_R, BodyPartType.Back}

end

function GetAcceptingProsthesisBodyPartTypes()


    return {BodyPartType.Hand_R, BodyPartType.ForeArm_R,
            BodyPartType.Hand_L, BodyPartType.ForeArm_L}


end

-- TODO This is just convoluted. Do not use this
function FindTocDataPartNameFromBodyPartType(toc_limbs_data, bodyPartType)
    if bodyPartType == BodyPartType.Hand_R          then return toc_limbs_data.Right_Hand
    elseif bodyPartType == BodyPartType.ForeArm_R   then return toc_limbs_data.Right_LowerArm
    elseif bodyPartType == BodyPartType.UpperArm_R  then return toc_limbs_data.Right_UpperArm
    elseif bodyPartType == BodyPartType.Hand_L      then return toc_limbs_data.Left_Hand
    elseif bodyPartType  == BodyPartType.ForeArm_L  then return toc_limbs_data.Left_LowerArm
    elseif bodyPartType  == BodyPartType.UpperArm_L then return toc_limbs_data.Left_UpperArm
    else return nil
    end
end


function FindTocBodyPartNameFromBodyPartType(bodyPartType)
    if bodyPartType == BodyPartType.Hand_R          then return "Right_Hand"
    elseif bodyPartType == BodyPartType.ForeArm_R   then return "Right_LowerArm"
    elseif bodyPartType == BodyPartType.UpperArm_R  then return "Right_UpperArm"
    elseif bodyPartType == BodyPartType.Hand_L      then return "Left_Hand"
    elseif bodyPartType  == BodyPartType.ForeArm_L  then return "Left_LowerArm"
    elseif bodyPartType  == BodyPartType.UpperArm_L then return "Left_UpperArm"
    else return nil
    end
end

