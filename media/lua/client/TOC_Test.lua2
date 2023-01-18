-- TODO Rewrite how all prosthesis are handled

function TestStuffToc()

    local mod_data = player:getModData().TOC


    if mod_data.TOC == nil then
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
                    mod_data.TOC.Limbs[part_name].cicatrization_base_time = 1700
                    mod_data.TOC.Limbs[part_name].depends_on = {}
    
                    mod_data.TOC.Prosthesis.AcceptedProsthesis[part_name] = accepted_prosthesis_hand
                    mod_data.TOC.Prosthesis["WoodenHook"][part_name].prosthesis_factor = 1.5
                    mod_data.TOC.Prosthesis["MetalHook"][part_name].prosthesis_factor = 1.3
                    mod_data.TOC.Prosthesis["MetalHand"][part_name].prosthesis_factor = 1.1
    
    
                elseif limb == "LowerArm" then
                    mod_data.TOC.Limbs[part_name].cicatrization_base_time = 1800
                    mod_data.TOC.Limbs[part_name].depends_on = {side .. "_Hand",}
                    mod_data.TOC.Prosthesis.AcceptedProsthesis[part_name] = accepted_prosthesis_lowerarm
    
                    mod_data.TOC.Prosthesis["WoodenHook"][part_name].prosthesis_factor = 1.65
                    mod_data.TOC.Prosthesis["MetalHook"][part_name].prosthesis_factor = 1.45
                    mod_data.TOC.Prosthesis["MetalHand"][part_name].prosthesis_factor = 1.25
                elseif limb == "UpperArm" then
                    mod_data.TOC.Limbs[part_name].cicatrization_base_time = 2000
                    mod_data.TOC.Limbs[part_name].depends_on = {side .. "_Hand", side .. "_LowerArm",}
                    mod_data.TOC.Prosthesis.AcceptedProsthesis[part_name] = accepted_prosthesis_upperarm
                end
      
            end
        end
    
        -- Setup traits
        if player:HasTrait("Amputee_Hand") then
    
            -- TODO override AddItem so we can change the texture dynamically based on skin color
            local amputation_clothing = player:getInventory():AddItem("TOC.Amputation_Left_Hand")
            player:setWornItem(amputation_clothing:getBodyLocation(), amputation_clothing)
            mod_data.TOC.Left_Hand.is_cut = true
            mod_data.TOC.Left_Hand.is_operated = true
            mod_data.TOC.Left_Hand.is_amputation_shown = true
            mod_data.TOC.Left_Hand.is_cicatrized = true
        elseif player:HasTrait("Amputee_LowerArm") then
            local amputation_clothing = player:getInventory():AddItem("TOC.Amputation_Left_LowerArm")
            player:setWornItem(amputation_clothing:getBodyLocation(), amputation_clothing)
            mod_data.TOC.Left_LowerArm.is_cut = true
            mod_data.TOC.Left_LowerArm.is_operated = true
            mod_data.TOC.Left_LowerArm.is_amputation_shown = true
            mod_data.TOC.Left_LowerArm.is_cicatrized = true
        elseif player:HasTrait("Amputee_UpperArm") then
            local amputation_clothing = player:getInventory():AddItem("TOC.Amputation_Left_UpperArm")
            player:setWornItem(amputation_clothing:getBodyLocation(), amputation_clothing)
            mod_data.TOC.Left_UpperArm.is_cut = true
            mod_data.TOC.Left_UpperArm.is_operated = true
            mod_data.TOC.Left_UpperArm.is_amputation_shown = true
            mod_data.TOC.Left_UpperArm.is_cicatrized = true
        end

    end
   

end


function TheOnlyCure.DeclareTraits2()
    local amp1 = TraitFactory.addTrait("Amputee_Hand", getText("UI_trait_Amputee_Hand"), -8, getText("UI_trait_Amputee_Hand_desc"), false, false)
    amp1:addXPBoost(Perks.LeftHand, 4)

    local amp2 = TraitFactory.addTrait("Amputee_LowerArm", getText("UI_trait_Amputee_LowerArm"), -10, getText("UI_trait_Amputee_LowerArm_desc"), false, false)
    amp2:addXPBoost(Perks.LeftHand, 4)

    local amp3 = TraitFactory.addTrait("Amputee_UpperArm", getText("UI_trait_Amputee_UpperArm"), -20, getText("UI_trait_Amputee_UpperArm_desc"), false, false)
    amp3:addXPBoost(Perks.LeftHand, 4)

    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false, false)
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_LowerArm")
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_UpperArm")
    TraitFactory.setMutualExclusive("Amputee_LowerArm", "Amputee_UpperArm")
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