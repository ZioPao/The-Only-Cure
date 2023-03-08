------------------------------------------
-------- THE ONLY CURE BUT BETTER --------
------------------------------------------
---------- PROSTHESIS FUNCTIONS ----------


---Equip a prosthesis transforming a normal item into a clothing item
---@param part_name string
---@param prosthesis_base_name string
function TocEquipProsthesis(part_name, prosthesis_base_name)
    local player = getPlayer()

    local toc_data = player:getModData().TOC

    local prosthesis_name = TocFindCorrectClothingProsthesis(prosthesis_base_name, part_name)
    local added_prosthesis = player:getInventory():AddItem(prosthesis_name)

    if part_name ~= nil then

        if added_prosthesis ~= nil then
            toc_data.Limbs[part_name].is_prosthesis_equipped = true
            toc_data.Limbs[part_name].equipped_prosthesis = toc_data.Prosthesis[prosthesis_base_name][part_name]
            if player:isFemale() then
                added_prosthesis:getVisual():setTextureChoice(1)    -- What if there is none?
            else
                added_prosthesis:getVisual():setTextureChoice(0)
            end
            player:setWornItem(added_prosthesis:getBodyLocation(), added_prosthesis)


            




        end
    end
end


---Unequip a prosthesis clothing item and returns it to the inventory as a normal item
---@param part_name string
function TheOnlyCure.UnequipProsthesis(patient, part_name, equipped_prosthesis)


    local toc_data = patient:getModData().TOC
    toc_data.Limbs[part_name].is_prosthesis_equipped = false


    local equipped_prosthesis_full_type = equipped_prosthesis:getFullType()


    for _, prost_v in ipairs(GetProsthesisList()) do
        local prosthesis_name = string.match(equipped_prosthesis_full_type, prost_v)
        if prosthesis_name then
            patient:getInventory():AddItem("TOC." .. prosthesis_name)
            patient:setWornItem(equipped_prosthesis:getBodyLocation(), nil)
            patient:getInventory():Remove(equipped_prosthesis)
            toc_data.Limbs[part_name].equipped_prosthesis = nil
        end

    end


end

