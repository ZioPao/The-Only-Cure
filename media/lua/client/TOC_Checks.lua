-- VARIOUS CHECKS --

if TheOnlyCure == nil then
    TheOnlyCure = {}
end

function CheckIfCanBeCut(part_name)

    return not getPlayer():getModData().TOC[part_name].is_cut

end


function CheckIfCanBeOperated(part_name)

    local toc_data = getPlayer():getModData().TOC

    return toc_data[part_name].is_operated == false and toc_data[part_name].is_amputation_shown

end

function CheckIfProsthesisCanBeEquipped(part_name)

end