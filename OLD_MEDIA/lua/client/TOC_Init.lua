------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
------------- INIT FUNCTIONS -------------
--[[
Original code and idea by: Mr. Bounty
Rewritten and maintained by: Pao
--]]


TOC.InitializeTraits = function()
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

TOC.CutLimbForTrait = function(player, TOCModData, partName)

    local limbsData = TOCModData.limbs

    local amputationClothingItem = player:getInventory():AddItem("TOC.Amputation_" .. partName)
    TOC_Visuals.SetTextureForAmputation(amputationClothingItem, player, true)

    player:setWornItem(amputationClothingItem:getBodyLocation(), amputationClothingItem)
    limbsData[partName].isCut = true
    limbsData[partName].isOperated = true
    limbsData[partName].isAmputationShown = true
    limbsData[partName].isCicatrized = true

    for _, v in pairs(TOC.limbParameters[partName].dependsOn) do
        limbsData[v].isCut = true
        limbsData[v].isOperated = true
        limbsData[v].isAmputationShown = false
        limbsData[v].isCicatrized = true
    end
end

TOC.InitPart = function(limbsData, partName)

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

TOC.SetInitData = function(modData, player)
    print("TOC: Creating mod_data.TOC")
    modData.TOC = {}

    -- Limbs
    modData.TOC.limbs = {
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
    for _, side in pairs(TOC.sideNames) do
        for _, limb in pairs(TOC.limbNames) do
            local partName = TOC_Common.ConcatPartName(side, limb)
            TOC.InitPart(modData.TOC.limbs, partName)
        end
    end

    -- Setup traits
    if player:HasTrait("Amputee_Hand") then
        TOC.CutLimbForTrait(player, modData.TOC, "Left_Hand")
    elseif player:HasTrait("Amputee_LowerArm") then
        TOC.CutLimbForTrait(player, modData.TOC, "Left_LowerArm")
    elseif player:HasTrait("Amputee_UpperArm") then
        TOC.CutLimbForTrait(player, modData.TOC, "Left_UpperArm")
    end

end

TOC.Init = function(_, player)

    local modData = player:getModData()
    if modData.TOC == nil then
        TOC.SetInitData(modData, player)
    else
        TOC_Compat.CheckCompatibilityWithOlderVersions(modData)
        TOC_Anims.CheckAndSetMissingFootAnims(modData)
        
    end

    -- Compat fix with older versions
    if modData.TOC ~= nil then
        print("TOC: found older data from TOC or TOCBB")
        TOC_Compat.CheckCompatibilityWithOlderVersions(modData)
    end

end

------------------------------------------------------------------------------------

-- Rewrite 2 Electirc Bogaloo
local function InitializeTheOnlyCure()

    if not TOC then
        TOC = {}
    end


    -- Initializes static values in a global table
    TOC.sideNames = {"Left", "Right"}
    TOC.limbNames = { "Hand", "LowerArm", "UpperArm", "Foot"}

    TOC.limbParameters = {}
    for _, side in pairs(TOC.sideNames) do
        for _, limb in pairs(TOC.limbNames) do
            local partName = TOC_Common.ConcatPartName(side, limb)
            TOC.limbParameters[partName] = {}

            if limb == "Hand" then
                TOC.limbParameters[partName].cicatrizationBaseTime = 1700
                TOC.limbParameters[partName].dependsOn = {}
            elseif limb == "LowerArm" then
                TOC.limbParameters[partName].cicatrizationBaseTime = 1800
                TOC.limbParameters[partName].dependsOn = { TOC_Common.ConcatPartName(side, "Hand") }
            elseif limb == "UpperArm" then
                TOC.limbParameters[partName].cicatrizationBaseTime = 2000
                TOC.limbParameters[partName].dependsOn = { TOC_Common.ConcatPartName(side, "Hand"), TOC_Common.ConcatPartName(side, "LowerArm"), }
            elseif limb == "Foot" then
                TOC.limbParameters[partName].cicatrizationBaseTime = 1700
                TOC.limbParameters[partName].dependsOn = {}
            end
        end
    end


    --------------------------

    TOC.InitializeTraits()
    Events.OnCreatePlayer.Add(TOC.Init)

    -- Setup updates
    Events.OnTick.Add(TOC.UpdateOnTick)
    Events.EveryTenMinutes.Add(TOC.UpdateEveryTenMinutes)
    Events.EveryOneMinute.Add(TOC.UpdateEveryOneMinute)


    -- Mod Checker
    CheckMyModTable = CheckMyModTable or {}
    CheckMyModTable["Amputation"] = 2703664356     -- TODO should we change the ID with the update or not?



end
Events.OnGameBoot.Add(InitializeTheOnlyCure)