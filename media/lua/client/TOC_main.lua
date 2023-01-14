if not TheOnlyCure then
    TheOnlyCure = {}
end


-- TODO this is gonna break a lot of stuff, don't do this you ass
-- GLOBAL STRINGS




-- TODO Unify Context Menus check with TOC Menu UI 


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
            
            
            mod_data.TOC[v].is_prosthesis_equipped = false
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


-----------------------------------------------------------------------
function TheOnlyCure.CutLimb(part_name, surgeon_factor, bandage_table, painkiller_table)

    -- TODO Check if this works in MP through MENU UI
    local player = getPlayer()
    local toc_data = player:getModData().TOC
    local body_part_type = player:getBodyDamage():getBodyPart(TheOnlyCure.GetBodyPartTypeFromBodyPart(part_name))
    local stats = player:getStats();

    -- Set damage, stress, and low endurance after amputation
    body_part_type:AddDamage(100 - surgeon_factor)
    body_part_type:setAdditionalPain(100 - surgeon_factor)
    body_part_type:setBleeding(true)
    body_part_type:setBleedingTime(100 - surgeon_factor)
    body_part_type:setDeepWounded(true)
    body_part_type:setDeepWoundTime(100 - surgeon_factor)
    stats:setEndurance(surgeon_factor)
    stats:setStress(100 - surgeon_factor)

    -- If bandages are available, use them
    body_part_type:setBandaged(bandage_table.use_bandage, 10, bandage_table.is_bandage_sterilized, bandage_table.bandage_type)



    -- If painkillers are available, use them
    -- ...


    -- Remove object in hand
    -- TODO do this

    if toc_data[part_name].is_cut == false then
        toc_data[part_name].is_cut = true
        toc_data[part_name].is_amputation_shown = true
        toc_data[part_name].cicatrization_time = toc_data[part_name].cicatrization_base_time - surgeon_factor * 50
        
        -- Heal the infection here
        local body_damage = player:getBodyDamage()
        if toc_data[part_name].is_infected and body_damage.getInfectionLevel() < 20 then
            toc_data[part_name].is_infected = false
            body_part_type:SetBitten(false)

            -- Second check, let's see if there is any other infected limb.
            if CheckIfStillInfected(toc_data) == false then
                CureInfection(body_damage)
                getPlayer():Say("I'm gonna be fine")
            else
                getPlayer():Say("I'm still gonna die...")
            end
        end

        -- Cut the depended part
        for _, depended_v in pairs(toc_data[part_name].depends_on) do
            toc_data[depended_v].is_cut = true
            toc_data[depended_v].is_amputation_shown = false        -- TODO why was it true before?
            toc_data[depended_v].cicatrization_time = toc_data[part_name].cicatrization_base_time - surgeon_factor * 50
        end

        --Equip model for amputation
        local cloth = player:getInventory():AddItem(find_clothName2_TOC(part_name))
        player:setWornItem(cloth:getBodyLocation(), cloth)
        player:transmitModData()

    end




end

function TheOnlyCure.OperateLimb(part_name, surgeon_factor, use_oven)

    local player = getPlayer()
    local toc_data = player:getModData().TOC

    if use_oven then
        local stats = player:getStats()
        stats:setEndurance(100)
        stats:setStress(100)
    end

    if toc_data[part_name].is_operated == false and toc_data[part_name].is_cut == true then
        toc_data[part_name].is_operated = true
        toc_data[part_name].cicatrization_time = toc_data[part_name].cicatrization_time - (surgeon_factor * 200)
        if use_oven then toc_data[part_name].is_cauterized = true end
        for _, depended_v in pairs(toc_data[part_name].depends_on) do
            toc_data[depended_v].is_operated = true
            toc_data[depended_v].cicatrization_time = toc_data[depended_v].cicatrization_time - (surgeon_factor * 200)
            if use_oven then toc_data[depended_v].is_cauterized = true end      -- TODO does this make sense?

        end

    end

    SetBodyPartsStatusAfterOperation(player, toc_data, part_name, use_oven)
    player:transmitModData()
end



Events.OnCreatePlayer.Add(TheOnlyCure.InitTheOnlyCure)
Events.OnGameBoot.Add(TheOnlyCure.DeclareTraits)