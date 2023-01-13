function GetBodyParts()
    local bodyparts = { "RightHand", "RightForearm", "RightArm", "LeftHand", "LeftForearm", "LeftArm"}
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

function FindTocDataPartNameFromBodyPartType(toc_data, bodyPartType)
    if bodyPartType == BodyPartType.Hand_R          then return toc_data.RightHand
    elseif bodyPartType == BodyPartType.ForeArm_R   then return toc_data.RightForearm
    elseif bodyPartType == BodyPartType.UpperArm_R  then return toc_data.RightArm
    elseif bodyPartType == BodyPartType.Hand_L      then return toc_data.LeftHand
    elseif bodyPartType  == BodyPartType.ForeArm_L  then return toc_data.LeftForearm
    elseif bodyPartType  == BodyPartType.UpperArm_L then return toc_data.LeftArm
    else return nil
    end
end

