function GetBodyParts()
    local bodyparts = {
        "Right_Hand", "Right_LowerArm", "Right_UpperArm", "Left_Hand",
        "Left_LowerArm", "Left_UpperArm"
    }
    return bodyparts
end

function GetProsthesisList()
    return {"WoodenHook", "MetalHook", "MetalHand"}

end

function TocFindAmputatedClothingFromPartName(part_name)
    return "TOC.Amputation_" .. part_name
end

function GetLimbsBodyPartTypes()

    return {
        BodyPartType.Hand_R, BodyPartType.ForeArm_R, BodyPartType.UpperArm_R,
        BodyPartType.Hand_L, BodyPartType.ForeArm_L, BodyPartType.UpperArm_L
    }

end

function GetOtherBodyPartTypes()

    return {
        BodyPartType.Torso_Upper, BodyPartType.Torso_Lower, BodyPartType.Head,
        BodyPartType.Neck, BodyPartType.Groin, BodyPartType.UpperLeg_L,
        BodyPartType.UpperLeg_R, BodyPartType.LowerLeg_L,
        BodyPartType.LowerLeg_R, BodyPartType.Foot_L, BodyPartType.Foot_R,
        BodyPartType.Back
    }

end

function GetAcceptingProsthesisBodyPartTypes()

    return {
        BodyPartType.Hand_R, BodyPartType.ForeArm_R, BodyPartType.Hand_L,
        BodyPartType.ForeArm_L
    }

end

function TocGetPartNameFromBodyPartType(body_part)

    if body_part == BodyPartType.Hand_R then
        return "Right_Hand"
    elseif body_part == BodyPartType.ForeArm_R then
        return "Right_LowerArm"
    elseif body_part == BodyPartType.UpperArm_R then
        return "Right_UpperArm"
    elseif body_part == BodyPartType.Hand_L then
        return "Left_Hand"
    elseif body_part == BodyPartType.ForeArm_L then
        return "Left_LowerArm"
    elseif body_part == BodyPartType.UpperArm_L then
        return "Left_UpperArm"
    else
        return nil
    end

end


-- 1:1 map of part_name to BodyPartType
function TocGetBodyPartFromPartName(part_name)
    if part_name == "Right_Hand" then return BodyPartType.Hand_R end
    if part_name == "Right_LowerArm" then return BodyPartType.ForeArm_R end
    if part_name == "Right_UpperArm" then return BodyPartType.UpperArm_R end
    if part_name == "Left_Hand" then return BodyPartType.Hand_L end
    if part_name == "Left_LowerArm" then return BodyPartType.ForeArm_L end
    if part_name == "Left_UpperArm" then return BodyPartType.UpperArm_L end
end

-- Custom mapping to make more sense when cutting a limb
function TocGetAdiacentBodyPartFromPartName(part_name)

    if part_name == "Right_Hand" then return BodyPartType.ForeArm_R end
    if part_name == "Right_LowerArm" then return BodyPartType.UpperArm_R end
    if part_name == "Right_UpperArm" then return BodyPartType.Torso_Upper end
    if part_name == "Left_Hand" then return BodyPartType.ForeArm_L end
    if part_name == "Left_LowerArm" then return BodyPartType.UpperArm_L end
    if part_name == "Left_UpperArm" then return BodyPartType.Torso_Upper end
end

function TocFindCorrectClothingProsthesis(item_name, part_name)

    local correct_name = "TOC.Prost_" .. part_name .. "_" .. item_name
    return correct_name

end

function TocGetAmputationItemInInventory(player, part_name)

    local player_inventory = player:getInventory()
    local amputation_item_name = TocFindAmputationOrProsthesisName(part_name, player, "Amputation")
    local amputation_item = player_inventory:FindAndReturn(amputation_item_name)
    return amputation_item
end

function TocGetSawInInventory(surgeon)

    local player_inv = surgeon:getInventory()
    local item = player_inv:getItemFromType("Saw") or player_inv:getItemFromType("GardenSaw") or
        player_inv:getItemFromType("Chainsaw")
    return item
end


function TocCheckIfAnyAmputationItemInInventory(inv)
    for _, partName in pairs(GetBodyParts()) do
        if inv:contains("TOC.Amputation_" .. partName) then
            return true
        end
    end
    return false
end
