
-- TODO rewrite this mess

local function CutLocal(_, patient, surgeon, part_name)
    if IsSawInInventory(surgeon) ~= nil then
        ISTimedActionQueue.add(ISCutLimb:new(patient, surgeon, part_name));
    else
        surgeon:Say("I don't have a saw on me")
    end
end

local function OperateLocal(_, patient, surgeon, part_name, use_oven)
    --local player = getPlayer();
    -- todo add a check if the player has already been amputated or somethin
    if use_oven then
        ISTimedActionQueue.add(ISOperateLimb:new(patient, surgeon, _, part_name, use_oven));
    else
        local kit = GetKitInInventory(surgeon)
        if kit ~= nil then
            ISTimedActionQueue.add(ISOperateLimb:new(patient, surgeon, kit, part_name, false))
        else
            surgeon:Say("I don't have a kit on me")
        end
    end
end


function TryToToResetEverythingOtherPlayer(_, patient, surgeon)
    sendClientCommand(surgeon, "TOC", "AskToResetEverything", {patient:getOnlineID()})
end

--TODO Make the name more unique
function TryActionOnOtherPlayerLocal(_, part_name, action, surgeon, patient)

    local ui = GetConfirmUIMP()
    if not ui then
        MakeConfirmUIMP()
        ui = GetConfirmUIMP()
    end

    if action == "Cut" then
        AskCanCutLimb(patient, part_name)
    elseif action == "Operate" then
        AskCanOperateLimb(patient, part_name)
    end
    ui.actionAct = action
    ui.partNameAct = part_name
    ui.patient = patient
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

local function CloseAllMenus(player_index)
    local contextMenu = getPlayerContextMenu(player_index)
    if contextMenu:isVisible() then

        contextMenu:closeAll()

    end
end


-- Declare context menus here so we can access them later
function ISWorldObjectContextMenu.OnFillTOCMenu(player, context, worldObjects, test)


   
end


function ISWorldObjectContextMenu.OnFillOperateWithOven(player, context, worldObjects, test)
  
end



----------------------------------------------------------------------------------------------------------

TocContextMenus = {}


TocContextMenus.CreateMenus = function(player, context, worldObjects, test)
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


                                -- admin stuff
                                if player_obj:getAccessLevel() == "Admin" then
                                    local cheat_option = rootMenu:addOption("Cheat")
                                    local cheat_menu = context:getNew(context)
                                    context:addSubMenu(cheat_option, cheat_menu)


                                    if clickedPlayer == player_obj then
                                        cheat_menu:addOption("Reset TOC for me", worldObjects, ResetEverything)

                                    else
                                        cheat_menu:addOption("Reset TOC for " .. clickedPlayer:getUsername(), worldObjects, TryToToResetEverythingOtherPlayer, clickedPlayer, player_obj)

                                    end
                                end

                                context:addSubMenu(rootOption, rootMenu);
                                context:addSubMenu(cutOption, cutMenu);
                                context:addSubMenu(operateOption, operateMenu);
                                -- todo add checks so that we don't show these menus if a player has already beeen operated or amputated


                                local player_toc_data = getPlayer():getModData().TOC

                                for k_part, v_part in ipairs(GetBodyParts()) do

                                    --todo right now it doesnt check for a saw.
                                    if clickedPlayer == player_obj then
                                        

                                        if player_toc_data[v_part].is_cut == false then
                                            cutMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, CutLocal, player_obj, player_obj, v_part)
                                        elseif player_toc_data[v_part].is_operated == false and player_toc_data[v_part].is_amputation_shown then
                                            operateMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, OperateLocal,  player_obj, player_obj, v_part)

                                        end
                                    else
                                        --TODO Make it so cut limbs do not appear in the Cut Menu
                                        --if clickedPlayer.getModData().TOC[v_part].is_cut == false then
                                        cutMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, TryActionOnOtherPlayerLocal, v_part, "Cut", player_obj, clickedPlayer)
                                        --elseif clickedPlayer.getModData().TOC[v_part].is_operated == false then
                                        operateMenu:addOption(getText('UI_ContextMenu_' .. v_part), worldObjects, TryActionOnOtherPlayerLocal, v_part, "Operate", player_obj, clickedPlayer);
                                        --end
    
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


TocContextMenus.CreateOperateWithOvenMenu = function(player, context, worldObjects, test)
    local player_obj = getSpecificPlayer(player)
    --local clickedPlayer


    -- TODO Add a way to move the player towards the oven

    
    local toc_data = player_obj:getModData().TOC

    local is_main_menu_already_created = false


    --local props = v:getSprite() and v:getSprite():getProperties() or nil

    for k_stove, v_stove in pairs(worldObjects) do
        if instanceof(v_stove, "IsoStove") and (player_obj:HasTrait("Brave") or player_obj:getPerkLevel(Perks.Strength) >= 6) then

            -- Check temperature
            if v_stove:getCurrentTemperature() > 250 then
                
                for k_bodypart, v_bodypart in ipairs(GetBodyParts()) do
                    if toc_data[v_bodypart].is_cut and toc_data[v_bodypart].is_amputation_shown and not toc_data[v_bodypart].is_operated  then
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


TocContextMenus.DoCut = function(_, patient, surgeon, part_name)

    if IsSawInInventory(surgeon) then
        ISTimedActionQueue.add(ISCutLimb:new(patient, surgeon, part_name));
    else
        surgeon:Say("I don't have a saw on me")
    end
end




Events.OnFillWorldObjectContextMenu.Add(TocContextMenus.CreateOperateWithOvenMenu)       -- this is probably too much 
Events.OnFillWorldObjectContextMenu.Add(TocContextMenus.CreateMenus)