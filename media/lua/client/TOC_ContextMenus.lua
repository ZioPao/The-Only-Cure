-- TODO this should be moved

function TryToToResetEverythingOtherPlayer(_, patient, surgeon)
    sendClientCommand(surgeon, "TOC", "AskToResetEverything", { patient:getOnlineID() })
end

----------------------------------------------------------------------------------------------------------

TocContextMenus = {}


TocContextMenus.CreateMenus = function(player, context, worldObjects, test)
    local clicked_players_table = {}
    local clicked_player = nil

    local local_player = getSpecificPlayer(player)
    --local players = getOnlinePlayers()

    for k, v in ipairs(worldObjects) do
        -- help detecting a player by checking nearby squares
        for x = v:getSquare():getX() - 1, v:getSquare():getX() + 1 do
            for y = v:getSquare():getY() - 1, v:getSquare():getY() + 1 do
                local sq = getCell():getGridSquare(x, y, v:getSquare():getZ())
                if sq then
                    for i = 0, sq:getMovingObjects():size() - 1 do
                        local o = sq:getMovingObjects():get(i)
                        if instanceof(o, "IsoPlayer") then
                            clicked_player = o

                            if clicked_players_table[clicked_player:getUsername()] == nil then

                                -- FIXME this is to prevent context menu spamming. Find a better way
                                clicked_players_table[clicked_player:getUsername()] = true

                                if local_player:getAccessLevel() == "Admin" or isDebugEnabled() then
                                    local root_option = context:addOption("The Only Cure Cheats on " .. clicked_player:getUsername())
                                    local root_menu = context:getNew(context)

                                    if clicked_player == local_player then
                                        root_menu:addOption("Reset TOC for me", _, TocResetEverything)
                            
                                    else
                                        root_menu:addOption("Reset TOC for " .. clicked_player:getUsername(), _, TryToToResetEverythingOtherPlayer,
                                            clicked_player, local_player)
                            
                                    end
                                    context:addSubMenu(root_option, root_menu)
                                end



                                -- TocContextMenus.FillCutAndOperateMenus(local_player, clicked_player, worldObjects,
                                --     cut_menu, operate_menu)
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
        if instanceof(v_stove, "IsoStove") and
            (player_obj:HasTrait("Brave") or player_obj:getPerkLevel(Perks.Strength) >= 6) then

            -- Check temperature
            if v_stove:getCurrentTemperature() > 250 then

                for _, v_bodypart in ipairs(GetBodyParts()) do
                    if part_data[v_bodypart].is_cut and part_data[v_bodypart].is_amputation_shown and
                        not part_data[v_bodypart].is_operated then
                        local subMenu = context:getNew(context);

                        if is_main_menu_already_created == false then
                            local rootMenu = context:addOption(getText('UI_ContextMenu_OperateOven'), worldObjects, nil);
                            context:addSubMenu(rootMenu, subMenu)
                            is_main_menu_already_created = true
                        end
                        subMenu:addOption(getText('UI_ContextMenu_' .. v_bodypart), worldObjects, TocOperateLocal,
                            getSpecificPlayer(player), v_bodypart,true)
                    end
                end
            end

            break -- stop searching for stoves

        end

    end
end

TocContextMenus.CreateNewMenu = function(name, context, root_menu)

    local new_option = root_menu:addOption(name)
    local new_menu = context:getNew(context)
    context:addSubMenu(new_option, new_menu)

    return new_menu
end

TocContextMenus.CreateCheatMenu = function(context, root_menu, local_player, clicked_player)
    if local_player:getAccessLevel() == "Admin" or isDebugEnabled() then

        local cheat_menu = TocContextMenus.CreateNewMenu("Cheat", context, root_menu)

        if clicked_player == local_player then
            cheat_menu:addOption("Reset TOC for me", _, TocResetEverything)

        else
            cheat_menu:addOption("Reset TOC for " .. clicked_player:getUsername(), _, TryToToResetEverythingOtherPlayer,
                clicked_player, local_player)

        end

        return cheat_menu
    end
end


TocContextMenus.FillCheatMenus = function(context, cheat_menu)

    if cheat_menu then
        local cheat_cut_and_fix_menu = TocContextMenus.CreateNewMenu("Cut and Fix", context, cheat_menu)

    end
end


Events.OnFillWorldObjectContextMenu.Add(TocContextMenus.CreateOperateWithOvenMenu) -- this is probably too much
Events.OnFillWorldObjectContextMenu.Add(TocContextMenus.CreateMenus)
