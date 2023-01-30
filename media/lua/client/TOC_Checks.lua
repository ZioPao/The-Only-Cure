-- VARIOUS CHECKS --

if TheOnlyCure == nil then
    TheOnlyCure = {}
end

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
-------------------------------




function CheckIfProsthesisAlreadyInstalled(limbs_data, part_name)

    for _, side in ipairs(TOC_sides) do
        if string.find(part_name, side) then
            return (limbs_data[side .. "_Hand"].is_prosthesis_equipped or limbs_data[side .. "_LowerArm"].is_prosthesis_equipped)
        end
    end

end
