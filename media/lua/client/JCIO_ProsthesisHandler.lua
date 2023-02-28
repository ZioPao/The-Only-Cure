-- Use the XLSX as a base for these stats
local baseTable = {
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
local topTable = {
    MetalHook = {
        durability = 1,
        speed = 1,
    },
    WoodenHook = {
        durability = 1,
        speed = 1,
    }

}



local function GetProsthesisStats(arrayStats, prosthesisName)
    local durability
    local speed
    for name, values in pairs(arrayStats) do
        -- Check the name of the prosthesis item, set the correct values
        if string.find(prosthesisName, name) then
            durability = values.durability
            speed = values.speed

            return durability, speed
        end
    end

end


---comment
---@param prosthesisItem any Normal item
---@param inventory any player inventory
---@param limb any
---@return any equipped_prosthesis clothing item equipped prosthesis
function GenerateEquippedProsthesis(prosthesisItem, inventory, limb)
    -- TODO Durability should be decided from the clothing item xml. Same thing for disassembling stuff
    -- TODO some stuff should be defined by the limb, like -10 if forearm in speed
    -- when we equip a prosthesis, we're gonna pass these parameters to the newly generated clothing item
    -- when we unequip it, we regen the normal item with the parameters from the clothing item

    local prosthesisName = prosthesisItem:getFullType()
    local itemModData = prosthesisItem:getModData()

    local durabilityBase = 0
    local speedBase = 0

    local durabilityTop = 0
    local speedTop = 0


    -- Check the item mod data if the values are different than the default values

    if itemModData.JCIO ~= nil then
        durabilityBase = itemModData.baseDurability
        durabilityTop = itemModData.topDurability
    -- else
    --     durability_base, speed_base = GetProsthesisStats(base_table, prosthesis_name)
    --     durability_top, speed_top = GetProsthesisStats(top_table, prosthesis_name)
    end

    local equippedProsthesis = inventory:AddItem(prosthesisName)
    equippedProsthesis:setCondition(prosthesisItem:getCondition())

    equippedProsthesis:getModData().JCIO = {
        baseDurability = durabilityBase,
        topDurability = durabilityTop,
    }

    return equippedProsthesis

end


----------------------------------------------------------
-- Recipe functions

ProsthesisRecipes = {}

-- Parts should have a default condition max set at creation
-- When we create a prosthesis, we carry the condition from the parts
-- If we disassemble the prosthesis, the condition will be carried back to the parts
-- Speed stat should be managed in another way, so change it


local function GetProsthesisPartName(arrayStats, prosthesisName)
    for name, _ in pairs(arrayStats) do
        if string.find(prosthesisName, name) then
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

    result:getModData().JCIO = {
        baseDurability = 100,
        topDurability = 100,           -- Stores it here too so we can re-reference it for later
    }

end


-- Reassign the correct condition to each item
function ProsthesisRecipes.OnDisassembleProsthesis(item, resultItems, player, selectedItem)

    -- Check durability of original item
    local itemModData = item.getModData().JCIO

    local durabilityTop = itemModData.top.durability
    local durabilityBase = itemModData.base.durability

    -- TODO do we actually need to store speed again?
    local speedTop = itemModData.top.speed
    local speedBase = itemModData.base.speed


    -- Check name of the item
    local prosthesisItemName = item:getFullType()

    local baseName = GetProsthesisPartName(baseTable, prosthesisItemName)
    local topName = GetProsthesisPartName(topTable, prosthesisItemName)

    print("JCIO: " .. baseName .. " and " .. topName)

    local playerInv = player:getInventory()

    local partBase = playerInv:AddItem("JCIO.ProstPart" .. baseName)
    partBase:setCondition(durabilityBase)



    local partTop = playerInv:AddItem("JCIO.ProstPart" .. topName)
    partTop:setCondition(durabilityTop)


    -- TODO Add Screws from the item back with a chance of them breaking



end

function ProsthesisRecipes.OnCreateProsthesisPartItem(items, result, player, selectedItem)
    -- TODO Assign condition here from the table
end





