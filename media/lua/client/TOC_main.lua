if not TheOnlyCure then
    TheOnlyCure = {}
end

-- GLOBAL STRINGS
Left = "Left"
Right = "Right"

Hand = "Hand"
Forearm = "Forearm"
Arm = "Arm"

function TheOnlyCure.InitTheOnlyCure(_, player)

    local mod_data = player:getModData()
    --local toc_data = player:getModData().TOC

    if mod_data.TOC == nil then

        mod_data.TOC = {}
        print("CREATING NEW TOC STUFF SINCE YOU JUST DIED")
         
        local rightHand = "RightHand"
        local rightForearm = "RightForearm"
        local rightArm = "RightArm"

        local leftHand = "LeftHand"
        local leftForearm = "LeftForearm"
        local leftArm = "LeftArm"

        mod_data.TOC  = {
            RightHand = {},
            RightForearm = {},
            RightArm = {},

            LeftHand = {},
            LeftForearm = {},
            LeftArm = {},

            is_other_bodypart_infected = false
        }

        for _ ,v in pairs(GetBodyParts()) do
            mod_data.TOC[v].is_cut = false
            mod_data.TOC[v].is_infected = false
            mod_data.TOC[v].is_operated = false
            mod_data.TOC[v].is_cicatrized = false
            mod_data.TOC[v].is_cauterized = false
            mod_data.TOC[v].is_amputation_shown = false

            mod_data.TOC[v].cicatrization_time = 0
            
            
            mod_data.TOC[v].has_prosthesis_equipped = false
            mod_data.TOC[v].prothesis_factor = 1.0       -- TODO Every prosthesis has the same... does this even make sense here?
            mod_data.TOC[v].prothesis_material_id = nil
        end


        -- Manual stuff, just a temporary fix since this is kinda awful
        mod_data.TOC[rightHand].depends_on = {}
        mod_data.TOC[rightForearm].depends_on = {rightHand}
        mod_data.TOC[rightArm].depends_on = { rightHand, rightForearm }
        
        mod_data.TOC[leftHand].depends_on = {}
        mod_data.TOC[leftForearm].depends_on = { leftHand }
        mod_data.TOC[leftArm].depends_on = { leftHand, leftForearm }

        
        -- Setup cicatrization times
        mod_data.TOC[rightHand].cicatrization_base_time = 1700
        mod_data.TOC[leftHand].cicatrization_base_time = 1700
        mod_data.TOC[rightForearm].cicatrization_base_time = 1800
        mod_data.TOC[leftForearm].cicatrization_base_time = 1800
        mod_data.TOC[rightArm].cicatrization_base_time = 2000
        mod_data.TOC[leftArm].cicatrization_base_time = 2000


        -- Traits setup
        if player:HasTrait("amputee1") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noHand")
            player:setWornItem(cloth:getBodyLocation(), cloth)
            mod_data.TOC.LeftHand.is_cut=true; mod_data.TOC.LeftHand.is_operated=true; mod_data.TOC.LeftHand.is_amputation_shown=true; mod_data.TOC.LeftHand.is_cicatrized=true
            player:getInventory():AddItem("TOC.MetalHook")
        end
        if player:HasTrait("amputee2") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noForearm")
            player:setWornItem(cloth:getBodyLocation(), cloth)
            mod_data.TOC.LeftHand.is_cut=true; mod_data.TOC.LeftHand.is_operated=true
            mod_data.TOC.LeftForearm.is_cut=true; mod_data.TOC.LeftForearm.is_operated=true; mod_data.TOC.LeftForearm.is_amputation_shown=true; mod_data.TOC.LeftForearm.is_cicatrized=true
            player:getInventory():AddItem("TOC.MetalHook")
        end
        if player:HasTrait("amputee3") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noArm")
            player:setWornItem(cloth:getBodyLocation(), cloth)
            mod_data.TOC.LeftHand.is_cut=true; mod_data.TOC.LeftHand.is_operated=true
            mod_data.TOC.LeftForearm.is_cut=true; mod_data.TOC.LeftForearm.is_operated=true
            mod_data.TOC.LeftArm.is_cut=true; mod_data.TOC.LeftArm.is_operated=true; mod_data.TOC.LeftArm.is_amputation_shown=true; mod_data.TOC.LeftArm.is_cicatrized=true
            player:getInventory():AddItem("TOC.MetalHook")
        end

        player:transmitModData()
    end
end

function TheOnlyCure.DeclareTraits()
    local amp1 = TraitFactory.addTrait("amputee1", getText("UI_trait_Amputee1"), -8, getText("UI_trait_Amputee1desc"), false, false)
    amp1:addXPBoost(Perks.LeftHand, 4)
    local amp2 = TraitFactory.addTrait("amputee2", getText("UI_trait_Amputee2"), -10, getText("UI_trait_Amputee2desc"), false, false)
    amp2:addXPBoost(Perks.LeftHand, 4)
    local amp3 = TraitFactory.addTrait("amputee3", getText("UI_trait_Amputee3"), -20, getText("UI_trait_Amputee3desc"), false, false)
    amp3:addXPBoost(Perks.LeftHand, 4)
    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false, false)
    TraitFactory.setMutualExclusive("amputee1", "amputee2")
    TraitFactory.setMutualExclusive("amputee1", "amputee3")
    TraitFactory.setMutualExclusive("amputee2", "amputee3")
end




Events.OnCreatePlayer.Add(TheOnlyCure.InitTheOnlyCure)
Events.OnGameBoot.Add(TheOnlyCure.DeclareTraits)