------------------------------------------
------------- JUST CUT IT OUT ------------
------------------------------------------
------------- LOCAL ACTIONS --------------

--Used to handle SP scenarios


if JCIO_LocalActions == nil then
    JCIO_LocalActions = {}
end


function JCIO_LocalActions.Cut(_, player, partName)
    if JCIO_Common.GetSawInInventory(player) ~= nil then
        ISTimedActionQueue.add(JCIO_CutLimbAction:new(player, player, partName))
    else
        player:Say("I don't have a saw on me")
    end
end

function JCIO_LocalActions.Operate(_, player, partName, useOven)
    if useOven then
        ISTimedActionQueue.add(JCIO_OperateLimbAction:new(player, player, _, partName, useOven));
    else
        local kit = JCIO_Common.GetKitInInventory(player)
        if kit ~= nil then
            ISTimedActionQueue.add(JCIO_OperateLimbAction:new(player, player, kit, partName, false))
        else
            player:Say("I don't have a kit on me")
        end
    end
end

-- TODO This is gonna get deleted
function JCIO_LocalActions.EquipProsthesis(_, player, partName)
    local surgeonInv = player:getInventory()
    local prosthesisToEquip = surgeonInv:getItemFromType('TOC.MetalHand') or
        surgeonInv:getItemFromType('TOC.MetalHook') or
        surgeonInv:getItemFromType('TOC.WoodenHook')
    if prosthesisToEquip then
        ISTimedActionQueue.add(JCIO_InstallProsthesisAction:new(player, player, prosthesisToEquip, partName))
    else
        player:Say("I need a prosthesis")
    end
end

function JCIO_LocalActions.UnequipProsthesis(_, player, partName)
    ISTimedActionQueue.add(JCIO_UninstallProsthesisAction:new(player, player, partName))
end
