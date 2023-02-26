------------------------------------------
-------- JUST CUT IT OFF --------
------------------------------------------
------------- LOCAL ACTIONS --------------



function TocCutLocal(_, player, part_name)
    if JCIO_Common.GetSawInInventory(player) ~= nil then
        ISTimedActionQueue.add(JCIO_CutLimbAction:new(player, player, part_name))
    else
        player:Say("I don't have a saw on me")
    end
end

function TocOperateLocal(_, player, part_name, use_oven)
    if use_oven then
        ISTimedActionQueue.add(JCIO_OperateLimbAction:new(player, player, _, part_name, use_oven));
    else
        local kit = TocGetKitInInventory(player)
        if kit ~= nil then
            ISTimedActionQueue.add(JCIO_OperateLimbAction:new(player, player, kit, part_name, false))
        else
            player:Say("I don't have a kit on me")
        end
    end
end

function TocEquipProsthesisLocal(_, player, part_name)
    local surgeon_inventory = player:getInventory()
    local prosthesis_to_equip = surgeon_inventory:getItemFromType('TOC.MetalHand') or
        surgeon_inventory:getItemFromType('TOC.MetalHook') or
        surgeon_inventory:getItemFromType('TOC.WoodenHook')
    if prosthesis_to_equip then
        ISTimedActionQueue.add(JCIO_InstallProsthesisAction:new(player, player, prosthesis_to_equip, part_name))
    else
        player:Say("I need a prosthesis")
    end
end

function TocUnequipProsthesisLocal(_, player, part_name)
    ISTimedActionQueue.add(JCIO_UninstallProsthesisAction:new(player, player, part_name))

end
