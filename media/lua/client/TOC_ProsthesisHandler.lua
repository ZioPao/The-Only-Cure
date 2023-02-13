-- Use the XLSX as a base for these stats
local base_table = {
    LeatherBase = {
        durability = 25,
        speed = 15
    },
    WoodenBase = {
        durability = 10,
        speed = 5,
    },
    MetalBase = {
        durability = 75,
        speed = 7,
    }




}


local top_table = {
    MetalHook = {
        durability = 1,
        speed = 1,
    },
    WoodenHook = {
        durability = 1,
        speed = 1,
    }

}



local function GetProsthesisStats(array_stats, prosthesis_name)
    local durability
    local speed
    for name, values in pairs(array_stats) do
        -- Check the name of the prosthesis item, set the correct values
        if string.find(prosthesis_name, name) then
            durability = values.durability
            speed = values.speed

            return durability, speed
        end
    end

end


---comment
---@param prosthesis_item any Normal item
---@param inventory any player inventory
---@param limb any
---@return unknown equipped_prosthesis clothing item equipped prosthesis
function GenerateEquippedProsthesis(prosthesis_item, inventory, limb)
    -- TODO Durability should be decided from the clothing item xml. Same thing for disassembling stuff
    -- TODO some stuff should be defined by the limb, like -10 if forearm in speed
    -- when we equip a prosthesis, we're gonna pass these parameters to the newly generated clothing item
    -- when we unequip it, we regen the normal item with the parameters from the clothing item

    local prosthesis_name = prosthesis_item:getFullType()
    local item_mod_data = prosthesis_item:getModData()



    local durability_base = 0
    local speed_base = 0

    local durability_top = 0
    local speed_top = 0


    -- Check the item mod data if the values are different than the default values

    if item_mod_data.TOC ~= nil then
        durability_base = item_mod_data.base_durability
        durability_top = item_mod_data.top_durability
    -- else
    --     durability_base, speed_base = GetProsthesisStats(base_table, prosthesis_name)
    --     durability_top, speed_top = GetProsthesisStats(top_table, prosthesis_name)
    end

    local equipped_prosthesis = inventory:AddItem(prosthesis_name)
    equipped_prosthesis:setCondition(prosthesis_item:getCondition())

    equipped_prosthesis:getModData().TOC = {
        base_durability = durability_base,
        top_durability = durability_top,
    }

    return equipped_prosthesis

end


----------------------------------------------------------
-- Recipe functions

ProsthesisRecipes = {}


local function GetProshetsisPartName(array_stats, prosthesis_name)
    for name, _ in pairs(array_stats) do
        if string.find(prosthesis_name, name) then
            return name
        end
    end

end

-- Creates the Normal Prosthesis Item
function ProsthesisRecipes.OnCreateProsthesis(items, result, player, selectedItem)
    -- TODO We need a screwdriver to craft it? Some screws maybe


    -- Set mod data for item with durability and all that crap

    -- Get condition from the items
    local condition = 0
    for i=1,items:size() do
        local item = items:get(i-1)
        condition = condition + item:getCondition()
    end

    result:setCondition(condition)      -- Should be the sum?

    result:getModData().TOC = {
        base_durability = 100,
        top_durability = 100,           -- Stores it here too so we can re-reference it for later
    }

end


-- Reassign the correct condition to each item
function ProsthesisRecipes.OnDisassembleProsthesis(item, result_items, player, selectedItem)

    -- Check durability of original item
    local item_mod_data = item.getModData().TOC

    local durability_top = item_mod_data.top.durability
    local durability_base = item_mod_data.base.durability

    -- TODO do we actually need to store speed again?
    local speed_top = item_mod_data.top.speed
    local speed_base = item_mod_data.base.speed


    -- Check name of the item
    local prosthesis_item_name = item:getFullType()

    local base_name = GetProshetsisPartName(base_table, prosthesis_item_name)
    local top_name = GetProshetsisPartName(top_table, prosthesis_item_name)

    print("TOC: " .. base_name .. " and " .. top_name)

    local player_inv = player:getInventory()

    local part_base = player_inv:AddItem("TOC.ProstPart" .. base_name)
    part_base:setCondition(durability_base)



    local part_top = player_inv:AddItem("TOC.ProstPart" .. top_name)
    part_top:setCondition(durability_top)




end



function ProsthesisRecipes.OnCreateProsthesisPartItem(items, result, player, selectedItem)
    -- TODO Assign condition here from the table


end






-- Parts should have a default condition max set at creation
-- When we create a prosthesis, we carry the condition from the parts
-- If we disassemble the prosthesis, the condition will be carried back to the parts

-- Speed stat should be managed in another way, so change it