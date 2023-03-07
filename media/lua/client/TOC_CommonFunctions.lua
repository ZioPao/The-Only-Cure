------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
------------ COMMON FUNCTIONS ------------

if TOC_Common == nil then
    TOC_Common = {}
end


TOC_Common.partNames = {}

TOC_Common.GeneratePartNames = function()

    local partNamesTable = {}
    for _, side in ipairs(TOC.sideNames) do
        for _, limb in ipairs(TOC.limbNames) do
            local tempPartName = side .. "_" .. limb
            table.insert(partNamesTable, tempPartName)
        end
    end

    TOC_Common.partNames = partNamesTable

end

TOC_Common.GetPartNames = function()
    if TOC_Common.partNames[1] == nil then
        TOC_Common.GeneratePartNames()
    end

    return TOC_Common.partNames
end

TOC_Common.GetSideFromPartName = function(partName)

    if string.find(partName, "Left") then
        return "Left"
    else
        return "Right"
    end

end

---------------------------------

TOC_Common.GetAcceptableBodyPartTypes = function()

    -- TODO Add Foot_L and Foot_R
    return {
        BodyPartType.Hand_R, BodyPartType.ForeArm_R, BodyPartType.UpperArm_R,
        BodyPartType.Hand_L, BodyPartType.ForeArm_L, BodyPartType.UpperArm_L
    }

end

TOC_Common.GetOtherBodyPartTypes = function()

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

TOC_Common.FindAmputatedClothingName = function(partName)
    return "TOC.Amputation_" .. partName
end

TOC_Common.GetPartNameFromBodyPartType = function(bodyPartType)

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


-- 1:1 map of partName to BodyPartType
TOC_Common.GetBodyPartFromPartName = function(partName)
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
TOC_Common.GetAdjacentBodyPartFromPartName = function(partName)

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

TOC_Common.GetAmputationItemInInventory = function(player, partName)

    local playerInv = player:getInventory()
    local amputationItemName = TOC_Common.FindAmputationOrProsthesisName(partName, player, "Amputation")
    local amputationItem = playerInv:FindAndReturn(amputationItemName)
    return amputationItem
end

TOC_Common.GetSawInInventory = function(surgeon)

    local playerInv = surgeon:getInventory()
    local item = playerInv:getItemFromType("Saw") or playerInv:getItemFromType("GardenSaw") or
        playerInv:getItemFromType("Chainsaw")
    return item
end



-----------------------------------
-- Online Handling checks


-----------------------------------------
-- MP HANDLING CHECKS
TOC_Common.CheckIfCanBeCut = function(partName, limbsData)

    if limbsData == nil then
        limbsData = getPlayer():getModData().TOC.limbs
    end
    
    local check = (not limbsData[partName].isCut) and
        (not TOC_Common.CheckIfProsthesisAlreadyInstalled(limbsData, partName))

    return check

end

TOC_Common.CheckIfCanBeOperated = function(partName, limbsData)

    if limbsData == nil then
        limbsData = getPlayer():getModData().TOC.limbs
    end

    return limbsData[partName].isOperated == false and limbsData[partName].isAmputationShown

end

TOC_Common.CheckIfProsthesisCanBeEquipped = function(partName)
    local limbs_data = getPlayer():getModData().TOC.limbs
    return limbs_data[partName].isCauterized or limbs_data[partName].isCicatrized
    -- check if prosthesis is in the surgeon inventory... we need to get it before
end

TOC_Common.CheckIfProsthesisCanBeUnequipped = function(partName)

    -- TODO we should get item here to be sure that we can do this action instead of relying on some later checks
    return true

end


-----------------------------------------
-- Various checks
-----------------------------------------

TOC_Common.CheckIfItemIsAmputatedLimb = function(item)
    local itemFullType = item:getFullType()
    local check

    if string.find(itemFullType, "TOC.Amputation_") then
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

TOC_Common.CheckIfItemIsInstalledProsthesis = function(item)
    local itemFullType = item:getFullType()
    if string.find(itemFullType, "TOC.Prost_") then
        return true
    else
        return false
    end

end

TOC_Common.CheckIfProsthesisAlreadyInstalled = function(limbsData, partName)

    for _, side in pairs(TOC.sideNames) do
        if string.find(partName, side) then
            return (limbsData[side .. "_Hand"].isProsthesisEquipped or limbsData[side .. "_LowerArm"].isProsthesisEquipped)
        end
    end

end

TOC_Common.GetCanBeHeldTable = function(limbs_data)

    local canBeHeld = {}

    for _, side in pairs(TOC.sideNames) do
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

TOC_Common.FindItemInWornItems = function(player, checkString)
    local wornItems = player:getWornItems()

    for i = 1, wornItems:size() - 1 do -- Maybe wornItems:size()-1
        local item = wornItems:get(i):getItem()
        local itemFullType = item:getFullType()
        if string.find(itemFullType, checkString) then
            return item
        end
    end

    return nil

end

TOC_Common.FindModItem = function(inventory)
    for _, partName in pairs(TOC_Common.GetPartNames()) do
        if inventory:contains("TOC.Amputation_" .. partName) then
            return true
        end
    end
    return false

end