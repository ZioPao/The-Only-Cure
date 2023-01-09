function CheckIfInfect(player, modData)
    local bd = player:getBodyDamage()
    local Keys = {BodyPartType.Torso_Upper, BodyPartType.Torso_Lower, BodyPartType.Head, BodyPartType.Neck, BodyPartType.Groin, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R, BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R, BodyPartType.Foot_L, BodyPartType.Foot_R, BodyPartType.Back}

    if     bd:getBodyPart(BodyPartType.Hand_R):bitten()     and not modData.TOC.RightHand.IsCut then    modData.TOC.RightHand.IsInfected = true;    player:transmitModData()
    elseif bd:getBodyPart(BodyPartType.ForeArm_R):bitten()  and not modData.TOC.RightForearm.IsCut then modData.TOC.RightForearm.IsInfected = true; player:transmitModData()
    elseif bd:getBodyPart(BodyPartType.UpperArm_R):bitten() and not modData.TOC.RightArm.IsCut then     modData.TOC.RightArm.IsInfected = true;     player:transmitModData()
    elseif bd:getBodyPart(BodyPartType.Hand_L):bitten()     and not modData.TOC.LeftHand.IsCut then     modData.TOC.LeftHand.IsInfected = true;     player:transmitModData()
    elseif bd:getBodyPart(BodyPartType.ForeArm_L):bitten()  and not modData.TOC.LeftForearm.IsCut then  modData.TOC.LeftForearm.IsInfected = true;  player:transmitModData()
    elseif bd:getBodyPart(BodyPartType.UpperArm_L):bitten() and not modData.TOC.LeftArm.IsCut then      modData.TOC.LeftArm.IsInfected = true;      player:transmitModData()
    else
        for index, value in ipairs(Keys) do
            if bd:getBodyPart(value):bitten() then modData.TOC.OtherBody_IsInfected = true; player:transmitModData() end
        end
    end
end