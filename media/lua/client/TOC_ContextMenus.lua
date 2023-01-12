local function CutLocal(_, patient, surgeon, partName)


    if IsSawInInventory(surgeon) ~= nil then
        ISTimedActionQueue.add(IsCutArm:new(patient, surgeon, partName));
    else
        surgeon:Say("I don't have a saw on me")

    end

end

local function OperateLocal(_, patient, surgeon, partName, useOven)
    --local player = getPlayer();
    -- todo add a check if the player has already been amputated or somethin

    if useOven then
        ISTimedActionQueue.add(ISOperateArm:new(patient, surgeon, _, partName, useOven));
    else

        local kit = GetKitInInventory(surgeon)
        if kit ~= nil then
            ISTimedActionQueue.add(ISOperateArm:new(patient, surgeon, kit, partName, false))

        else
            surgeon:Say("I don't have a kit on me")
        end

    end



end



local function otherPlayerLocal(_, partName, action, surgeon, patient)

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
    SetConfirmUIMP("Wait server")



   
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



function ISWorldObjectContextMenu.OnFillTOCMenu(player, context, worldObjects, test)


    local clickedPlayersTable = {}      --todo awful workaround
    local clickedPlayer = nil

    local player_obj = getSpecificPlayer(player)
    --local players = getOnlinePlayers()     

    for k,v in ipairs(worldObjects) do
            -- help detecting a player by checking nearby squares
        for x=v:getSquare():getX()-1,v:getSquare():getX()+1 do
            for y=v:getSquare():getY()-1,v:getSquare():getY()+1 do
                local sq = getCell():getGridSquare(x,y,v:getSquare():getZ());
                if sq then
                    for i=0,sq:getMovingObjects():size()-1 do
                        local o = sq:getMovingObjects():get(i)
                        if instanceof(o, "IsoPlayer") then
                            clickedPlayer = o

                            if clickedPlayersTable[clickedPlayer:getUsername()] == nil then
                                clickedPlayersTable[clickedPlayer:getUsername()] = true
                                
                                local rootOption = context:addOption("The Only Cure on " .. clickedPlayer:getUsername())
                                local rootMenu = context:getNew(context)
                                local cutOption = rootMenu:addOption("Cut");
                                local operateOption = rootMenu:addOption("Operate");
                                local cutMenu = context:getNew(context);
                                local operateMenu = context:getNew(context);

                                context:addSubMenu(rootOption, rootMenu);
                                context:addSubMenu(cutOption, cutMenu);
                                context:addSubMenu(operateOption, operateMenu);
                                -- todo add checks so that we don't show these menus if a player has already beeen operated or amputated




                                for k_part, v_part in ipairs(GetBodyParts()) do

                                    --todo right now it doesnt check for a saw.
                                    if clickedPlayer == player_obj then
                                        cutMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, CutLocal, player_obj, player_obj, v_part)
                                        operateMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, OperateLocal,  player_obj, player_obj, v_part)
                                    else
                                        cutMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, otherPlayerLocal, v_part, "Cut", player_obj, clickedPlayer)
                                        operateMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, otherPlayerLocal, v_part, "Operate", player_obj, clickedPlayer);
    
                                    end

                                   
                                end


                                break
                            end

                        end
                    end
                end
            end
        end
    end
end


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
                        subMenu:addOption(getText('UI_ContextMenu_' .. v_bodypart), worldObjects, OperateLocal, getSpecificPlayer(player), getSpecificPlayer(player), v_bodypart, true)
                    end
                end
            end

            break   -- stop searching for stoves

        end

    end
end











Events.OnFillWorldObjectContextMenu.Add(ISWorldObjectContextMenu.OnFillOperateWithOven)       -- this is probably too much 
Events.OnFillWorldObjectContextMenu.Add(ISWorldObjectContextMenu.OnFillTOCMenu)