-- TODO this should be moved

local function TryToToResetEverythingOtherPlayer(_, patient, surgeon)
    sendClientCommand(surgeon, "TOC", "AskToResetEverything", { patient:getOnlineID() })
end

----------------------------------------------------------------------------------------------------------
if TOC_ContextMenu == nil then
    TOC_ContextMenu = {}
end

TOC_ContextMenu.CreateCheatsMenu = function(playerId, context, worldObjects, _)
    local clickedPlayers = {}
    local currentClickedPlayer = nil

    local localPlayer = getSpecificPlayer(playerId)
    --local players = getOnlinePlayers()

    for _, v in pairs(worldObjects) do
        -- help detecting a player by checking nearby squares
        for x = v:getSquare():getX() - 1, v:getSquare():getX() + 1 do
            for y = v:getSquare():getY() - 1, v:getSquare():getY() + 1 do
                local sq = getCell():getGridSquare(x, y, v:getSquare():getZ())
                if sq then
                    for i = 0, sq:getMovingObjects():size() - 1 do
                        local o = sq:getMovingObjects():get(i)
                        if instanceof(o, "IsoPlayer") then
                            currentClickedPlayer = o

                            if clickedPlayers[currentClickedPlayer:getUsername()] == nil then

                                -- FIXME this is to prevent context menu spamming. Find a better way
                                clickedPlayers[currentClickedPlayer:getUsername()] = true

                                if localPlayer:getAccessLevel() == "Admin" or isDebugEnabled() then
                                    local rootOption = context:addOption("Just Cut It Off Cheats on " .. currentClickedPlayer:getUsername())
                                    local rootMenu = context:getNew(context)

                                    if currentClickedPlayer == localPlayer then
                                        rootMenu:addOption("Reset TOC for me", _, TOC_Cheat.ResetEverything)
                            
                                    else
                                        rootMenu:addOption("Reset TOC for " .. currentClickedPlayer:getUsername(), _, TryToToResetEverythingOtherPlayer,
                                            currentClickedPlayer, localPlayer)
                            
                                    end
                                    context:addSubMenu(rootOption, rootMenu)
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


TOC_ContextMenu.CreateOperateWithOvenMenu = function(playerId, context, worldObjects, test)
    local player = getSpecificPlayer(playerId)
    -- TODO Let the player move towards the oven

    local partData = player:getModData().TOC.limbs
    local isMainMenuAlreadyCreated = false

    for _, currentObject in pairs(worldObjects) do
        if instanceof(currentObject, "IsoStove") and (player:HasTrait("Brave") or player:getPerkLevel(Perks.Strength) >= 6) then

            -- Check temperature
            if currentObject:getCurrentTemperature() > 250 then

                for _, partName in ipairs(TOC_Common.GetPartNames()) do
                    if partData[partName].isCut and partData[partName].isAmputationShown and
                        not partData[partName].isOperated then
                        local subMenu = context:getNew(context);

                        if isMainMenuAlreadyCreated == false then
                            local rootMenu = context:addOption(getText('UI_ContextMenu_OperateOven'), worldObjects, nil);
                            context:addSubMenu(rootMenu, subMenu)
                            isMainMenuAlreadyCreated = true
                        end
                        subMenu:addOption(getText('UI_ContextMenu_' .. partName), worldObjects, TOC_LocalActions.Operate,
                            getSpecificPlayer(playerId), partName,true)
                    end
                end
            end

            break -- stop searching for stoves

        end

    end
end

TOC_ContextMenu.CreateNewMenu = function(name, context, rootMenu)

    local new_option = rootMenu:addOption(name)
    local new_menu = context:getNew(context)
    context:addSubMenu(new_option, new_menu)

    return new_menu
end

TOC_ContextMenu.FillCheatMenus = function(context, cheat_menu)

    if cheat_menu then
        local cheat_cut_and_fix_menu = TOC_ContextMenu.CreateNewMenu("Cut and Fix", context, cheat_menu)

    end
end


Events.OnFillWorldObjectContextMenu.Add(TOC_ContextMenu.CreateOperateWithOvenMenu) -- this is probably too much
Events.OnFillWorldObjectContextMenu.Add(TOC_ContextMenu.CreateCheatsMenu)       -- TODO Add check only when admin is active
