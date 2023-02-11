local BaseStats = {
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


local TopStats = {

}







function GenerateEquippedProsthesis(prosthesis_item, limb)
    -- TODO Durability should be decided from the clothing item xml. Same thing for disassembling stuff

    -- TODO some stuff should be defined by the limb, like -10 if forearm in speed
--     -- when we equip a prosthesis, we're gonna pass these parameters to the newly generated clothing item
--     -- when we unequip it, we regen the normal item with the parameters from the clothing item

    local durability = 0
    local speed = 0

    local prosthesis_name = prosthesis_item:getFullType()

    for base_name, base_values in pairs(BaseStats) do
        -- Check the name of the prosthesis item, set the correct values
        if string.find(prosthesis_name, base_name) then
            durability = base_values.durability
            speed = base_values.speed
        end
    end



    for top_name, top_values in pairs(TopStats) do
        -- Check the name of the prosthesis item, set the correct values
        if string.find(prosthesis_name, top_name) then
            durability = durability + top_values.durability
            speed = speed + top_values.speed
        end
    end

    local item_mod_data = prosthesis_item:getModData()

    --------------------
    -- TEST STUFF
    durability = 12
    speed = 51

    -------------------


    item_mod_data.TOC = {
        durability = durability,
        speed = speed,
    }
end

--local ProsthesisRecipe = {}


-- function ProsthesisRecipe.OnCreate.Hook(items, result, player, selectedItem)

--     -- Set mod data for item with durability and all that crap



-- end



