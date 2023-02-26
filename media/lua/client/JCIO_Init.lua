------------------------------------------
------------- JUST CUT IT OFF ------------
------------------------------------------
------------- INIT FUNCTIONS -------------
--[[
Original code and idea by: Mr. Bounty
Rewritten by: Pao
--]]


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
-- TODO Refactor this
local function TocUpdateBaseData(mod_data)
    -- TODO Gonna delete this soon, overhauling the whole init thing

    -- TODO The prosthetic knife needs to be a weapon first and foremost, so other than a
    -- clothing item it needs to be a weapon too (an invisible one maybe?)

    --local prosthesis_list = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }

    local accepted_prosthesis_hand = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }
    local accepted_prosthesis_lowerarm = { "WoodenHook", "MetalHook", "MetalHand", "ProstheticKnife" }
    local accepted_prosthesis_upperarm = {} -- For future stuff
    local accepted_prosthesis_foot = {}

    for _, side in pairs(JCIO.sideNames) do
        for _, limb in pairs(JCIO.limbNames) do

            local part_name = side .. "_" .. limb


            -- Check if part was initialized, in case of previous errors
            if mod_data.TOC.Limbs[part_name] == nil then
                JCIO.InitPart(mod_data.TOC.Limbs, part_name)
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

JCIO.CutLimbForTrait = function(player, limbs_data, part_name)
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
JCIO.InitPart = function(limbs_data, part_name)

    limbs_data[part_name].is_cut = false
    limbs_data[part_name].is_infected = false
    limbs_data[part_name].is_operated = false
    limbs_data[part_name].is_cicatrized = false
    limbs_data[part_name].is_cauterized = false
    limbs_data[part_name].is_amputation_shown = false

    limbs_data[part_name].cicatrization_time = 0

    limbs_data[part_name].is_prosthesis_equipped = false
    limbs_data[part_name].equipped_prosthesis = {}

end
JCIO.SetInitData = function(modData, player)
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

    modData.JCIO = {}

    -- Limbs
    modData.JCIO.limbs = {
        Right_Hand = {},
        Right_LowerArm = {},
        Right_UpperArm = {},

        Left_Hand = {},
        Left_LowerArm = {},
        Left_UpperArm = {},

        Left_Foot = {},
        Right_Foot = {},

        isOtherBodypartInfected = false
    }

    -- TODO Move this to the global TOC thing
    -- Prosthetics
    modData.JCIO.prosthesis = {
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
    modData.JCIO.generic = {}


    for _, side in pairs(JCIO.sideNames) do
        for _, limb in pairs(JCIO.limbNames) do
            local partName = side .. "_" .. limb
            JCIO.InitPart(modData.JCIO.limbs, partName)
        end
    end

    -- Set data like prosthesis lists, cicatrization time etc
    -- TODO Change this
    TocUpdateBaseData(modData)

    -- Setup traits
    if player:HasTrait("Amputee_Hand") then
        JCIO.CutLimbForTrait(player, modData.JCIO.limbs, "Left_Hand")
    elseif player:HasTrait("Amputee_LowerArm") then
        JCIO.CutLimbForTrait(player, modData.TOC.limbs, "Left_LowerArm")
    elseif player:HasTrait("Amputee_UpperArm") then
        JCIO.CutLimbForTrait(player, modData.TOC.limbs, "Left_UpperArm")
    end

end
JCIO.Init = function(_, player)

    local modData = player:getModData()
    if modData.JCIO == nil then
        JCIO.SetInitData(modData, player)
    else
        JCIOCompat.CheckCompatibilityWithOlderVersions(modData)

        -- TODO This is gonna be deleted and moved directly to TOC
        TocUpdateBaseData(modData)                 -- Since it's gonna be common to update stuff
        TocCheckLegsAmputations(modData)
    end

    -- Compat fix with older versions
    if modData.TOC ~= nil then
        print("JCIO: found older data from TOC or TOCBB")
        JCIOCompat.CheckCompatibilityWithOlderVersions(modData)
    end

end

------------------------------------------------------------------------------------

-- Rewrite 2 Electirc Bogaloo
local function InitializeJustCutItOff()

    if not JCIO then
        JCIO = {}
    end


    -- Initializes static values in a global table
    JCIO.sideNames = {"Left", "Right"}
    JCIO.limbNames = { "Hand", "LowerArm", "UpperArm", "Foot"}

    JCIO.limbParameters = {}
    for _, side in pairs(JCIO.sideNames) do
        for _, limb in pairs(JCIO.limbNames) do
            local partName = side .. "_" .. limb
            JCIO.limbParameters[partName] = {}

            if limb == "Hand" then
                JCIO.limbParameters[partName].cicatrization_base_time = 1700
                JCIO.limbParameters[partName].depends_on = {}
            elseif limb == "LowerArm" then
                JCIO.limbParameters[partName].cicatrization_base_time = 1800
                JCIO.limbParameters[partName].depends_on = { side .. "_Hand", }
            elseif limb == "UpperArm" then
                JCIO.limbParameters[partName].cicatrization_base_time = 2000
                JCIO.limbParameters[partName].depends_on = { side .. "_Hand", side .. "_LowerArm", }
            elseif limb == "Foot" then
                JCIO.limbParameters[partName].cicatrization_base_time = 1700
                JCIO.limbParameters[partName].depends_on = {}
            end
        end
    end

    --------------------------

    InitializeTraits()
    Events.OnCreatePlayer.Add(JCIO.Init)

    -- Setup updates
    Events.OnTick.Add(JCIO.UpdateOnTick)
    Events.EveryTenMinutes.Add(JCIO.UpdateEveryTenMinutes)
    Events.EveryOneMinute.Add(JCIO.UpdateEveryOneMinute)


end
Events.OnGameBoot.Add(InitializeJustCutItOff)