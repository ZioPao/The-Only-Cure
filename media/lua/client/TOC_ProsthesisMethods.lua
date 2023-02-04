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


---------------------------------------------------------------------------------------------
-- TEST MODULAR SYSTEM
---------------------------------------------------------------------------------------------

function TocModular()
    

    -- Should affect comfort, so mobility (equal speed of actions)
    local prost_straps = {
        "leather_strap",        -
        "sheet_strap"
    }

    -- A better base has a better resistance. During use it's gonna break sooner or later so a leather base is the best inbetween
    local prost_base_forearm = {
        "leather_base_forearm",     -- Good resistance and speed
        "wood_base_forearm",        -- Shitty resistance and low speed
        "metal_base_forearm"        -- Really high resistance and very low speed
    }

    local prost_base_hand = {
        "wood_base_hand",
        "metal_base_hand"
    }



    local prost_top = {
        "metal_hook",       -- Decent action speed (around 0.75), good durability, restores hand
        "metal_knife",      -- Doesn't count as an hand, but substitute the primary attack... Gonna need a way to disable it to make LIR work (retractable)
        "wooden_hook",      -- Shitty action speed (around 0.3), bad durability, restores hand
        "metal_hand"        -- Good action speed, amazing durability, restores hand
    }




    local TOC_straps = {
        leather_strap = {
            time_modifier = 1,
            durability = 1,
        },
        sheet_strap = {
            time_modifier = 0.3,
            durability = 0.4
        }
    }

    local TOC_base_lowerarm = {
        leather_base = {
            durability = 1,
            time_modifier = 1
        },
        wood_base = {
            durability = 1,
            time_modifier = 1,
        },
        metal_base = {
            durability = 1,
            time_modifier = 1,
        }
    }


    local TOC_base_hand = {
        wood_base = {
            durability = 1,
            time_modifier = 1,
        },
        metal_base = {
            durability = 1,
            time_modifier = 1,
        }
    }





    local TOC_top = {
        metal_hook = {
            type = "Normal",        -- restores functioning hand
            durability = 1,
            time_modifier = 1,
        },
        wooden_hook = {
            type = "Normal",
            durability = 1,
            time_modifier = 1,
        },

        metal_hand = {
            type = "Normal",
            durability = 1,
            time_modifier = 1,
        },

        metal_knife = {
            type = "Attack"
        }


    }




    -- We need A LOT of recipes... or use another menu from the toc one

    -- RECIPES FOR FOREARM = 24 RECIPES in total
    -- Would be 48 items in TOC_items since we need them for both sides


    -- RECIPES FOR HAND = 8 RECIPES in total
    -- Would be in total 16 items



    -- TOTAL = 64 ITEMS and 32 RECIPES

    -- Leather strap + leather base forearm + metal hook






    -- Base Item that can be crafted\found
    
    -- Different type of hooks

    -- Addons that can be added to the base item


    -- Equip and unequip pretty much the same

end