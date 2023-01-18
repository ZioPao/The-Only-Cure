-- VARIOUS CHECKS --

if TheOnlyCure == nil then
    TheOnlyCure = {}
end

function CheckIfCanBeCut(part_name)
    -- This is just for MP handling... Not enough to check everything
    return not getPlayer():getModData().TOC[part_name].is_cut

end

function CheckIfProsthesisAlreadyInstalled(part_data, part_name)

    local r = "Right"
    local l = "Left"


    if string.find(part_name, r) then
        return (part_data[r .. "_Hand"].is_prosthesis_equipped or part_data[r .. "_LowerArm"].is_prosthesis_equipped)
        
    elseif string.find(part_name, l) then
        return (part_data[l .. "_Hand"].is_prosthesis_equipped or part_data[l .. "_LowerArm"].is_prosthesis_equipped)
    end


            

end

function CheckIfCanBeOperated(part_name)

    local part_data = getPlayer():getModData().TOC.Limbs

    return part_data[part_name].is_operated == false and part_data[part_name].is_amputation_shown

end

function CheckIfProsthesisCanBeEquipped(part_name)

end