-- TODO Rewrite how all prosthesis are handled

function TestStuffToc()

    local mod_data = player:getModData().TOC

    mod_data.TOC = {}
    
    mod_data.TOC  = {

        Limbs = {},
        Prosthesis = {},
        Generic = {},
    }




    --------
    -- NEW NAMING SCHEME

    ---- Amputations

    -- Amputation_Left_Hand
    -- Amputation_Right_UpperArm


    ---- Prosthesis to equip
    -- Prost_Left_Hand_MetalHook
    -- Prost_Right_Forearm_WoodenHook

    --- Objects
    -- Prost_Object_WoddenHook


    local sides = {"Left", "Right"}
    local limbs = {"Hand", "LowerArm", "UpperArm"}          -- Let's follow their naming


    local prosthesis_list = {"WoodenHook", "MetalHook", "MetalHand"}



    local accepted_prosthesis_hand = {"WoodenHook", "MetalHook", "MetalHand"}
    local accepted_prosthesis_lowerarm = {"WoodenHook", "MetalHook", "MetalHand"}
    local accepted_prosthesis_upperarm = {}     -- For future stuff





    for _, side in ipairs(sides) do
        for _, limb in ipairs(limbs) do

            local part_name = side .. "_" .. limb

            mod_data.TOC.Limbs[part_name].is_cut = false
            mod_data.TOC.Limbs[part_name].is_infected = false
            mod_data.TOC.Limbs[part_name].is_operated = false
            mod_data.TOC.Limbs[part_name].is_cicatrized = false
            mod_data.TOC.Limbs[part_name].is_cauterized = false
            mod_data.TOC.Limbs[part_name].is_amputation_shown = false
    
            mod_data.TOC.Limbs[part_name].cicatrization_time = 0
            
            
            mod_data.TOC.Limbs[part_name].is_prosthesis_equipped = false
            mod_data.TOC.Limbs[part_name].prosthesis_factor = 1.0
            mod_data.TOC.Limbs[part_name].prosthesis_material_id = nil

            
            -- Even if there are some duplicates, this is just easier in the end since we're gonna get fairly easily part_name
            if limb == "Hand" then
                mod_data.TOC.Prosthesis.AcceptedProsthesis[part_name] = accepted_prosthesis_hand



            elseif limb == "LowerArm" then
                mod_data.TOC.Prosthesis.AcceptedProsthesis[part_name] = accepted_prosthesis_lowerarm
            elseif limb == "UpperArm" then
                mod_data.TOC.Prosthesis.AcceptedProsthesis[part_name] = accepted_prosthesis_upperarm
            end
  
        end
    end

    for _, v in ipairs(prosthesis_list) do
        
        mod_data.TOC.Prosthesis[v].prosthesis_factor = 1.0      -- Default
        mod_data.TOC.Limbs[v].prosthesis_material_id = nil      -- Set texture?

        -- TODO Something else?

    end

end


function Test2Toc(part_name, prosthetic_name)

    --------
    -- NEW NAMING SCHEME

    ---- Amputations

    -- Amputation_Left_Hand
    -- Amputation_Right_UpperArm


    ---- Prosthesis to equip
    -- Prost_Left_Hand_MetalHook
    -- Prost_Right_Forearm_WoodenHook

    --- Objects
    -- Prost_Object_WoddenHook


    -- First value side, second value limb
    local part_name_table = {}

    for v in part_name:gmatch("([^_]+)") do
        table.insert(part_name_table, v)
    end

    -- TODO Probably add TOC. before prost_
    local prost_to_equip_name = "Prost_" .. part_name_table[1] .. "_" .. part_name_table[2] .. "_" .. prosthetic_name
    return prost_to_equip_name


end