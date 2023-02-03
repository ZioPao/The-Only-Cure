-- TODO this needs to be moved away
function TocGetKitInInventory(surgeon)
    local playerInv = surgeon:getInventory();
    local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or
        playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
    return item

end

-- Unequip Prosthesis

function PartNameToBodyLocationProsthesis(name)
    if name == "Right_Hand" then return "TOC_ArmRightProsthesis" end
    if name == "Right_LowerArm" then return "TOC_ArmRightProsthesis" end
    if name == "Right_UpperArm" then return "TOC_ArmRightProsthesis" end
    if name == "Left_Hand" then return "TOC_ArmLeftProsthesis" end
    if name == "Left_LowerArm" then return "TOC_ArmLeftProsthesis" end
    if name == "Left_UpperArm" then return "TOC_ArmLeftProsthesis" end
end

function PartNameToBodyLocationAmputation(name)
    if name == "Right_Hand" then return "TOC_ArmRight" end
    if name == "Right_LowerArm" then return "TOC_ArmRight" end
    if name == "Right_UpperArm" then return "TOC_ArmRight" end
    if name == "Left_Hand" then return "TOC_ArmLeft" end
    if name == "Left_LowerArm" then return "TOC_ArmLeft" end
    if name == "Left_UpperArm" then return "TOC_ArmLeft" end
end

function TocFindItemInProstBodyLocation(part_name, patient)
    -- Can't be used for online purposes, since we can't get the online inventory of another player
    local worn_items = patient:getWornItems()

    for i = 1, worn_items:size() - 1 do -- Maybe wornItems:size()-1
        local item = worn_items:get(i):getItem()
        if item:getBodyLocation() == PartNameToBodyLocationProsthesis(part_name) then
            return item
        end
    end

end

-- Debug cheat and update every minute for cicatrization
function TocFindAmputationOrProsthesisName(part_name, player, choice)
    local worn_items = player:getWornItems()
    for i = 1, worn_items:size() - 1 do 
        local item = worn_items:get(i):getItem()

        if choice == "Amputation" then
            
            if item:getBodyLocation() == PartNameToBodyLocationAmputation(part_name) then
                return item:getFullType()
            end
        elseif choice == "Prosthesis" then

            if item:getBodyLocation() == PartNameToBodyLocationProsthesis(part_name) then
                return item:getFullType()

            end
        end

    end

end





-------------------------------------
-- Override and mod compat helper
function TocPopulateCanBeHeldTable(can_be_held, limbs_data)

    for _, side in ipairs(TOC_sides) do
        can_be_held[side] = true

        if limbs_data[side .. "_Hand"].is_cut then
            if limbs_data[side .. "_LowerArm"].is_cut then
                if not limbs_data[side .. "_LowerArm"].is_prosthesis_equipped then
                    can_be_held[side] = false
                end
            elseif not limbs_data[side .. "_Hand"].is_prosthesis_equipped then
                can_be_held[side] = false
            end
        end
    end

end