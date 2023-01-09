local function dropItem(player, modData)
    if (modData.TOC.RightHand.IsCut and not (modData.TOC.RightHand.IsEquiped or modData.TOC.RightForearm.IsEquiped)) or (modData.TOC.RightForearm.IsCut and not modData.TOC.RightForearm.IsEquiped) then
        if player:getPrimaryHandItem() ~= nil then
            if player:getPrimaryHandItem():getName() ~= "Bare Hands" then player:dropHandItems() end
        end
    end
    if (modData.TOC.LeftHand.IsCut and not (modData.TOC.LeftHand.IsEquiped or modData.TOC.LeftForearm.IsEquiped)) or (modData.TOC.LeftForearm.IsCut and not modData.TOC.LeftForearm.IsEquiped) then
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
        if modData.TOC.RightHand.IsEquiped  or modData.TOC.RightForearm.IsEquiped   then player:getXp():AddXP(Perks.RightHand, 4) end
        if modData.TOC.LeftHand.IsEquiped   or modData.TOC.LeftForearm.IsEquiped    then player:getXp():AddXP(Perks.LeftHand, 4) end

        --Reduit le temps de cicatri restant
        for i,name in pairs(names) do
            if modData.TOC[name].IsCut and not modData.TOC[name].IsCicatrized then
                modData.TOC[name].CicaTimeLeft = modData.TOC[name].CicaTimeLeft - 1;
                player:transmitModData()
            end
        end
    end
end

local function initVariable(_, player)
    local modData = player:getModData()
    if modData.TOC == nil then
        modData.TOC = {};
        modData.TOC.RightHand = {};
        modData.TOC.RightForearm = {};
        modData.TOC.RightArm = {};
        modData.TOC.LeftHand = {};
        modData.TOC.LeftForearm = {};
        modData.TOC.LeftArm = {};

        modData.TOC.RightHand.IsCut = false;
        modData.TOC.RightForearm.IsCut = false;
        modData.TOC.RightArm.IsCut = false;
        modData.TOC.LeftHand.IsCut = false;
        modData.TOC.LeftForearm.IsCut = false;
        modData.TOC.LeftArm.IsCut = false;

        modData.TOC.RightHand.IsInfected = false;
        modData.TOC.RightForearm.IsInfected = false;
        modData.TOC.RightArm.IsInfected = false;
        modData.TOC.LeftHand.IsInfected = false;
        modData.TOC.LeftForearm.IsInfected = false;
        modData.TOC.LeftArm.IsInfected = false;

        modData.TOC.RightHand.IsOperated = false;
        modData.TOC.RightForearm.IsOperated = false;
        modData.TOC.RightArm.IsOperated = false;
        modData.TOC.LeftHand.IsOperated = false;
        modData.TOC.LeftForearm.IsOperated = false;
        modData.TOC.LeftArm.IsOperated = false;

        modData.TOC.RightHand.IsCicatrized = false;
        modData.TOC.RightForearm.IsCicatrized = false;
        modData.TOC.RightArm.IsCicatrized = false;
        modData.TOC.LeftHand.IsCicatrized = false;
        modData.TOC.LeftForearm.IsCicatrized = false;
        modData.TOC.LeftArm.IsCicatrized = false;

        modData.TOC.RightHand.IsEquiped = false;
        modData.TOC.RightForearm.IsEquiped = false;
        modData.TOC.RightArm.IsEquiped = false;
        modData.TOC.LeftHand.IsEquiped = false;
        modData.TOC.LeftForearm.IsEquiped = false;
        modData.TOC.LeftArm.IsEquiped = false;

        modData.TOC.RightHand.IsBurn = false;
        modData.TOC.RightForearm.IsBurn = false;
        modData.TOC.RightArm.IsBurn = false;
        modData.TOC.LeftHand.IsBurn = false;
        modData.TOC.LeftForearm.IsBurn = false;
        modData.TOC.LeftArm.IsBurn = false;

        modData.TOC.RightHand.EquipFact = 1.0;
        modData.TOC.RightForearm.EquipFact = 1.0;
        modData.TOC.RightArm.EquipFact = 1.0;
        modData.TOC.LeftHand.EquipFact = 1.0;
        modData.TOC.LeftForearm.EquipFact = 1.0;
        modData.TOC.LeftArm.EquipFact = 1.0;

        modData.TOC.RightHand.Equip_mat_id = nil;
        modData.TOC.RightForearm.Equip_mat_id = nil;
        modData.TOC.RightArm.Equip_mat_id = nil;
        modData.TOC.LeftHand.Equip_mat_id = nil;
        modData.TOC.LeftForearm.Equip_mat_id = nil;
        modData.TOC.LeftArm.Equip_mat_id = nil;

        modData.TOC.RightHand.CicaTimeLeft = 0;
        modData.TOC.RightForearm.CicaTimeLeft = 0;
        modData.TOC.RightArm.CicaTimeLeft = 0;
        modData.TOC.LeftHand.CicaTimeLeft = 0;
        modData.TOC.LeftForearm.CicaTimeLeft = 0;
        modData.TOC.LeftArm.CicaTimeLeft = 0;

        modData.TOC.RightHand.ToDisplay = false;
        modData.TOC.RightForearm.ToDisplay = false;
        modData.TOC.RightArm.ToDisplay = false;
        modData.TOC.LeftHand.ToDisplay = false;
        modData.TOC.LeftForearm.ToDisplay = false;
        modData.TOC.LeftArm.ToDisplay = false;

        modData.TOC.InitDone = true;
        modData.TOC.OtherBody_IsInfected = false;

        if player:HasTrait("amputee1") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noHand");
            player:setWornItem(cloth:getBodyLocation(), cloth);
            modData.TOC.LeftHand.IsCut=true; modData.TOC.LeftHand.IsOperated=true; modData.TOC.LeftHand.ToDisplay=true; modData.TOC.LeftHand.IsCicatrized=true;
            player:getInventory():AddItem("TOC.MetalHook");
        end
        if player:HasTrait("amputee2") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noForearm");
            player:setWornItem(cloth:getBodyLocation(), cloth);
            modData.TOC.LeftHand.IsCut=true; modData.TOC.LeftHand.IsOperated=true;
            modData.TOC.LeftForearm.IsCut=true; modData.TOC.LeftForearm.IsOperated=true; modData.TOC.LeftForearm.ToDisplay=true; modData.TOC.LeftForearm.IsCicatrized=true;
            player:getInventory():AddItem("TOC.MetalHook");
        end
        if player:HasTrait("amputee3") then
            local cloth = player:getInventory():AddItem("TOC.ArmLeft_noArm");
            player:setWornItem(cloth:getBodyLocation(), cloth);
            modData.TOC.LeftHand.IsCut=true; modData.TOC.LeftHand.IsOperated=true;
            modData.TOC.LeftForearm.IsCut=true; modData.TOC.LeftForearm.IsOperated=true;
            modData.TOC.LeftArm.IsCut=true; modData.TOC.LeftArm.IsOperated=true; modData.TOC.LeftArm.ToDisplay=true; modData.TOC.LeftArm.IsCicatrized=true;
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