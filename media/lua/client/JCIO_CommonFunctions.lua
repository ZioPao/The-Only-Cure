------------------------------------------
------------- JUST CUT IT OFF ------------
------------------------------------------
------------ COMMON FUNCTIONS ------------

if JCIO_Common == nil then
    JCIO_Common = {}
end


JCIO_Common.partNames = {}

JCIO_Common.GeneratePartNames = function()

    local partNamesTable = {}
    for _, side in ipairs(JCIO.sideNames) do
        for _, limb in ipairs(JCIO.limbNames) do
            local tempPartName = side .. "_" .. limb
            table.insert(partNamesTable, tempPartName)
        end
    end

    JCIO_Common.partNames = partNamesTable

end

JCIO_Common.GetPartNames = function()
    if JCIO_Common.partNames[1] == nil then
        JCIO_Common.GeneratePartNames()
    end

    return JCIO_Common.partNames
end

JCIO_Common.GetSideFromPartName = function(partName)

    if string.find(partName, "Left") then
        return "Left"
    else
        return "Right"
    end

end

---------------------------------

JCIO_Common.GetAcceptableBodyPartTypes = function()

    -- TODO Add Foot_L and Foot_R
    return {
        BodyPartType.Hand_R, BodyPartType.ForeArm_R, BodyPartType.UpperArm_R,
        BodyPartType.Hand_L, BodyPartType.ForeArm_L, BodyPartType.UpperArm_L
    }

end

JCIO_Common.GetOtherBodyPartTypes = function()

    return {
        BodyPartType.Torso_Upper, BodyPartType.Torso_Lower, BodyPartType.Head,
        BodyPartType.Neck, BodyPartType.Groin, BodyPartType.UpperLeg_L,
        BodyPartType.UpperLeg_R, BodyPartType.LowerLeg_L,
        BodyPartType.LowerLeg_R, BodyPartType.Foot_L, BodyPartType.Foot_R,
        BodyPartType.Back
    }

end


function GetProsthesisList()
    -- TODO Not gonna work anymore
    return {"WoodenHook", "MetalHook", "MetalHand"}

end

function JCIO_Common.FindAmputatedClothingName(partName)
    return "JCIO.Amputation_" .. partName
end

function JCIO_Common.GetPartNameFromBodyPartType(bodyPartType)

    if bodyPartType == BodyPartType.Hand_R then
        return "Right_Hand"
    elseif bodyPartType == BodyPartType.ForeArm_R then
        return "Right_LowerArm"
    elseif bodyPartType == BodyPartType.UpperArm_R then
        return "Right_UpperArm"
    elseif bodyPartType == BodyPartType.Hand_L then
        return "Left_Hand"
    elseif bodyPartType == BodyPartType.ForeArm_L then
        return "Left_LowerArm"
    elseif bodyPartType == BodyPartType.UpperArm_L then
        return "Left_UpperArm"
    else
        return nil
    end

end


-- 1:1 map of part_name to BodyPartType
function JCIO_Common.GetBodyPartFromPartName(partName)
    if partName == "Right_Hand" then return BodyPartType.Hand_R end
    if partName == "Right_LowerArm" then return BodyPartType.ForeArm_R end
    if partName == "Right_UpperArm" then return BodyPartType.UpperArm_R end
    if partName == "Left_Hand" then return BodyPartType.Hand_L end
    if partName == "Left_LowerArm" then return BodyPartType.ForeArm_L end
    if partName == "Left_UpperArm" then return BodyPartType.UpperArm_L end

    -- New Legs stuff
    if partName == "Right_Foot" then return BodyPartType.Foot_R end
    if partName == "Left_Foot" then return BodyPartType.Foot_L end

end

-- Custom mapping to make more sense when cutting a limb
function JCIO_Common.GetAdjacentBodyPartFromPartName(partName)

    if partName == "Right_Hand" then return BodyPartType.ForeArm_R end
    if partName == "Right_LowerArm" then return BodyPartType.UpperArm_R end
    if partName == "Right_UpperArm" then return BodyPartType.Torso_Upper end
    if partName == "Left_Hand" then return BodyPartType.ForeArm_L end
    if partName == "Left_LowerArm" then return BodyPartType.UpperArm_L end
    if partName == "Left_UpperArm" then return BodyPartType.Torso_Upper end
    if partName == "Right_Foot" then return BodyPartType.LowerLeg_R end
    if partName == "Left_Foot" then return BodyPartType.LowerLeg_L end


end

function TocFindCorrectClothingProsthesis(itemName, partName)

    -- TODO This is not gonna work soon, so don't use this
    local correctName = "TOC.Prost_" .. partName .. "_" .. itemName
    return correctName

end

JCIO_Common.GetAmputationItemInInventory = function(player, partName)

    local playerInv = player:getInventory()
    local amputationItemName = TocFindAmputationOrProsthesisName(partName, player, "Amputation")
    local amputationItem = playerInv:FindAndReturn(amputationItemName)
    return amputationItem
end

function JCIO_Common.GetSawInInventory(surgeon)

    local playerInv = surgeon:getInventory()
    local item = playerInv:getItemFromType("Saw") or playerInv:getItemFromType("GardenSaw") or
        playerInv:getItemFromType("Chainsaw")
    return item
end



-----------------------------------
-- Online Handling checks


-----------------------------------------
-- MP HANDLING CHECKS
function JCIO_Common.CheckIfCanBeCut(partName, limbsData)

    if limbsData == nil then
        limbsData = getPlayer():getModData().JCIO.limbs
    end
    
    local check = (not limbsData[partName].isCut) and
        (not JCIO_Common.CheckIfProsthesisAlreadyInstalled(limbsData, partName))

    return check

end

function JCIO_Common.CheckIfCanBeOperated(partName, limbsData)

    if limbsData == nil then
        limbsData = getPlayer():getModData().JCIO.limbs
    end

    return limbsData[partName].isOperated == false and limbsData[partName].isAmputationShown

end

function JCIO_Common.CheckIfProsthesisCanBeEquipped(partName)
    local limbs_data = getPlayer():getModData().JCIO.limbs
    return limbs_data[partName].isCauterized or limbs_data[partName].isCicatrized
    -- check if prosthesis is in the surgeon inventory... we need to get it before
end

function JCIO_Common.CheckIfProsthesisCanBeUnequipped(partName)

    -- TODO we should get item here to be sure that we can do this action instead of relying on some later checks
    return true

end


-----------------------------------------
-- Various checks
-----------------------------------------

function JCIO_Common.CheckIfItemIsAmputatedLimb(item)
    local itemFullType = item:getFullType()
    local check

    if string.find(itemFullType, "JCIO.Amputation_") then
        check = true
    else
        check = false
    end

    return check

end

function CheckIfItemIsProsthesis(item)

    local itemFullType = item:getFullType()

    -- TODO This isn't gonna work anymore! Modular prosthetics needs to be handled in a different way
    local prosthesisList = GetProsthesisList()     

    for _, v in pairs(prosthesisList) do
        if v == itemFullType then
            return true
        end
    end

    return false

end

function JCIO_Common.CheckIfItemIsInstalledProsthesis(item)
    local itemFullType = item:getFullType()
    if string.find(itemFullType, "TOC.Prost_") then
        return true
    else
        return false
    end

end

function JCIO_Common.CheckIfProsthesisAlreadyInstalled(limbsData, partName)

    for _, side in pairs(JCIO.sideNames) do
        if string.find(partName, side) then
            return (limbsData[side .. "_Hand"].isProsthesisEquipped or limbsData[side .. "_LowerArm"].isProsthesisEquipped)
        end
    end

end


function JCIO_Common.GetCanBeHeldTable(limbs_data)

    local canBeHeld = {}

    for _, side in pairs(JCIO.sideNames) do
        canBeHeld[side] = true

        if limbs_data[side .. "_Hand"].isCut then
            if limbs_data[side .. "_LowerArm"].isCut then
                if not limbs_data[side .. "_LowerArm"].isProsthesisEquipped then
                    canBeHeld[side] = false
                end
            elseif not limbs_data[side .. "_Hand"].isProsthesisEquipped then
                canBeHeld[side] = false
            end
        end
    end

    return canBeHeld

end
-------------------------------