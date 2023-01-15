-- VARIOUS CHECKS --

if TheOnlyCure == nil then
    TheOnlyCure = {}
end

function CheckIfCanBeCut(part_name)
    -- This is just for MP handling... Not enough to check everything
    return not getPlayer():getModData().TOC[part_name].is_cut

end

function CheckIfProsthesisAlreadyInstalled(toc_data, part_name)

    local r = "Right"
    local l = "Left"

    return (string.find(part_name, r) and not (toc_data[r .. "Hand"].is_prosthesis_equipped or toc_data[r .. "Forearm"].is_prosthesis_equipped)) or
            (string.find(part_name, l) and not (toc_data[l .. "Hand"].is_prosthesis_equipped or toc_data[l .. "Forearm"].is_prosthesis_equipped))

end

function CheckIfCanBeOperated(part_name)

    local toc_data = getPlayer():getModData().TOC

    return toc_data[part_name].is_operated == false and toc_data[part_name].is_amputation_shown

end

function CheckIfProsthesisCanBeEquipped(part_name)

end