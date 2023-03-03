------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
---------- COMPATIBILITY FUNCS -----------


if TOC_Compat == nil then
    TOC_Compat = {}
end

-- Gets the old status and turns it into the new.
TOC_Compat.CheckCompatibilityWithOlderVersions = function(modData)

    if modData.TOC ~= nil then
        print("TOC: found old data from TOC")
        if modData.TOC.Limbs ~= nil then
            TOC_Compat.MapOldDataToNew(modData)
            modData.TOC = nil   -- Deletes the old mod data stuff
        else
            print("TOC: something is wrong, couldn't find Limbs table in old TOC modData")
        end
    else
        print("TOC: couldn't find old TOC data")

    end

end


TOC_Compat.MapOldDataToNew = function(modData)

    local oldNamesTable = { "RightHand", "RightForearm", "RightArm", "LeftHand", "LeftForearm", "LeftArm" }
    local newNamesTable = { "Right_Hand", "Right_LowerArm", "Right_UpperArm", "Left_Hand", "Left_LowerArm", "Left_UpperArm" }

    print("TOC: Trying to backup old data from TOC")

    if modData == nil then
        return
    end

    print("TOC: found old data from TOC")


    TOC_Cheat.ResetEverything()

    -- Another check just in case the user is using Mr Bounty og version. I really don't wanna map that out so let's just reset everything directly

    local compatEnum = nil



    -- Player has the og version of the mod
    if modData.TOC.Limbs.RightHand.IsCut ~= nil then
        print("TOC: Found TOC Beta data")
        compatEnum = 1
    elseif modData.TOC.Limbs.Right_Hand.is_cut ~= nil then
        print("TOC: Found TOCBB data")
        compatEnum = 2
    end


    if compatEnum == nil then
        print("TOC: Couldn't find any compatible data that could be retrieved")
        return
    end


    -- Key setup
    local isCutOldKey = nil
    local isInfectedOldKey = nil
    local isOperatedOldKey = nil
    local isCicatrizedOldKey = nil
    local isCauterizedOldKey = nil
    local isAmputationShownOldKey = nil
    local cicatrizationTimeOldKey = nil
    local isOtherBodypartInfectedOldKey = nil

    if compatEnum == 1 then
        isCutOldKey = "IsCut"
        isInfectedOldKey = "IsInfected"
        isOperatedOldKey = "IsOperated"
        isCicatrizedOldKey = "IsCicatrized"
        isCauterizedOldKey = "ISBurn"
        isAmputationShownOldKey = "ToDisplay"
        cicatrizationTimeOldKey = "CicaTimeLeft"
        isOtherBodypartInfectedOldKey = "OtherBody_IsInfected"
    elseif compatEnum == 2 then
        isCutOldKey = "is_cut"
        isInfectedOldKey = "is_infected"
        isOperatedOldKey = "is_operated"
        isCicatrizedOldKey = "is_cicatrized"
        isCauterizedOldKey = "is_cauterized"
        isAmputationShownOldKey = "is_amputation_shown"
        cicatrizationTimeOldKey = "cicatrization_time"
        isOtherBodypartInfectedOldKey = "is_other_bodypart_infected"
        
    elseif compatEnum == 3 then
        isCutOldKey = "isCut"
        isInfectedOldKey = "isInfected"
        isOperatedOldKey = "isOperated"
        isCicatrizedOldKey = "isCicatrized"
        isCauterizedOldKey = "isCauterized"
        isAmputationShownOldKey = "isAmputationShwon"
        cicatrizationTimeOldKey = "cicatrizationTime"
        isOtherBodypartInfectedOldKey = "isOtherBodypartInfected"
    end


    -- Starts reapplying stuff
    modData.TOC.limbs.isOtherBodypartInfected = modData.TOC.Limbs[isOtherBodypartInfectedOldKey]

    for i = 1, #newNamesTable do

        local oldName = oldNamesTable[i]
        local newName = newNamesTable[i]
        print("TOC: isCut: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isCutOldKey]))
        print("TOC: isOperated: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isOperatedOldKey]))
        print("TOC: isCicatrized: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isCicatrizedOldKey]))
        print("TOC: isAmputationShown: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isAmputationShownOldKey]))
        print("TOC: cicatrizationTime: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][cicatrizationTimeOldKey]))

        
        modData.TOC.limbs[newName].isCut = modData.TOC.Limbs[oldName][isCutOldKey]

        if modData.TOC.limbs[newName].isCut then
            print("TOC: Found old cut limb, reapplying model")
            local cloth = getPlayer():getInventory():AddItem(TOC_Common.FindAmputatedClothingName(newName))
            getPlayer():setWornItem(cloth:getBodyLocation(), cloth)
        end


        modData.TOC.limbs[newName].isInfected = modData.TOC.Limbs[oldName][isInfectedOldKey]
        modData.TOC.limbs[newName].isOperated = modData.TOC.Limbs[oldName][isOperatedOldKey]
        modData.TOC.limbs[newName].isCicatrized = modData.TOC.Limbs[oldName][isCicatrizedOldKey]
        modData.TOC.limbs[newName].isCauterized = modData.TOC.Limbs[oldName][isCauterizedOldKey]
        modData.TOC.limbs[newName].isAmputationShown = modData.TOC.Limbs[oldName][isAmputationShownOldKey]
        modData.TOC.limbs[newName].cicatrizationTime = modData.TOC.Limbs[oldName][cicatrizationTimeOldKey]
    end



end
