if not TheOnlyCure then
    TheOnlyCure = {}
end



local function dropItem(player, modData)
    if (modData.TOC.RightHand.is_cut and not (modData.TOC.RightHand.has_prothesis_equipped or modData.TOC.RightForearm.has_prothesis_equipped)) or (modData.TOC.RightForearm.is_cut and not modData.TOC.RightForearm.has_prothesis_equipped) then
        if player:getPrimaryHandItem() ~= nil then
            if player:getPrimaryHandItem():getName() ~= "Bare Hands" then player:dropHandItems() end
        end
    end
    if (modData.TOC.LeftHand.is_cut and not (modData.TOC.LeftHand.has_prothesis_equipped or modData.TOC.LeftForearm.has_prothesis_equipped)) or (modData.TOC.LeftForearm.is_cut and not modData.TOC.LeftForearm.has_prothesis_equipped) then
        if player:getSecondaryHandItem() ~= nil then
            if player:getSecondaryHandItem():getName() ~= "Bare Hands" then player:dropHandItems() end
        end
    end
end

local function everyOneMinute()
    local player = getPlayer();
    local modData = player:getModData();
    if modData.TOC ~= nil then
        dropItem(player, modData);
        CheckIfInfect(player, modData);
        UpdatePlayerHealth(player, modData);
    end
end

local function everyTenMinutes()
    local player = getPlayer()
    local modData = player:getModData()
    if modData.TOC ~= nil then
        local names = {"RightHand", "RightForearm", "RightArm", "LeftHand", "LeftForearm", "LeftArm"}

        --Augmente l'xp si equip
        if modData.TOC.RightHand.has_prothesis_equipped  or modData.TOC.RightForearm.has_prothesis_equipped   then player:getXp():AddXP(Perks.RightHand, 4) end
        if modData.TOC.LeftHand.has_prothesis_equipped   or modData.TOC.LeftForearm.has_prothesis_equipped    then player:getXp():AddXP(Perks.LeftHand, 4) end

        --Reduit le temps de cicatri restant
        for i,name in pairs(names) do
            if modData.TOC[name].is_cut and not modData.TOC[name].is_cicatrized then
                modData.TOC[name].cicatrization_time = modData.TOC[name].cicatrization_time - 1;
                player:transmitModData()
            end
        end
    end
end

local function initVariable(_, player)
    local modData = player:getModData()
    if modData.TOC == nil then

        -- https://stackoverflow.com/questions/20915164/lua-loop-for-creating-variables-in-table

        
        local rightHand = "RightHand"
        local rightForearm = "RightForearm"
        local rightArm = "RightArm"

        local leftHand = "LeftHand"
        local leftForearm = "LeftForearm"
        local leftArm = "LeftArm"



        
        modData.TOC = {
            RightHand = {},
            RightForearm = {},
            RightArm = {},

            LeftHand = {},
            LeftForearm = {},
            LeftArm = {}
        }

        for k,v in pairs(GetBodyParts()) do
            modData.TOC[v].is_cut = false
            modData.TOC[v].is_infected = false
            modData.TOC[v].is_operated = false
            modData.TOC[v].is_cicatrized = false
            modData.TOC[v].is_cauterized = false
            modData.TOC[v].is_amputation_shown = false

            modData.TOC[v].cicatrization_time = 0
            
            
            modData.TOC[v].has_prothesis_equipped = false
            modData.TOC[v].prothesis_factor = 1.0       -- Every prothesis has the same... does this even make sense here?
            modData.TOC[v].prothesis_material_id = nil           
        end


        -- Manual stuff, just a temporary fix since this is kinda awful
        modData.TOC[rightHand].depends_on = {}
        modData.TOC[rightForearm].depends_on = {rightHand}
        modData.TOC[rightArm].depends_on = { rightHand, rightForearm }
        
        modData.TOC[leftHand].depends_on = {}
        modData.TOC[leftForearm].depends_on = { leftHand }
        modData.TOC[leftArm].depends_on = { leftHand, leftForearm }

        
        -- Setup cicatrization times
        modData.TOC[rightHand].cicatrization_base_time = 1700
        modData.TOC[leftHand].cicatrization_base_time = 1700
        modData.TOC[rightForearm].cicatrization_base_time = 1800
        modData.TOC[leftForearm].cicatrization_base_time = 1800
        modData.TOC[rightArm].cicatrization_base_time = 2000
        modData.TOC[leftArm].cicatrization_base_time = 2000




        if player:HasTrait("amputee1") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noHand");
            player:setWornItem(cloth:getBodyLocation(), cloth);
            modData.TOC.LeftHand.is_cut=true; modData.TOC.LeftHand.is_operated=true; modData.TOC.LeftHand.is_amputation_shown=true; modData.TOC.LeftHand.is_cicatrized=true;
            player:getInventory():AddItem("TOC.MetalHook");
        end
        if player:HasTrait("amputee2") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noForearm");
            player:setWornItem(cloth:getBodyLocation(), cloth);
            modData.TOC.LeftHand.is_cut=true; modData.TOC.LeftHand.is_operated=true;
            modData.TOC.LeftForearm.is_cut=true; modData.TOC.LeftForearm.is_operated=true; modData.TOC.LeftForearm.is_amputation_shown=true; modData.TOC.LeftForearm.is_cicatrized=true;
            player:getInventory():AddItem("TOC.MetalHook");
        end
        if player:HasTrait("amputee3") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noArm");
            player:setWornItem(cloth:getBodyLocation(), cloth);
            modData.TOC.LeftHand.is_cut=true; modData.TOC.LeftHand.is_operated=true;
            modData.TOC.LeftForearm.is_cut=true; modData.TOC.LeftForearm.is_operated=true;
            modData.TOC.LeftArm.is_cut=true; modData.TOC.LeftArm.is_operated=true; modData.TOC.LeftArm.is_amputation_shown=true; modData.TOC.LeftArm.is_cicatrized=true;
            player:getInventory():AddItem("TOC.MetalHook");
        end

        player:transmitModData()
    end
end

local function initTOCTraits()
    local amp1 = TraitFactory.addTrait("amputee1", getText("UI_trait_Amputee1"), -8, getText("UI_trait_Amputee1desc"), false, false);
    amp1:addXPBoost(Perks.LeftHand, 4);
    local amp2 = TraitFactory.addTrait("amputee2", getText("UI_trait_Amputee2"), -10, getText("UI_trait_Amputee2desc"), false, false);
    amp2:addXPBoost(Perks.LeftHand, 4);
    local amp3 = TraitFactory.addTrait("amputee3", getText("UI_trait_Amputee3"), -20, getText("UI_trait_Amputee3desc"), false, false);
    amp3:addXPBoost(Perks.LeftHand, 4);
    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false, false);
    TraitFactory.setMutualExclusive("amputee1", "amputee2");
    TraitFactory.setMutualExclusive("amputee1", "amputee3");
    TraitFactory.setMutualExclusive("amputee2", "amputee3");
end

Events.EveryHours.Add(everyHours);
Events.EveryTenMinutes.Add(everyTenMinutes);
Events.EveryOneMinute.Add(everyOneMinute);
Events.OnCreatePlayer.Add(initVariable);
Events.OnGameBoot.Add(initTOCTraits);