if not TheOnlyCure then
    TheOnlyCure = {}
end

TOC_sides = { "Left", "Right" }
TOC_limbs = { "Hand", "LowerArm", "UpperArm" }

local function TocCutLimbForTrait(player, limbs_data, part_name)
    local amputation_clothing_item = player:getInventory():AddItem("TOC.Amputation_" .. part_name)
    TocSetCorrectTextureForAmputation(amputation_clothing_item, player, true)

    player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)
    limbs_data[part_name].is_cut = true
    limbs_data[part_name].is_operated = true
    limbs_data[part_name].is_amputation_shown = true
    limbs_data[part_name].is_cicatrized = true

    for _, v in pairs(limbs_data[part_name].depends_on) do
        limbs_data[v].is_cut = true
        limbs_data[v].is_operated = true
        limbs_data[v].is_amputation_shown = false
        limbs_data[v].is_cicatrized = true
    end
end

-- Sub function of TocSetInitData
local function TocUpdateBaseData(mod_data)

    -- TODO The prosthetic knife needs to be a weapon first and foremost, so other than a
    -- clothing item it needs to be a weapon too (an invisible one maybe?)

    --local prosthesis_list = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }

    local accepted_prosthesis_hand = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }
    local accepted_prosthesis_lowerarm = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }
    local accepted_prosthesis_upperarm = {} -- For future stuff

    for _, side in ipairs(TOC_sides) do
        for _, limb in ipairs(TOC_limbs) do

            local part_name = side .. "_" .. limb

            if limb == "Hand" then
                mod_data.TOC.Limbs[part_name].cicatrization_base_time = 1700
                mod_data.TOC.Limbs[part_name].depends_on = {}


                mod_data.TOC.Prosthesis.Accepted_Prosthesis[part_name] = accepted_prosthesis_hand
                mod_data.TOC.Prosthesis["WoodenHook"][part_name].prosthesis_factor = 1.3
                mod_data.TOC.Prosthesis["MetalHook"][part_name].prosthesis_factor = 1.2
                mod_data.TOC.Prosthesis["MetalHand"][part_name].prosthesis_factor = 1.1
                --mod_data.TOC.Prosthesis["ProstheticKnife"][part_name].prosthesis_factor = 1.5


            elseif limb == "LowerArm" then
                mod_data.TOC.Limbs[part_name].cicatrization_base_time = 1800
                mod_data.TOC.Limbs[part_name].depends_on = { side .. "_Hand", }
                mod_data.TOC.Prosthesis.Accepted_Prosthesis[part_name] = accepted_prosthesis_lowerarm

                mod_data.TOC.Prosthesis["WoodenHook"][part_name].prosthesis_factor = 1.35
                mod_data.TOC.Prosthesis["MetalHook"][part_name].prosthesis_factor = 1.25
                mod_data.TOC.Prosthesis["MetalHand"][part_name].prosthesis_factor = 1.15
                --mod_data.TOC.Prosthesis["ProstheticKnife"][part_name].prosthesis_factor = 1.6

            elseif limb == "UpperArm" then
                mod_data.TOC.Limbs[part_name].cicatrization_base_time = 2000
                mod_data.TOC.Limbs[part_name].depends_on = { side .. "_Hand", side .. "_LowerArm", }
                mod_data.TOC.Prosthesis.Accepted_Prosthesis[part_name] = accepted_prosthesis_upperarm
            end

        end
    end




end

local function TocSetInitData(mod_data, player)

    print("TOC: Creating mod_data.TOC")


    -- TODO this is gonna become a mess really fast, i fucked up.
    -- TODO Move prosthesis to something more easily accessible
    -- TODO Acceptable prosthesis need to be moved to something more accessible





    mod_data.TOC = {

        Limbs = {
            Right_Hand = {},
            Right_LowerArm = {},
            Right_UpperArm = {},

            Left_Hand = {},
            Left_LowerArm = {},
            Left_UpperArm = {},
            is_other_bodypart_infected = false
        },
        Prosthesis = {
            WoodenHook = {
                Right_Hand = {},
                Right_LowerArm = {},
                Right_UpperArm = {},

                Left_Hand = {},
                Left_LowerArm = {},
                Left_UpperArm = {},
            },
            MetalHook = {
                Right_Hand = {},
                Right_LowerArm = {},
                Right_UpperArm = {},

                Left_Hand = {},
                Left_LowerArm = {},
                Left_UpperArm = {},
            },
            MetalHand = {
                Right_Hand = {},
                Right_LowerArm = {},
                Right_UpperArm = {},

                Left_Hand = {},
                Left_LowerArm = {},
                Left_UpperArm = {},
            },



            Accepted_Prosthesis = {}

        },
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






    for _, side in ipairs(TOC_sides) do
        for _, limb in ipairs(TOC_limbs) do

            local part_name = side .. "_" .. limb

            mod_data.TOC.Limbs[part_name].is_cut = false
            mod_data.TOC.Limbs[part_name].is_infected = false
            mod_data.TOC.Limbs[part_name].is_operated = false
            mod_data.TOC.Limbs[part_name].is_cicatrized = false
            mod_data.TOC.Limbs[part_name].is_cauterized = false
            mod_data.TOC.Limbs[part_name].is_amputation_shown = false

            mod_data.TOC.Limbs[part_name].cicatrization_time = 0


            mod_data.TOC.Limbs[part_name].is_prosthesis_equipped = false
            mod_data.TOC.Limbs[part_name].equipped_prosthesis = {}

            -- Even if there are some duplicates, this is just easier in the end since we're gonna get fairly easily part_name



        end
    end

    -- Set data like prosthesis lists, cicatrization time etc
    TocUpdateBaseData(mod_data)

    -- Setup traits
    if player:HasTrait("Amputee_Hand") then
        TocCutLimbForTrait(player, mod_data.TOC.Limbs, "Left_Hand")
    elseif player:HasTrait("Amputee_LowerArm") then
        TocCutLimbForTrait(player, mod_data.TOC.Limbs, "Left_LowerArm")
    elseif player:HasTrait("Amputee_UpperArm") then
        TocCutLimbForTrait(player, mod_data.TOC.Limbs, "Left_UpperArm")
    end

end



function TheOnlyCure.InitTheOnlyCure(_, player)

    local mod_data = player:getModData()
    if mod_data.TOC == nil then
        TocSetInitData(mod_data, player)
    else
        TocCheckCompatibilityWithOlderVersions(mod_data)
        TocUpdateBaseData(mod_data) -- Since it's gonna be common to update stuff
    end

end


function TheOnlyCure.DeclareTraits()
    local amp1 = TraitFactory.addTrait("Amputee_Hand", getText("UI_trait_Amputee_Hand"), -8,
        getText("UI_trait_Amputee_Hand_desc"), false, false)
    amp1:addXPBoost(Perks.Left_Hand, 4)
    amp1:addXPBoost(Perks.Fitness, -1)
    amp1:addXPBoost(Perks.Strength, -1)

    local amp2 = TraitFactory.addTrait("Amputee_LowerArm", getText("UI_trait_Amputee_LowerArm"), -10,
        getText("UI_trait_Amputee_LowerArm_desc"), false, false)
    amp2:addXPBoost(Perks.Left_Hand, 4)
    amp2:addXPBoost(Perks.Fitness, -1)
    amp2:addXPBoost(Perks.Strength, -1)

    local amp3 = TraitFactory.addTrait("Amputee_UpperArm", getText("UI_trait_Amputee_UpperArm"), -20,
        getText("UI_trait_Amputee_UpperArm_desc"), false, false)
    amp3:addXPBoost(Perks.Left_Hand, 4)
    amp3:addXPBoost(Perks.Fitness, -1)
    amp3:addXPBoost(Perks.Strength, -1)

    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false,
        false)
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_LowerArm")
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_UpperArm")
    TraitFactory.setMutualExclusive("Amputee_LowerArm", "Amputee_UpperArm")
end

function TryTocAction(_, part_name, action, surgeon, patient)
    -- TODO add checks so that we don't show these menus if a player has already beeen operated or amputated
    -- TODO at this point surgeon doesnt do anything. We'll fix this later

    -- Check if SinglePlayer
    if not isServer() and not isClient() then

        if action == "Cut" then
            TocCutLocal(_, surgeon, part_name)
        elseif action == "Operate" then
            TocOperateLocal(_, surgeon, part_name, false)
        elseif action == "Equip" then
            TocEquipProsthesisLocal(_, surgeon, part_name)
        elseif action == "Unequip" then
            TocUnequipProsthesisLocal(_, surgeon, part_name)
        end
    else
        local ui = GetConfirmUIMP()
        if not ui then
            CreateTocConfirmUIMP()
            ui = GetConfirmUIMP()
        end

        if patient == nil then
            patient = surgeon
        end


        if action == "Cut" then
            AskCanCutLimb(patient, part_name)
        elseif action == "Operate" then
            AskCanOperateLimb(patient, part_name)
        elseif action == "Equip" then
            AskCanEquipProsthesis(patient, part_name)
        elseif action == "Unequip" then
            AskCanUnequipProsthesis(patient, part_name)
        end

        ui.actionAct = action
        ui.partNameAct = part_name
        ui.patient = patient

        SendCommandToConfirmUIMP("Wait server")

    end
end

Events.OnCreatePlayer.Add(TheOnlyCure.InitTheOnlyCure)
Events.OnGameBoot.Add(TheOnlyCure.DeclareTraits)
