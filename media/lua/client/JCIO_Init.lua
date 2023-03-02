------------------------------------------
------------- JUST CUT IT OUT ------------
------------------------------------------
------------- INIT FUNCTIONS -------------
--[[
Original code and idea by: Mr. Bounty
Rewritten by: Pao
--]]


JCIO.InitializeTraits = function()
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

JCIO.CutLimbForTrait = function(player, jcioModData, partName)

    local limbsData = jcioModData.limbs

    local amputationClothingItem = player:getInventory():AddItem("JCIO.Amputation_" .. partName)
    JCIO_Visuals.SetTextureForAmputation(amputationClothingItem, player, true)

    player:setWornItem(amputationClothingItem:getBodyLocation(), amputationClothingItem)
    limbsData[partName].isCut = true
    limbsData[partName].isOperated = true
    limbsData[partName].isAmputationShown = true
    limbsData[partName].isCicatrized = true

    for _, v in pairs(JCIO.limbParameters[partName].dependsOn) do
        limbsData[v].isCut = true
        limbsData[v].isOperated = true
        limbsData[v].isAmputationShown = false
        limbsData[v].isCicatrized = true
    end
end

JCIO.InitPart = function(limbsData, partName)

    limbsData[partName].isCut = false
    limbsData[partName].isInfected = false
    limbsData[partName].isOperated = false
    limbsData[partName].isCicatrized = false
    limbsData[partName].isCauterized = false
    limbsData[partName].isAmputation_shown = false

    limbsData[partName].cicatrizationTime = 0

    limbsData[partName].isProsthesisEquipped = false
    limbsData[partName].equippedProsthesis = {}

end

JCIO.SetInitData = function(modData, player)
    print("JCIO: Creating mod_data.JCIO")
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

    -- Setup traits
    if player:HasTrait("Amputee_Hand") then
        JCIO.CutLimbForTrait(player, modData.JCIO, "Left_Hand")
    elseif player:HasTrait("Amputee_LowerArm") then
        JCIO.CutLimbForTrait(player, modData.JCIO, "Left_LowerArm")
    elseif player:HasTrait("Amputee_UpperArm") then
        JCIO.CutLimbForTrait(player, modData.JCIO, "Left_UpperArm")
    end

end

JCIO.Init = function(_, player)

    local modData = player:getModData()
    if modData.JCIO == nil then
        JCIO.SetInitData(modData, player)
    else
        JCIO_Compat.CheckCompatibilityWithOlderVersions(modData)
        JCIO_Anims.CheckAndSetMissingFootAnims(modData)
        
    end

    -- Compat fix with older versions
    if modData.TOC ~= nil then
        print("JCIO: found older data from TOC or TOCBB")
        JCIO_Compat.CheckCompatibilityWithOlderVersions(modData)
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
                JCIO.limbParameters[partName].cicatrizationBaseTime = 1700
                JCIO.limbParameters[partName].dependsOn = {}
            elseif limb == "LowerArm" then
                JCIO.limbParameters[partName].cicatrizationBaseTime = 1800
                JCIO.limbParameters[partName].dependsOn = { side .. "_Hand", }
            elseif limb == "UpperArm" then
                JCIO.limbParameters[partName].cicatrizationBaseTime = 2000
                JCIO.limbParameters[partName].dependsOn = { side .. "_Hand", side .. "_LowerArm", }
            elseif limb == "Foot" then
                JCIO.limbParameters[partName].cicatrizationBaseTime = 1700
                JCIO.limbParameters[partName].dependsOn = {}
            end
        end
    end


    --------------------------

    JCIO.InitializeTraits()
    Events.OnCreatePlayer.Add(JCIO.Init)

    -- Setup updates
    Events.OnTick.Add(JCIO.UpdateOnTick)
    Events.EveryTenMinutes.Add(JCIO.UpdateEveryTenMinutes)
    Events.EveryOneMinute.Add(JCIO.UpdateEveryOneMinute)


    -- Mod Checker
    CheckMyModTable = CheckMyModTable or {}
    CheckMyModTable["JCIO"] = 2915572347



end
Events.OnGameBoot.Add(InitializeJustCutItOff)