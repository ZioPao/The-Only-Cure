------------------------------------------
-------- THE ONLY CURE BUT BETTER --------
------------------------------------------
------------- INIT FUNCTIONS -------------

if not TOC then
    TOC = {}
end

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

TOC.InitPart = function(mod_data, part_name)

    mod_data.TOC.Limbs[part_name].is_cut = false
    mod_data.TOC.Limbs[part_name].is_infected = false
    mod_data.TOC.Limbs[part_name].is_operated = false
    mod_data.TOC.Limbs[part_name].is_cicatrized = false
    mod_data.TOC.Limbs[part_name].is_cauterized = false
    mod_data.TOC.Limbs[part_name].is_amputation_shown = false

    mod_data.TOC.Limbs[part_name].cicatrization_time = 0


    mod_data.TOC.Limbs[part_name].is_prosthesis_equipped = false
    mod_data.TOC.Limbs[part_name].equipped_prosthesis = {}



end

local function TocUpdateBaseData(mod_data)
    -- TODO Gonna delete this soon, overhauling the whole init thing

    -- TODO The prosthetic knife needs to be a weapon first and foremost, so other than a
    -- clothing item it needs to be a weapon too (an invisible one maybe?)

    --local prosthesis_list = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }

    local accepted_prosthesis_hand = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }
    local accepted_prosthesis_lowerarm = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }
    local accepted_prosthesis_upperarm = {} -- For future stuff
    local accepted_prosthesis_foot = {}

    for _, side in pairs(TOC.side_names) do
        for _, limb in pairs(TOC.limb_names) do

            local part_name = side .. "_" .. limb


            -- Check if part was initialized, in case of previous errors
            if mod_data.TOC.Limbs[part_name] == nil then
                TOC.InitPart(mod_data, part_name)
            end


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
            elseif limb == "Foot" then
                mod_data.TOC.Limbs[part_name].cicatrization_base_time = 1700
                mod_data.TOC.Limbs[part_name].depends_on = {}
                mod_data.TOC.Prosthesis.Accepted_Prosthesis[part_name] = accepted_prosthesis_foot

            end

        end
    end




end

TOC.SetInitData = function(mod_data, player)
    print("TOC: Creating mod_data.TOC")
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

    -- TODO this is gonna become a mess really fast, i fucked up.
    -- TODO Move prosthesis to something more easily accessible
    -- TODO Acceptable prosthesis need to be moved to something more accessible

    mod_data.TOC = {}

    -- Limbs
    mod_data.TOC.Limbs = {
        Right_Hand = {},
        Right_LowerArm = {},
        Right_UpperArm = {},

        Left_Hand = {},
        Left_LowerArm = {},
        Left_UpperArm = {},

        Left_Foot = {},
        Right_Foot = {},

        is_other_bodypart_infected = false
    }

    -- TODO Move this to the global TOC thing
    -- Prosthetics
    mod_data.TOC.Prosthesis = {
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

    }

    -- TODO Move this to the global TOC thing
    -- Generic (future uses)
    mod_data.TOC.Generic = {}


    for _, side in pairs(TOC.side_names) do
        for _, limb in pairs(TOC.limb_names) do
            local part_name = side .. "_" .. limb
            TOC.InitPart(mod_data, part_name)
        end
    end

    -- Set data like prosthesis lists, cicatrization time etc
    -- TODO Change this
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

function TOC.Init(_, player)

    local mod_data = player:getModData()

    if mod_data.TOC == nil then
        TOC.SetInitData(mod_data, player)
    else
        TocCheckCompatibilityWithOlderVersions(mod_data)

        -- TODO This is gonna be deleted and moved directly to TOC
        TocUpdateBaseData(mod_data)                 -- Since it's gonna be common to update stuff
        TocCheckLegsAmputations(mod_data)
    end

end

local function InitializeTraits()
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

------------------------------------------------------------------------------------

-- Rewrite 2 Electirc Bogaloo
local function InitializeTheOnlyCure()

    -- Initializes static values in a global table
    TOC.side_names = {"Left", "Right"}
    TOC.limb_names = { "Hand", "LowerArm", "UpperArm", "Foot"}

    TOC.limb_parameters = {}
    for _, side in pairs(TOC.side_names) do
        for _, limb in pairs(TOC.limb_names) do
            local part_name = side .. "_" .. limb

            if limb == "Hand" then
                TOC.limb_parameters[part_name].cicatrization_base_time = 1700
                TOC.limb_parameters[part_name].depends_on = {}
            elseif limb == "LowerArm" then
                TOC.limb_parameters[part_name].cicatrization_base_time = 1800
                TOC.limb_parameters[part_name].depends_on = { side .. "_Hand", }
            elseif limb == "UpperArm" then
                TOC.limb_parameters[part_name].cicatrization_base_time = 2000
                TOC.limb_parameters[part_name].depends_on = { side .. "_Hand", side .. "_LowerArm", }
            elseif limb == "Foot" then
                TOC.limb_parameters[part_name].cicatrization_base_time = 1700
                TOC.limb_parameters[part_name].depends_on = {}
            end
        end
    end

    InitializeTraits()
    Events.OnCreatePlayer.Add(TOC.Init)


end



Events.OnGameBoot.Add(InitializeTheOnlyCure)
