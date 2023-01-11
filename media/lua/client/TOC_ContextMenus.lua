
local function operateLocal(worldobjects, partName)
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
    if modData.TOC.RightHand.is_cut and not modData.TOC.RightHand.is_operated
    or modData.TOC.RightForearm.is_cut and not modData.TOC.RightForearm.is_operated
    or modData.TOC.RightArm.is_cut and not modData.TOC.RightArm.is_operated
    or modData.TOC.LeftHand.is_cut and not modData.TOC.LeftHand.is_operated
    or modData.TOC.LeftForearm.is_cut and not modData.TOC.LeftForearm.is_operated
    or modData.TOC.LeftArm.is_cut and not modData.TOC.LeftArm.is_operated then
        return true
    else
        return false
    end

end






-- why local?
function ISWorldObjectContextMenu.OnFillOperateWithOven(player, context, worldObjects, test)
    local player_obj = getSpecificPlayer(player)
    --local clickedPlayer
    local modData = player_obj:getModData()

    local is_main_menu_already_created = false


    --local props = v:getSprite() and v:getSprite():getProperties() or nil

    for k_stove, v_stove in pairs(worldObjects) do
        if instanceof(v_stove, "IsoStove") and (player_obj:HasTrait("Brave") or player_obj:getPerkLevel(Perks.Strength) >= 6) then

            -- Check temperature
            if v_stove:getCurrentTemperature() > 250 then
                
                for k_bodypart, v_bodypart in ipairs(GetBodyParts()) do
                    if modData.TOC[v_bodypart].is_cut and not modData.TOC[v_bodypart].is_operated then
                        local subMenu = context:getNew(context);

                        if is_main_menu_already_created == false then
                            local rootMenu = context:addOption(getText('UI_ContextMenu_OperateOven'), worldObjects, nil);
                            context:addSubMenu(rootMenu, subMenu)
                            is_main_menu_already_created = true
                        end
                        subMenu:addOption(getText('UI_ContextMenu_' .. v_bodypart), worldObjects, operateLocal, v_bodypart)
                    end
                end
            end

            break   -- stop searching for stoves

        end

    end
end




        -- if instanceof(vtest, "IsoStove") and (player_obj:HasTrait("Brave") or player_obj:getPerkLevel(Perks.Strength) >= 6) then
        --     --if v:getCurrentTemperature() > 250 then
        --         local rootMenu = context:addOption(getText('UI_ContextMenu_OperateOven'), worldObjects, nil);
        --         local subMenu = context:getNew(context);
        --         context:addSubMenu(rootMenu, subMenu)

        --         for k_bodypart, v_bodypart in pairs(GetBodyParts()) do
        --             -- todo this is awful but it should work
        --             if modData.TOC[v_bodypart].is_cut and not modData.TOC[v_bodypart].is_operated then
        --                 subMenu:addOption(getText('UI_ContextMenu_' .. v_bodypart), worldObjects, operateLocal, v_bodypart);

        --             end


        --         end
        --     --end
        -- end







    -- for _,object in ipairs(worldobjects) do
    --     local square = object:getSquare()
    --     if square then
    --         for i=1,square:getObjects():size() do
    --             local object2 = square:getObjects():get(i-1);
    --             --For the oven operate part


    --             if CheckIfCanBeOperated(modData) then
                    
       
    --                 if instanceof(object2, "IsoStove") and (player:HasTrait("Brave") or player:getPerkLevel(Perks.Strength) >= 6) then
    --                     if not object2:isMicrowave() and object2:getCurrentTemperature() > 250 then
    --                         local rootMenu = context:addOption(getText('UI_ContextMenu_OperateOven'), worldobjects, nil);
    --                         local subMenu = context:getNew(context);
    --                         context:addSubMenu(rootMenu, subMenu)

    --                         for k, v in pairs(GetBodyParts()) do
    --                             -- todo this is awful but it should work
    --                             if modData.TOC[v].is_cut and not modData.TOC[v].is_operated then
    --                                 subMenu:addOption(getText('UI_ContextMenu_' .. v), worldobjects, operateLocal, v);

    --                             end


    --                         end


    --                     end
    --                 end
    --             end
    --         end

    --         local movingObjects = square:getMovingObjects()
    --         for i = 0, movingObjects:size() - 1 do
    --             local o = movingObjects:get(i)
    --             if instanceof(o, "IsoPlayer") then
    --                 clickedPlayer = o;
    --                 break
    --             end
    --         end
    --         if clickedPlayer then
    --             -- Pretty sure this check is kinda broken
    --             if not ((-1 < clickedPlayer:getX() - player:getX() and clickedPlayer:getX() - player:getX() < 1) and (-1 < clickedPlayer:getY() - player:getY() and clickedPlayer:getY() - player:getY() < 1)) then
    --                 return false;
    --             end
    --             local rootOption = context:addOption("The Only Cure on " .. clickedPlayer:getUsername());
    --             local rootMenu = context:getNew(context);
    --             local cutOption = rootMenu:addOption("Cut");
    --             local operateOption = rootMenu:addOption("Operate");
    --             local cutMenu = context:getNew(context);
    --             local operateMenu = context:getNew(context);

    --             context:addSubMenu(rootOption, rootMenu);
    --             context:addSubMenu(cutOption, cutMenu);
    --             context:addSubMenu(operateOption, operateMenu);
    --             -- todo add checks so that we don't show these menus if a player has already beeen operated or amputated
    --             for k, v in ipairs(GetBodyParts()) do
    --                 cutMenu:addOption(getText('UI_ContextMenu_' .. v), worldobjects, otherPlayerLocal, v, "Cut", clickedPlayer)
    --                 operateMenu:addOption(getText('UI_ContextMenu_' .. v), worldobjects, otherPlayerLocal, v, "Operate", clickedPlayer);

    --             end


    --         end
    --     end
    -- end


--Events.OnTick.Add(TheOnlyCure.CheckState);
Events.OnFillWorldObjectContextMenu.Add(ISWorldObjectContextMenu.OnFillOperateWithOven)       -- this is probably too much 