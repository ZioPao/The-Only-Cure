local function operateLocal(partName)
    local player = getPlayer();
    ISTimedActionQueue.add(ISOperateArm:new(player, player, _, partName, true));
end

local function otherPlayerLocal(_, partName, action, patient)
    local ui = GetConfirmUIMP();
    if not ui then 
        MakeConfirmUIMP();
        ui = GetConfirmUIMP();
    end
    if action == "Cut" then
        AskCanCutArm(patient, partName);
    else
        AskCanOperateArm(patient, partName);
    end
    ui.actionAct = action;
    ui.partNameAct = partName;
    ui.patient = patient;
    SetConfirmUIMP("Wait server");
end


local function CheckIfCanBeOperated(modData)
    if modData.TOC.RightHand.IsCut and not modData.RightHand.IsOperated 
    or modData.TOC.RightForeArm.IsCut and not modData.RightForearm.IsOperated 
    or modData.TOC.RightArm.IsCut and not modData.RightArm.IsOperated 
    or modData.TOC.LeftHand.IsCut and not modData.LeftHand.IsOperated
    or modData.TOC.LeftForearm.IsCut and not modData.LeftForearm.IsOperated 
    or modData.TOC.LeftArm.IsCut and not modData.LeftArm.IsOperated then
        return true
    else
        return false
    end

end



local function TOC_onFillWorldObjectContextMenu(playerId, context, worldobjects, _)
    local player = getSpecificPlayer(playerId);
    local clickedPlayer
    local modData = player:getModData();

    for _,object in ipairs(worldobjects) do
        local square = object:getSquare()
        if square then
            for i=1,square:getObjects():size() do
                local object2 = square:getObjects():get(i-1);
                --For the oven operate part


                if CheckIfCanBeOperated(modData) then
                    
       
                    if instanceof(object2, "IsoStove") and (player:HasTrait("Brave") or player:getPerkLevel(Perks.Strength) >= 6) then
                        if not object2:isMicrowave() and object2:getCurrentTemperature() > 250 then
                            local rootMenu = context:addOption(getText('UI_ContextMenu_OperateOven'), worldobjects, nil);
                            local subMenu = context:getNew(context);
                            context:addSubMenu(rootMenu, subMenu)
                            if modData.TOC.RightHand.IsCut and not modData.TOC.RightForearm.IsCut and not modData.TOC.RightHand.IsOperated then
                                subMenu:addOption(getText('UI_ContextMenu_RightHand'), worldobjects, operateLocal, "RightHand");
                            end
                            if modData.TOC.LeftHand.IsCut and not modData.TOC.LeftForearm.IsCut and not modData.TOC.LeftHand.IsOperated then
                                subMenu:addOption(getText('UI_ContextMenu_LeftHand'), worldobjects, operateLocal, "LeftHand");
                            end
                            if modData.TOC.RightForearm.IsCut and not modData.TOC.RightArm.IsCut and not modData.TOC.RightForearm.IsOperated then
                                subMenu:addOption(getText('UI_ContextMenu_RightForearm'), worldobjects, operateLocal, "RightForearm");
                            end
                            if modData.TOC.LeftForearm.IsCut and not modData.TOC.LeftArm.IsCut and not modData.TOC.LeftForearm.IsOperated then
                                subMenu:addOption(getText('UI_ContextMenu_LeftForearm'), worldobjects, operateLocal, "LeftForearm");
                            end
                            if modData.TOC.RightArm.IsCut and not modData.TOC.RightArm.IsOperated then
                                subMenu:addOption(getText('UI_ContextMenu_RightArm'), worldobjects, operateLocal, "RightArm");
                            end
                            if modData.TOC.LeftArm.IsCut and not modData.TOC.LeftArm.IsOperated then
                                subMenu:addOption(getText('UI_ContextMenu_LeftArm'), worldobjects, operateLocal, "LeftArm");
                            end

                            break       -- stop cycling like an idiot
                        end
                    end
                end
            end

            local movingObjects = square:getMovingObjects()
            for i = 0, movingObjects:size() - 1 do
                local o = movingObjects:get(i)
                if instanceof(o, "IsoPlayer") then
                    clickedPlayer = o;
                    break
                end
            end
            if clickedPlayer then
                if not ((-1 < clickedPlayer:getX() - player:getX() and clickedPlayer:getX() - player:getX() < 1) and (-1 < clickedPlayer:getY() - player:getY() and clickedPlayer:getY() - player:getY() < 1)) then
                    return false;
                end
                local rootOption = context:addOption("The Only Cure on " .. clickedPlayer:getUsername());
                local rootMenu = context:getNew(context);
                local cutOption = rootMenu:addOption("Cut");
                local operateOption = rootMenu:addOption("Operate");
                local cutMenu = context:getNew(context);
                local operateMenu = context:getNew(context);

                context:addSubMenu(rootOption, rootMenu);
                context:addSubMenu(cutOption, cutMenu);
                context:addSubMenu(operateOption, operateMenu);

                cutMenu:addOption(getText('UI_ContextMenu_RightHand'), worldobjects, otherPlayerLocal, "RightHand", "Cut", clickedPlayer);
                cutMenu:addOption(getText('UI_ContextMenu_LeftHand'), worldobjects, otherPlayerLocal, "LeftHand", "Cut", clickedPlayer);
                cutMenu:addOption(getText('UI_ContextMenu_RightForearm'), worldobjects, otherPlayerLocal, "RightForearm", "Cut", clickedPlayer);
                cutMenu:addOption(getText('UI_ContextMenu_LeftForearm'), worldobjects, otherPlayerLocal, "LeftForearm", "Cut", clickedPlayer);
                cutMenu:addOption(getText('UI_ContextMenu_RightArm'), worldobjects, otherPlayerLocal, "RightArm", "Cut", clickedPlayer);
                cutMenu:addOption(getText('UI_ContextMenu_LeftArm'), worldobjects, otherPlayerLocal, "LeftArm", "Cut", clickedPlayer);

                operateMenu:addOption(getText('UI_ContextMenu_RightHand'), worldobjects, otherPlayerLocal, "RightHand", "Operate", clickedPlayer);
                operateMenu:addOption(getText('UI_ContextMenu_LeftHand'), worldobjects, otherPlayerLocal, "LeftHand", "Operate", clickedPlayer);
                operateMenu:addOption(getText('UI_ContextMenu_RightForearm'), worldobjects, otherPlayerLocal, "RightForearm", "Operate", clickedPlayer);
                operateMenu:addOption(getText('UI_ContextMenu_LeftForearm'), worldobjects, otherPlayerLocal, "LeftForearm", "Operate", clickedPlayer);
                operateMenu:addOption(getText('UI_ContextMenu_RightArm'), worldobjects, otherPlayerLocal, "RightArm", "Operate", clickedPlayer);
                operateMenu:addOption(getText('UI_ContextMenu_LeftArm'), worldobjects, otherPlayerLocal, "LeftArm", "Operate", clickedPlayer);
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(TOC_onFillWorldObjectContextMenu);