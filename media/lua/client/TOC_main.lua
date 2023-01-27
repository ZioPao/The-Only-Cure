if not TheOnlyCure then
    TheOnlyCure = {}
end

TOC_sides = { "Left", "Right" }
TOC_limbs = { "Hand", "LowerArm", "UpperArm" }


function TheOnlyCure.InitTheOnlyCure(_, player)

    local mod_data = player:getModData()
    if mod_data.TOC == nil then
        TocSetInitData(mod_data, player)
    else
        TocCheckCompatibilityWithOlderVersions(mod_data)
        TocUpdateBaseData(mod_data) -- Since it's gonna be common to update stuff
    end

end

function TocSetInitData(mod_data, player)

    print("TOC: Creating mod_data.TOC")

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

        local amputation_clothing_item = player:getInventory():AddItem("TOC.Amputation_Left_Hand")
        TocSetCorrectTextureForAmputation(amputation_clothing_item, player)

        player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)
        mod_data.TOC.Limbs.Left_Hand.is_cut = true
        mod_data.TOC.Limbs.Left_Hand.is_operated = true
        mod_data.TOC.Limbs.Left_Hand.is_amputation_shown = true
        mod_data.TOC.Limbs.Left_Hand.is_cicatrized = true
    elseif player:HasTrait("Amputee_LowerArm") then
        local amputation_clothing_item = player:getInventory():AddItem("TOC.Amputation_Left_LowerArm")
        TocSetCorrectTextureForAmputation(amputation_clothing_item, player)

        player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)
        mod_data.TOC.Limbs.Left_LowerArm.is_cut = true
        mod_data.TOC.Limbs.Left_LowerArm.is_operated = true
        mod_data.TOC.Limbs.Left_LowerArm.is_amputation_shown = true
        mod_data.TOC.Limbs.Left_LowerArm.is_cicatrized = true
    elseif player:HasTrait("Amputee_UpperArm") then
        local amputation_clothing_item = player:getInventory():AddItem("TOC.Amputation_Left_UpperArm")
        TocSetCorrectTextureForAmputation(amputation_clothing_item, player)

        player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)
        mod_data.TOC.Limbs.Left_UpperArm.is_cut = true
        mod_data.TOC.Limbs.Left_UpperArm.is_operated = true
        mod_data.TOC.Limbs.Left_UpperArm.is_amputation_shown = true
        mod_data.TOC.Limbs.Left_UpperArm.is_cicatrized = true
    end




end

function TocUpdateBaseData(mod_data)

    local prosthesis_list = { "WoodenHook", "MetalHook", "MetalHand" }



    local accepted_prosthesis_hand = { "WoodenHook", "MetalHook", "MetalHand" }
    local accepted_prosthesis_lowerarm = { "WoodenHook", "MetalHook", "MetalHand" }
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


            elseif limb == "LowerArm" then
                mod_data.TOC.Limbs[part_name].cicatrization_base_time = 1800
                mod_data.TOC.Limbs[part_name].depends_on = { side .. "_Hand", }
                mod_data.TOC.Prosthesis.Accepted_Prosthesis[part_name] = accepted_prosthesis_lowerarm

                mod_data.TOC.Prosthesis["WoodenHook"][part_name].prosthesis_factor = 1.35
                mod_data.TOC.Prosthesis["MetalHook"][part_name].prosthesis_factor = 1.25
                mod_data.TOC.Prosthesis["MetalHand"][part_name].prosthesis_factor = 1.15
            elseif limb == "UpperArm" then
                mod_data.TOC.Limbs[part_name].cicatrization_base_time = 2000
                mod_data.TOC.Limbs[part_name].depends_on = { side .. "_Hand", side .. "_LowerArm", }
                mod_data.TOC.Prosthesis.Accepted_Prosthesis[part_name] = accepted_prosthesis_upperarm
            end

        end
    end




end

function TheOnlyCure.DeclareTraits()
    local amp1 = TraitFactory.addTrait("Amputee_Hand", getText("UI_trait_Amputee_Hand"), -8,
        getText("UI_trait_Amputee_Hand_desc"), false, false)
    amp1:addXPBoost(Perks.Left_Hand, 4)

    local amp2 = TraitFactory.addTrait("Amputee_LowerArm", getText("UI_trait_Amputee_LowerArm"), -10,
        getText("UI_trait_Amputee_LowerArm_desc"), false, false)
    amp2:addXPBoost(Perks.Left_Hand, 4)

    local amp3 = TraitFactory.addTrait("Amputee_UpperArm", getText("UI_trait_Amputee_UpperArm"), -20,
        getText("UI_trait_Amputee_UpperArm_desc"), false, false)
    amp3:addXPBoost(Perks.Left_Hand, 4)

    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false,
        false)
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_LowerArm")
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_UpperArm")
    TraitFactory.setMutualExclusive("Amputee_LowerArm", "Amputee_UpperArm")
end

-----------------------------------------------------------------------
function TheOnlyCure.CutLimb(part_name, surgeon_factor, bandage_table, painkiller_table)

    -- TODO Separate Cut Limb in side and limb instead of single part_name

    -- Items get unequipped in ISCutLimb.Start

    local player = getPlayer()
    local toc_data = player:getModData().TOC
    local limbs_data = toc_data.Limbs



    -- TODO Stop for a bit,

    -- Cut Hand -> Damage in forearm
    -- Cut Forearm -> Damage in Upperarm
    -- Cut UpperArm -> Damage to torso

    local body_damage = player:getBodyDamage()
    local body_part = body_damage:getBodyPart(TocGetBodyPartFromPartName(part_name))
    local adiacent_body_part = player:getBodyDamage():getBodyPart(TocGetAdiacentBodyPartFromPartName(part_name))

    local stats = player:getStats()



    -- Reset the status of the first body part, since we just cut it off it shouldn't be bleeding anymore
    -- The bit will be checked later since we're not sure if the player is not infected from another wound
    TocSetParametersForMissingLimb(body_part, false)

    -- Set damage, stress, and low endurance after amputation
    adiacent_body_part:AddDamage(100 - surgeon_factor)
    adiacent_body_part:setAdditionalPain(100 - surgeon_factor)
    adiacent_body_part:setBleeding(true)
    adiacent_body_part:setBleedingTime(100 - surgeon_factor)
    adiacent_body_part:setDeepWounded(true)
    adiacent_body_part:setDeepWoundTime(100 - surgeon_factor)
    stats:setEndurance(surgeon_factor)
    stats:setStress(100 - surgeon_factor)


    -- Set malus for strength and fitness
    player:LoseLevel(Perks.Fitness)
    player:LoseLevel(Perks.Strength)



    -- If bandages are available, use them
    adiacent_body_part:setBandaged(bandage_table.use_bandage, 10, bandage_table.is_bandage_sterilized, bandage_table.bandage_type)



    -- If painkillers are available, use them
    -- TODO add painkiller support

    -- Use a tourniquet if available
    -- TODO add tourniquet

    if limbs_data[part_name].is_cut == false then
        limbs_data[part_name].is_cut = true
        limbs_data[part_name].is_amputation_shown = true
        limbs_data[part_name].cicatrization_time = limbs_data[part_name].cicatrization_base_time - surgeon_factor * 50

        for _, depended_v in pairs(limbs_data[part_name].depends_on) do
            if limbs_data[depended_v].is_cut == false then
                limbs_data[depended_v].is_cut = true
                limbs_data[depended_v].is_amputation_shown = false
                limbs_data[depended_v].cicatrization_time = limbs_data[part_name].cicatrization_base_time -
                    surgeon_factor * 50

                local should_depended_v_be_healed_of_bite = limbs_data[depended_v].is_infected and body_damage:getInfectionLevel() < 20
                local depended_body_part = body_damage:getBodyPart(TocGetBodyPartFromPartName(depended_v))
                TocSetParametersForMissingLimb(depended_body_part, should_depended_v_be_healed_of_bite)

                if should_depended_v_be_healed_of_bite then
                    limbs_data[depended_v].is_infected = false
                end


            end
         end


        -- Heal the infection here
        local body_damage = player:getBodyDamage()
        if limbs_data[part_name].is_infected and body_damage:getInfectionLevel() < 20 then
            limbs_data[part_name].is_infected = false

            -- NOT THE ADIACENT ONE!!!
            body_part:SetBitten(false)
            body_part:setBiteTime(0)

            -- Second check, let's see if there is any other infected limb.
            if TocCheckIfStillInfected(limbs_data) == false then
                TocCureInfection(body_damage, part_name)
                getPlayer():Say("I'm gonna be fine...")
            else
                getPlayer():Say("I'm still gonna die...")
            end
        end



        -- Check for older amputation models and deletes them from player's inventory
        local side = string.match(part_name, '(%w+)_')
        TocDeleteOtherAmputatedLimbs(side)

        --Equip new model for amputation
        local amputation_clothing_item = player:getInventory():AddItem(TocFindAmputatedClothingFromPartName(part_name))
        TocSetCorrectTextureForAmputation(amputation_clothing_item, player)
        player:setWornItem(amputation_clothing_item:getBodyLocation(), amputation_clothing_item)


        -- Set blood on the amputated limb
        TocSetBloodOnAmputation(getPlayer(), adiacent_body_part)
    end




end

function TocOperateLimb(part_name, surgeon_factor, use_oven)

    local player = getPlayer()
    local limbs_data = player:getModData().TOC.Limbs

    if use_oven then
        local stats = player:getStats()
        stats:setEndurance(100)
        stats:setStress(100)
    end

    if limbs_data[part_name].is_operated == false and limbs_data[part_name].is_cut == true then
        limbs_data[part_name].is_operated = true
        limbs_data[part_name].cicatrization_time = limbs_data[part_name].cicatrization_time - (surgeon_factor * 200)
        if use_oven then limbs_data[part_name].is_cauterized = true end
        for _, depended_v in pairs(limbs_data[part_name].depends_on) do
            limbs_data[depended_v].is_operated = true
            limbs_data[depended_v].cicatrization_time = limbs_data[depended_v].cicatrization_time -
                (surgeon_factor * 200)
            if use_oven then limbs_data[depended_v].is_cauterized = true end -- TODO does this make sense?

        end

    end

    SetBodyPartsStatusAfterOperation(player, limbs_data, part_name, use_oven)
end

function TheOnlyCure.EquipProsthesis(part_name, prosthesis_base_name)
    local player = getPlayer()

    local toc_data = player:getModData().TOC

    local prosthesis_name = TocFindCorrectClothingProsthesis(prosthesis_base_name, part_name)
    local added_prosthesis = player:getInventory():AddItem(prosthesis_name)

    if part_name ~= nil then

        if added_prosthesis ~= nil then
            toc_data.Limbs[part_name].is_prosthesis_equipped = true
            toc_data.Limbs[part_name].equipped_prosthesis = toc_data.Prosthesis[prosthesis_base_name][part_name]

            if player:isFemale() then
                added_prosthesis:getVisual():setTextureChoice(1)
            else
                added_prosthesis:getVisual():setTextureChoice(0)
            end
            player:setWornItem(added_prosthesis:getBodyLocation(), added_prosthesis)



        end
    end





end

function TheOnlyCure.UnequipProsthesis(part_name, equipped_prosthesis)
    local player = getPlayer()

    local toc_data = player:getModData().TOC


    -- we've got equipped_prosthesis, so we should be able to get it directly
    toc_data.Limbs[part_name].is_prosthesis_equipped = false
    local equipped_prosthesis_full_type = equipped_prosthesis:getFullType()


    for _, prost_v in ipairs(GetProsthesisList()) do
        local prosthesis_name = string.match(equipped_prosthesis_full_type, prost_v)
        if prosthesis_name then
            player:getInventory():AddItem("TOC." .. prosthesis_name)
            player:setWornItem(equipped_prosthesis:getBodyLocation(), nil)
            player:getInventory():Remove(equipped_prosthesis)
        end

    end


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
