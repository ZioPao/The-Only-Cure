-- VARIOUS CHECKS --

if TheOnlyCure == nil then
    TheOnlyCure = {}
end


local pairs = pairs


-----------------------------------------
-- MP HANDLING CHECKS
function CheckIfCanBeCut(part_name, limbs_data)

    if limbs_data == nil then
        limbs_data = getPlayer():getModData().TOC.Limbs
  
    end
    local check = (not limbs_data[part_name].is_cut) and
        (not CheckIfProsthesisAlreadyInstalled(limbs_data, part_name))

    return check

end

function CheckIfCanBeOperated(part_name, limbs_data)

    if limbs_data == nil then
        limbs_data = getPlayer():getModData().TOC.Limbs
    end


    return limbs_data[part_name].is_operated == false and limbs_data[part_name].is_amputation_shown

end

function CheckIfProsthesisCanBeEquipped(part_name)
    local limbs_data = getPlayer():getModData().TOC.Limbs
    return limbs_data[part_name].is_cauterized or limbs_data[part_name].is_cicatrized
    -- check if prosthesis is in the surgeon inventory... we need to get it before
end

function CheckIfProsthesisCanBeUnequipped(part_name)

    -- TODO we should get item here to be sure that we can do this action instead of relying on some later checks
    return true

end
-----------------------------------------

function CheckIfItemIsAmputatedLimb(item)
    local item_full_type = item:getFullType()
    local check

    if string.find(item_full_type, "TOC.Amputation_") then
        check = true
    else
        check = false
    end

    return check

end

function CheckIfItemIsProsthesis(item)

    local item_full_type = item:getFullType()
    local prosthesis_list = GetProsthesisList()     -- TODO this isn't gonna work after the modular prost rewrite

    for _, v in pairs(prosthesis_list) do
        if v == item_full_type then
            return true
        end
    end

    return false

end

function CheckIfItemIsInstalledProsthesis(item)
    local item_full_type = item:getFullType()
    if string.find(item_full_type, "TOC.Prost_") then
        return true
    else
        return false
    end

end



function CheckIfProsthesisAlreadyInstalled(limbs_data, part_name)

    for _, side in pairs(TOC.side_names) do
        if string.find(part_name, side) then
            return (limbs_data[side .. "_Hand"].is_prosthesis_equipped or limbs_data[side .. "_LowerArm"].is_prosthesis_equipped)
        end
    end

end
