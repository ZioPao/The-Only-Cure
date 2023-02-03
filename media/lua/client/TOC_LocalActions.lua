function TocCutLocal(_, player, part_name)
    if TocGetSawInInventory(player) ~= nil then
        ISTimedActionQueue.add(ISCutLimb:new(player, player, part_name))
    else
        player:Say("I don't have a saw on me")
    end
end

function TocOperateLocal(_, player, part_name, use_oven)
    --local player = getPlayer();
    -- todo add a check if the player has already been amputated or somethin
    if use_oven then
        ISTimedActionQueue.add(ISOperateLimb:new(player, player, _, part_name, use_oven));
    else
        local kit = TocGetKitInInventory(player)            -- TODO Why is it here and only for local?
        if kit ~= nil then
            ISTimedActionQueue.add(ISOperateLimb:new(player, player, kit, part_name, false))
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
        ISTimedActionQueue.add(ISInstallProsthesis:new(player, player, prosthesis_to_equip, part_name))
    else
        player:Say("I need a prosthesis")
    end
end

function TocUnequipProsthesisLocal(_, player, part_name)
    ISTimedActionQueue.add(ISUninstallProsthesis:new(player, player, part_name))

end
