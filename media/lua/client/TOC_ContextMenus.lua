
function TryToToResetEverythingOtherPlayer(_, patient, surgeon)
    sendClientCommand(surgeon, "TOC", "AskToResetEverything", {patient:getOnlineID()})
end





----------------------------------------------------------------------------------------------------------

TocContextMenus = {}


TocContextMenus.CreateMenus = function(player, context, worldObjects, test)
    local clicked_players_table = {}
    local clicked_player = nil

    local local_player = getSpecificPlayer(player)
    --local players = getOnlinePlayers()     

    for k,v in ipairs(worldObjects) do
        -- help detecting a player by checking nearby squares
        for x=v:getSquare():getX()-1,v:getSquare():getX()+1 do
            for y=v:getSquare():getY()-1,v:getSquare():getY()+1 do
                local sq = getCell():getGridSquare(x,y,v:getSquare():getZ())
                if sq then
                    for i=0,sq:getMovingObjects():size()-1 do
                        local o = sq:getMovingObjects():get(i)
                        if instanceof(o, "IsoPlayer") then
                            clicked_player = o

                            if clicked_players_table[clicked_player:getUsername()] == nil then

                                -- FIXME this is to prevent context menu spamming. Find a better way
                                clicked_players_table[clicked_player:getUsername()] = true
                                
                                local root_option = context:addOption("The Only Cure on " .. clicked_player:getUsername())
                                local root_menu = context:getNew(context)

                                local cut_menu = TocContextMenus.CreateNewMenu("Cut", context, root_menu)
                                local operate_menu = TocContextMenus.CreateNewMenu("Operate", context, root_menu)
                                local cheat_menu = TocContextMenus.CreateCheatMenu(context, root_menu, local_player, clicked_player)
                                context:addSubMenu(root_option, root_menu)

                                TocContextMenus.FillCutAndOperateMenus(local_player, clicked_player, worldObjects, cut_menu, operate_menu)
                                --TocContextMenus.FillCheatMenu(context, cheat_menu)

                                break
                            end

                        end
                    end
                end
            end
        end
    end
end


TocContextMenus.CreateOperateWithOvenMenu = function(player, context, worldObjects, test)
    local player_obj = getSpecificPlayer(player)
    --local clickedPlayer


    -- TODO Add a way to move the player towards the oven

    
    local part_data = player_obj:getModData().TOC.Limbs

    local is_main_menu_already_created = false


    --local props = v:getSprite() and v:getSprite():getProperties() or nil

    for _, v_stove in pairs(worldObjects) do
        if instanceof(v_stove, "IsoStove") and (player_obj:HasTrait("Brave") or player_obj:getPerkLevel(Perks.Strength) >= 6) then

            -- Check temperature
            if v_stove:getCurrentTemperature() > 250 then
                
                for _, v_bodypart in ipairs(GetBodyParts()) do
                    if part_data[v_bodypart].is_cut and part_data[v_bodypart].is_amputation_shown and not part_data[v_bodypart].is_operated  then
                        local subMenu = context:getNew(context);

                        if is_main_menu_already_created == false then
                            local rootMenu = context:addOption(getText('UI_ContextMenu_OperateOven'), worldObjects, nil);
                            context:addSubMenu(rootMenu, subMenu)
                            is_main_menu_already_created = true
                        end
                        subMenu:addOption(getText('UI_ContextMenu_' .. v_bodypart), worldObjects, TocOperateLocal, getSpecificPlayer(player), getSpecificPlayer(player), v_bodypart, true)
                    end
                end
            end

            break   -- stop searching for stoves

        end

    end
end


TocContextMenus.DoCut = function(_, patient, surgeon, part_name)

    if GetSawInInventory(surgeon) then
        ISTimedActionQueue.add(ISCutLimb:new(patient, surgeon, part_name));
    else
        surgeon:Say("I don't have a saw on me")
    end
end



TocContextMenus.CreateNewMenu = function(name, context, root_menu)

    local new_option = root_menu:addOption(name)
    local new_menu = context:getNew(context)
    context:addSubMenu(new_option, new_menu)

    return new_menu
end



TocContextMenus.FillCutAndOperateMenus = function(local_player, clicked_player, world_objects, cut_menu, operate_menu)

    local local_part_data = local_player:getModData().TOC.Limbs

    for _, v in ipairs(GetBodyParts()) do


        if local_player == clicked_player then        -- Local player
            if CheckIfCanBeCut(v) and not CheckIfProsthesisAlreadyInstalled(local_part_data, v) then
                cut_menu:addOption(getText('UI_ContextMenu_' .. v), _, TryTocAction, v, "Cut", local_player, local_player)

            elseif CheckIfCanBeOperated(v) then
                operate_menu:addOption(getText('UI_ContextMenu_' .. v), _, TryTocAction, v, "Operate", local_player, local_player)
            end
            
        else    -- Another player
            -- TODO add way to prevent cutting already cut parts of another player
            cut_menu:addOption(getText('UI_ContextMenu_' .. v), world_objects, TryTocAction, v, "Cut", local_player, clicked_player)
            operate_menu:addOption(getText('UI_ContextMenu_' .. v), world_objects, TryTocAction, v, "Operate", local_player, clicked_player)

        end

    end

end




TocContextMenus.CreateCheatMenu = function(context, root_menu, local_player, clicked_player)
    if local_player:getAccessLevel() == "Admin" then

        local cheat_menu = TocContextMenus.CreateNewMenu("Cheat", context, root_menu)

        if clicked_player == local_player then
            cheat_menu:addOption("Reset TOC for me", _, TocResetEverything)

        else
            cheat_menu:addOption("Reset TOC for " .. clicked_player:getUsername(), _, TryToToResetEverythingOtherPlayer, clicked_player, local_player)

        end

        return cheat_menu
    end
end


TocContextMenus.FillCheatMenus = function(context, cheat_menu)

    if cheat_menu then
        local cheat_cut_and_fix_menu = TocContextMenus.CreateNewMenu("Cut and Fix", context, cheat_menu)

    end
end


Events.OnFillWorldObjectContextMenu.Add(TocContextMenus.CreateOperateWithOvenMenu)       -- this is probably too much 
Events.OnFillWorldObjectContextMenu.Add(TocContextMenus.CreateMenus)