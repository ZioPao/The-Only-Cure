function TocCutLocal(_, patient, surgeon, part_name)
    if GetSawInInventory(surgeon) ~= nil then
        ISTimedActionQueue.add(ISCutLimb:new(patient, surgeon, part_name));
    else
        surgeon:Say("I don't have a saw on me")
    end
end

function TocOperateLocal(_, patient, surgeon, part_name, use_oven)
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

function TocEquipProsthesisLocal(_, patient, surgeon, part_name)
    -- TODO probably completely broken for MP 
    -- TODO this is really janky
    local surgeon_inventory = surgeon:getInventory()
    local prosthesis_to_equip = surgeon_inventory:getItemFromType('TOC.MetalHand') or 
                            surgeon_inventory:getItemFromType('TOC.MetalHook') or 
                            surgeon_inventory:getItemFromType('TOC.WoodenHook')
    if prosthesis_to_equip then
        ISTimedActionQueue.add(ISInstallProsthesis:new(patient, prosthesis_to_equip, patient:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromBodyPart(part_name))))
    else
        surgeon:Say("I need a prosthesis")
    end
end

function TocUnequipProsthesisLocal(_, patient, part_name)
    local equipped_prosthesis = FindTocItemWorn(part_name, patient)
    ISTimedActionQueue.add(ISUninstallProsthesis:new(patient, equipped_prosthesis, patient:getBodyDamage():getBodyPart(TocGetBodyPartTypeFromBodyPart(part_name))))
end