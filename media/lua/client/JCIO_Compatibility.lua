------------------------------------------
------------- JUST CUT IT OFF ------------
------------------------------------------
---------- COMPATIBILITY FUNCS -----------


if JCIOCompat == nil then
    JCIOCompat = {}
end

-- Gets the old status and turns it into the new.
JCIOCompat.CheckCompatibilityWithOlderVersions = function(modData)

    if modData.TOC ~= nil then
        print("JCIO: found old data from TOC")
        if modData.TOC.Limbs ~= nil then
            JCIOCompat.MapOldDataToNew(modData)
            modData.TOC = nil   -- Deletes the old mod data stuff
        else
            print("JCIO: something is wrong, couldn't find Limbs table in old TOC modData")
        end
    else
        print("JCIO: couldn't find old TOC data")

    end

end


JCIOCompat.MapOldDataToNew = function(modData)

    local oldNamesTable = { "RightHand", "RightForearm", "RightArm", "LeftHand", "LeftForearm", "LeftArm" }
    local newNamesTable = { "Right_Hand", "Right_LowerArm", "Right_UpperArm", "Left_Hand", "Left_LowerArm", "Left_UpperArm" }

    print("JCIO: Trying to backup old data from TOC")

    if modData == nil then
        return
    end

    print("JCIO: found old data from TOC")


    TocResetEverything()

    -- Another check just in case the user is using Mr Bounty og version. I really don't wanna map that out so let's just reset everything directly

    local compatEnum = nil



    -- Player has the og version of the mod
    if modData.TOC.Limbs.RightHand.IsCut ~= nil then
        print("JCIO: Found TOC Beta data")
        compatEnum = 1
    elseif modData.TOC.Limbs.Right_Hand.is_cut ~= nil then
        print("JCIO: Found TOCBB data")
        compatEnum = 2
    end


    if compatEnum == nil then
        print("JCIO: Couldn't find any compatible data that could be retrieved")
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
    modData.JCIO.limbs.isOtherBodypartInfected = modData.TOC.Limbs[isOtherBodypartInfectedOldKey]

    for i = 1, #newNamesTable do

        local oldName = oldNamesTable[i]
        local newName = newNamesTable[i]
        print("JCIO: isCut: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isCutOldKey]))
        print("JCIO: isOperated: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isOperatedOldKey]))
        print("JCIO: isCicatrized: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isCicatrizedOldKey]))
        print("JCIO: isAmputationShown: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][isAmputationShownOldKey]))
        print("JCIO: cicatrizationTime: " .. oldName .. " " .. tostring(modData.TOC.Limbs[oldName][cicatrizationTimeOldKey]))

        
        modData.JCIO.limbs[newName].isCut = modData.TOC.Limbs[oldName][isCutOldKey]

        if modData.JCIO.limbs[newName].isCut then
            print("JCIO: Found old cut limb, reapplying model")
            local cloth = getPlayer():getInventory():AddItem(TocFindAmputatedClothingFromPartName(newName))
            getPlayer():setWornItem(cloth:getBodyLocation(), cloth)
        end


        modData.JCIO.limbs[newName].isInfected = modData.TOC.Limbs[oldName][isInfectedOldKey]
        modData.JCIO.limbs[newName].isOperated = modData.TOC.Limbs[oldName][isOperatedOldKey]
        modData.JCIO.limbs[newName].isCicatrized = modData.TOC.Limbs[oldName][isCicatrizedOldKey]
        modData.JCIO.limbs[newName].isCauterized = modData.TOC.Limbs[oldName][isCauterizedOldKey]
        modData.JCIO.limbs[newName].isAmputationShown = modData.TOC.Limbs[oldName][isAmputationShownOldKey]
        modData.JCIO.limbs[newName].cicatrizationTime = modData.TOC.Limbs[oldName][cicatrizationTimeOldKey]
    end



end
