-- VARIOUS CHECKS --

if TheOnlyCure == nil then
    TheOnlyCure = {}
end

-----------------------------------------
-- MP HANDLING CHECKS
function CheckIfCanBeCut(part_name)

    local toc_data = getPlayer():getModData().TOC
    local check = (not toc_data.Limbs[part_name].is_cut) and
        (not CheckIfProsthesisAlreadyInstalled(toc_data.Limbs, part_name))

    return check

end

function CheckIfCanBeOperated(part_name)

    local part_data = getPlayer():getModData().TOC.Limbs

    return part_data[part_name].is_operated == false and part_data[part_name].is_amputation_shown

end

function CheckIfProsthesisCanBeEquipped(part_name, item)
    local part_data = getPlayer():getModData().TOC.Limbs


    if item ~= nil then
        if part_data[part_name].is_operated then
            return true
        end
    else

        return false
    end

    -- check if prosthesis is in the surgeon inventory... we need to get it before



end

-------------------------------




function CheckIfProsthesisAlreadyInstalled(part_data, part_name)

    local r = "Right"
    local l = "Left"


    if string.find(part_name, r) then
        return (part_data[r .. "_Hand"].is_prosthesis_equipped or part_data[r .. "_LowerArm"].is_prosthesis_equipped)

    elseif string.find(part_name, l) then
        return (part_data[l .. "_Hand"].is_prosthesis_equipped or part_data[l .. "_LowerArm"].is_prosthesis_equipped)
    end




end
