function TocCheckCompatibilityWithOlderVersions(mod_data)
    -- Gets the old status and turns it into the new.

    if mod_data.TOC.Limbs == nil then
        print("TOC: Limbs is nil, resetting mod_data")
        TocMapOldDataToNew(mod_data)
    else
        print("TOC: Found compatible data")
    end

end



function TocMapOldDataToNew(mod_data)

    local map_names = {
        Right_Hand = "RightHand",
        Right_LowerArm = "RightForearm",
        Right_UpperArm = "RightArm",

        Left_Hand = "LeftHand",
        Left_LowerArm = "LeftForearm",
        Left_UpperArm = "LeftArm"
    }

    local old_names_table = {"RightHand", "RightForearm", "RightArm", "LeftHand", "LeftForearm", "LeftArm"}
    local new_names_table = {"Right_Hand", "Right_LowerArm", "Right_UpperArm", "Left_Hand", "Left_LowerArm", "Left_UpperArm"}
    print("TOC: Trying to backup old data")
    local backup_old_data = mod_data.TOC



    -- for k, v in pairs(map_names) do
    --     print("TOC: Looping old names...")
    --     print(k)
    --     print(v)
    --     print(backup_old_data[v].is_cut)
    --     print("__________________")
    -- end



    -- for _, v in ipairs(map_names) do
    --     print("TOC: Looping old names...")
    --     print(k)
    --     print(v)
    --     print(backup_old_data[v].is_cut)
    --     print("__________________")
    -- end




    TocResetEverything()
        -- For some reasons pairs does not work here... 
    -- TODO ask why
    for i=1, #new_names_table do
        print("TOC: Looping " .. i)
        print(backup_old_data[old_names_table[i]].is_cut)

        local old_name = old_names_table[i]
        local new_name = new_names_table[i]

        mod_data.TOC.Limbs[new_name].is_cut = backup_old_data[old_name].is_cut

        if mod_data.TOC.Limbs[new_name].is_cut then
            local cloth = getPlayer():getInventory():AddItem(TocFindAmputatedClothingFromPartName(new_name))
            getPlayer():setWornItem(cloth:getBodyLocation(), cloth)
        end


        mod_data.TOC.Limbs[new_name].is_infected = backup_old_data[old_name].is_infected
        mod_data.TOC.Limbs[new_name].is_operated = backup_old_data[old_name].is_operated
        mod_data.TOC.Limbs[new_name].is_cicatrized = backup_old_data[old_name].is_cicatrized
        mod_data.TOC.Limbs[new_name].is_cauterized = backup_old_data[old_name].is_cauterized
        mod_data.TOC.Limbs[new_name].is_amputation_shown = backup_old_data[old_name].is_amputation_shown

        mod_data.TOC.Limbs[new_name].cicatrization_time =  backup_old_data[old_name].cicatrization_time
        

    end
    getPlayer():transmitModData()


end