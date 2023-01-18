-- TODO Find a better name
function GetProsthesisLisHumanReadable()
    return {"WoodenHook", "MetalHook", "MetalHand"}

end





function GetProsthesisList()
    return {"TOC.WoodenHook", "TOC.MetalHook", "TOC.MetalHand"}

end

function GetInstallableProsthesisList()

    -- TODO Delete this and re do it


    -- To make it future proof since i'm gonna add stuff, let's cycle through already known prosthesis 
    local prosthesis_list = GetProsthesisList()

    local sides = {"right", "left"}
    local body_parts = {"Hand", "Forearm", "Arm"}
    local installed_prosthesis_list = {}

    for _, side in pairs(sides) do
        for _, prost in pairs(prosthesis_list) do
            for _, body_part in pairs(body_parts) do
                local installable_prost =  prost .. "_" .. side .. "_no" .. body_part
                print(installable_prost)
                table.insert(installed_prosthesis_list, installable_prost)
            end
        end
    end

    return installed_prosthesis_list

    

end





local function PartNameToBodyLocation(name)
    if name == "Right_Hand"      then return "ArmRight_Prot" end
    if name == "Right_LowerArm"   then return "ArmRight_Prot" end
    if name == "Right_UpperArm"       then return "ArmRight_Prot" end
    if name == "Left_Hand"       then return "ArmLeft_Prot" end
    if name == "Left_LowerArm"    then return "ArmLeft_Prot" end
    if name == "Left_UpperArm"        then return "ArmLeft_Prot" end
end


-- TODO find a better name, this doesnt check for amputation only for prosthetics
function FindTocItemWorn(part_name, patient)
    local worn_items = patient:getWornItems()

    for i=1,worn_items:size()-1 do -- Maybe wornItems:size()-1
        local item = worn_items:get(i):getItem();
        if item:getBodyLocation() == PartNameToBodyLocation(part_name) then
            return item;
        end
    end

end


function TocGetPartNameFromBodyPartType(body_part)

    if body_part      == BodyPartType.Hand_R      then return "Right_Hand"
    elseif body_part      == BodyPartType.ForeArm_R      then return "Right_LowerArm"
    elseif body_part   == BodyPartType.UpperArm_R  then return "Right_UpperArm"
    elseif body_part   == BodyPartType.Hand_L      then return "Left_Hand"
    elseif body_part   == BodyPartType.ForeArm_L   then return "Left_LowerArm"
    elseif body_part   == BodyPartType.UpperArm_L  then return "Left_UpperArm"
    else return nil
    end

end









-- TODO ew
function find_clothName_TOC(bodyPart)
    if bodyPart:getType()       == BodyPartType.Hand_R      then return "TOC.ArmRight_noHand"
    elseif bodyPart:getType()   == BodyPartType.ForeArm_R   then return "TOC.ArmRight_noForearm"
    elseif bodyPart:getType()   == BodyPartType.UpperArm_R  then return "TOC.ArmRight_noArm"
    elseif bodyPart:getType()   == BodyPartType.Hand_L      then return "TOC.ArmLeft_noHand"
    elseif bodyPart:getType()   == BodyPartType.ForeArm_L   then return "TOC.ArmLeft_noForearm"
    elseif bodyPart:getType()   == BodyPartType.UpperArm_L  then return "TOC.ArmLeft_noArm"
    else return nil
    end
end

function TocGetDisplayText(part_name)
    return getText("UI_ContextMenu_" .. part_name)

end


function TocGetBodyPartTypeFromBodyPart(part_name)
    if part_name == "Right_Hand"      then return BodyPartType.Hand_R end
    if part_name == "Right_LowerArm"   then return BodyPartType.ForeArm_R end
    if part_name == "Right_UpperArm"       then return BodyPartType.UpperArm_R end
    if part_name == "Left_Hand"       then return BodyPartType.Hand_L end
    if part_name == "Left_LowerArm"    then return BodyPartType.ForeArm_L end
    if part_name == "Left_UpperArm"        then return BodyPartType.UpperArm_L end
end


function TocFindAmputatedClothingFromPartName(part_name)
    return "TOC.Amputation_" .. part_name
end

-- TODO finish this
-- function TocFindIfClothingItemIsAmputatedLimb(item_name)



--     if item_name == "ArmRight_noHand"
--     local check =

-- end






function TocFindProsthesisFactorFromItem(item)

    local itemType = item:getType()

    -- TODO change this


    if     string.find(itemType, "WoodenHook") and string.find(itemType, "noHand")    then return 1.5
    elseif string.find(itemType, "WoodenHook") and string.find(itemType, "noForearm") then return 1.65
    elseif string.find(itemType, "MetalHook")  and string.find(itemType, "noHand")    then return 1.3
    elseif string.find(itemType, "MetalHook")  and string.find(itemType, "noForearm") then return 1.45
    elseif string.find(itemType, "MetalHand")  and string.find(itemType, "noHand")    then return 1.1
    elseif string.find(itemType, "MetalHand")  and string.find(itemType, "noForearm") then return 1.25
    end
end


function TocFindCorrectClothingProsthesis(item_name, part_name)

    local correct_name = "TOC.Prost_" .. part_name .. "_" .. item_name
    return correct_name

end