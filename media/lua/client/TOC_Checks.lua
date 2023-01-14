-- VARIOUS CHECKS --

if TheOnlyCure == nil then
    TheOnlyCure = {}
end

function TheOnlyCure.CheckIfCanBeCut(toc_data, part_name)

    return not toc_data[part_name].is_cut

end


function TheOnlyCure.CheckIfCanBeOperated(toc_data, part_name)

    return toc_data[part_name].is_operated == false and toc_data[part_name].is_amputation_shown

end