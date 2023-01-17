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
    










    -- Setup prosthesis table

    local prosthesis_table = {
    }





    for _ ,v in pairs(GetBodyParts()) do
        mod_data.TOC.Limbs[v].is_cut = false
        mod_data.TOC.Limbs[v].is_infected = false
        mod_data.TOC.Limbs[v].is_operated = false
        mod_data.TOC.Limbs[v].is_cicatrized = false
        mod_data.TOC.Limbs[v].is_cauterized = false
        mod_data.TOC.Limbs[v].is_amputation_shown = false

        mod_data.TOC.Limbs[v].cicatrization_time = 0
        
        
        mod_data.TOC.Limbs[v].is_prosthesis_equipped = false
        mod_data.TOC.Limbs[v].prosthesis_factor = 1.0
        mod_data.TOC.Limbs[v].prosthesis_material_id = nil


        -- Prosthesis part
        mod_data.TOC.Prosthesis[v].accepted_prosthesis = {}
        mod_data.TOC.Prosthesis



    end


    mod_data.TOC.Prosthesis.list = GetProsthesisList()

    for _,v in ipairs(GetProsthesisLisHumanReadable()) do   
        mod_data.TOC.Prosthesis[v].
        


    end




        RightHand = {},
        RightForearm = {},
        RightArm = {},

        LeftHand = {},
        LeftForearm = {},
        LeftArm = {},

        is_other_bodypart_infected = false
    }


end