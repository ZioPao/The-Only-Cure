------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
------------- LOCAL ACTIONS --------------

--Used to handle SP scenarios


if TOC_LocalActions == nil then
    TOC_LocalActions = {}
end


function TOC_LocalActions.Cut(_, player, partName)
    if TOC_Common.GetSawInInventory(player) ~= nil then
        ISTimedActionQueue.add(TOC_CutLimbAction:new(player, player, partName))
    else
        player:Say("I don't have a saw on me")
    end
end

function TOC_LocalActions.Operate(_, player, partName, useOven)
    if useOven then
        ISTimedActionQueue.add(TOC_OperateLimbAction:new(player, player, _, partName, useOven));
    else
        local kit = TOC_Common.GetKitInInventory(player)
        if kit ~= nil then
            ISTimedActionQueue.add(TOC_OperateLimbAction:new(player, player, kit, partName, false))
        else
            player:Say("I don't have a kit on me")
        end
    end
end

function TOC_LocalActions.EquipProsthesis(_, player, partName)
    local surgeonInv = player:getInventory()


    -- TODO Find a better way to filter objects. Disabled for now and only gets LeatherBase
    local prosthesisToEquip = surgeonInv:getItemFromType('TOC.ProstNormal_LeatherBase_MetalHook')
    if prosthesisToEquip then
        ISTimedActionQueue.add(TOC_InstallProsthesisAction:new(player, player, prosthesisToEquip, partName))
    else
        player:Say("I need a prosthesis")
    end
end

function TOC_LocalActions.UnequipProsthesis(_, player, partName)
    ISTimedActionQueue.add(TOC_UninstallProsthesisAction:new(player, player, partName))
end
