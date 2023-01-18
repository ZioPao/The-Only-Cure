if not TheOnlyCure then
    TheOnlyCure = {}
end


-- TODO remove this crap
Left = "Left"
Right = "Right"

Hand = "Hand"
Forearm = "Forearm"
Arm = "Arm"

function TheOnlyCure.InitTheOnlyCure(_, player)

    local mod_data = player:getModData()

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
                mod_data.TOC.Limbs[part_name].equipped_prosthesis = {}

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

function TheOnlyCure.DeclareTraits()
    local amp1 = TraitFactory.addTrait("Amputee_Hand", getText("UI_trait_Amputee_Hand"), -8, getText("UI_trait_Amputee_Hand_desc"), false, false)
    amp1:addXPBoost(Perks.Left_Hand, 4)

    local amp2 = TraitFactory.addTrait("Amputee_LowerArm", getText("UI_trait_Amputee_LowerArm"), -10, getText("UI_trait_Amputee_LowerArm_desc"), false, false)
    amp2:addXPBoost(Perks.Left_Hand, 4)

    local amp3 = TraitFactory.addTrait("Amputee_UpperArm", getText("UI_trait_Amputee_UpperArm"), -20, getText("UI_trait_Amputee_UpperArm_desc"), false, false)
    amp3:addXPBoost(Perks.Left_Hand, 4)

    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false, false)
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_LowerArm")
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_UpperArm")
    TraitFactory.setMutualExclusive("Amputee_LowerArm", "Amputee_UpperArm")
end


-----------------------------------------------------------------------
function TheOnlyCure.CutLimb(part_name, surgeon_factor, bandage_table, painkiller_table)

    -- TODO Check if this works in MP through MENU UI
    local player = getPlayer()
    local toc_data = player:getModData().TOC
    local body_part_type = player:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromBodyPart(part_name))
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
        local cloth = player:getInventory():AddItem(TocFindAmputatedClothingFromPartName(part_name))
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

function TryTocAction(_, part_name, action, surgeon, patient)
    -- TODO add checks so that we don't show these menus if a player has already beeen operated or amputated
    -- TODO at this point surgeon doesnt do anything. We'll fix this later

    -- Check if SinglePlayer
    if not isServer() and not isClient() then
        
        if action == "Cut" then
            TocCutLocal(_, surgeon, surgeon, part_name)
        elseif action == "Operate" then
            TocOperateLocal(_, surgeon, surgeon, part_name, false)
        elseif action == "Equip" then
            -- TODO finish this
            local item
            TocEquipProsthesisLocal(_, surgeon, surgeon, part_name)
        elseif action == "Unequip" then
            -- TODO finish this
            local item
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
            local surgeon_inventory = surgeon:getInventory()
            local prosthesis_to_equip = surgeon_inventory:getItemFromType('TOC.MetalHand') or 
                        surgeon_inventory:getItemFromType('TOC.MetalHook') or 
                        surgeon_inventory:getItemFromType('TOC.WoodenHook')
            if prosthesis_to_equip then
                ISTimedActionQueue.add(ISInstallProsthesis:new(patient, prosthesis_to_equip, patient:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromBodyPart(part_name))))
            else
                surgeon:Say("I need a prosthesis")
            end



            --AskCanEquipProsthesis(patient, part_name, item)

        elseif action == "Unequip" then
            --AskCanUnequipProsthesis(patient, part_name)
            local equipped_prosthesis = FindTocItemWorn(part_name, patient)
            ISTimedActionQueue.add(ISUninstallProsthesis:new(patient, equipped_prosthesis, patient:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromBodyPart(part_name))))
        end
        ui.actionAct = action
        ui.partNameAct = part_name
        ui.patient = patient

        --TODO just a workaround for now
        if action ~= "Equip" and action ~= "Unequip" then
            SendCommandToConfirmUIMP("Wait server")
        end
    end
end


Events.OnCreatePlayer.Add(TheOnlyCure.InitTheOnlyCure)
Events.OnGameBoot.Add(TheOnlyCure.DeclareTraits)