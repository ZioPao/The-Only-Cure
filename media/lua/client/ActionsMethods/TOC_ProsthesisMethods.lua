------------------------------------------
-------- THE ONLY CURE BUT BETTER --------
------------------------------------------
---------- PROSTHESIS FUNCTIONS ----------


---Equip a prosthesis transforming a normal item into a clothing item
---@param part_name string
---@param prosthesis_item any the prosthesis item
---@param prosthesis_base_name string
function TocEquipProsthesis(part_name, prosthesis_item, prosthesis_base_name)

    -- TODO probably will have to move this from the TOC menu to classic equip to have dynamic durability
    -- TODO We need to pass the original item so we can get its data!

    local player = getPlayer()

    local toc_data = player:getModData().TOC



    local item_mod_data = prosthesis_item:getModData()

    if item_mod_data.TOC == nil then
        GenerateEquippedProsthesis(prosthesis_item, "Test")     -- TODO Change it with the limb
        item_mod_data = prosthesis_item:getModData()        -- Updates it
    end


    --print("TOC: Test durability normal item " .. item_mod_data.TOC.durability)


    local prosthesis_name = TocFindCorrectClothingProsthesis(prosthesis_base_name, part_name)
    local added_prosthesis = player:getInventory():AddItem(prosthesis_name)


    -- Add parameters to added_prosthesis
    local added_prosthesis_mod_data = added_prosthesis:getModData()

    added_prosthesis_mod_data.TOC = {
        durability = item_mod_data.TOC.durability,
        speed = item_mod_data.TOC.speed,
    }


    --print("TOC: Test durability new item " .. added_prosthesis_mod_data.TOC.durability)



    if part_name ~= nil then

        if added_prosthesis ~= nil then
            toc_data.Limbs[part_name].is_prosthesis_equipped = true
            toc_data.Limbs[part_name].equipped_prosthesis = toc_data.Prosthesis[prosthesis_base_name][part_name]

            if player:isFemale() then
                added_prosthesis:getVisual():setTextureChoice(1)
            else
                added_prosthesis:getVisual():setTextureChoice(0)
            end
            player:setWornItem(added_prosthesis:getBodyLocation(), added_prosthesis)



        end
    end
end


---Unequip a prosthesis clothing item and returns it to the inventory as a normal item
---@param part_name string
function TocUnequipProsthesis(patient, part_name, equipped_prosthesis)


    -- TODO Pass the parameters generated from EquipProsthesis to the re-generated normal item

    local toc_data = patient:getModData().TOC
    toc_data.Limbs[part_name].is_prosthesis_equipped = false


    local equipped_prosthesis_full_type = equipped_prosthesis:getFullType()


    for _, prost_v in ipairs(GetProsthesisList()) do
        local prosthesis_name = string.match(equipped_prosthesis_full_type, prost_v)
        if prosthesis_name then

            -- Get mod data from equipped prosthesis so we can get its parameters
            local equipped_prosthesis_mod_data = equipped_prosthesis:getModData()


            local base_prosthesis_item = patient:getInventory():AddItem("TOC." .. prosthesis_name)
            local base_prosthesis_item_mod_data = base_prosthesis_item.getModData()
            base_prosthesis_item_mod_data.TOC = {
                durability = equipped_prosthesis_mod_data.TOC.durability,
                speed = equipped_prosthesis_mod_data.TOC.speed
            }

            patient:setWornItem(equipped_prosthesis:getBodyLocation(), nil)
            patient:getInventory():Remove(equipped_prosthesis)
            toc_data.Limbs[part_name].equipped_prosthesis = nil
        end
    end
end