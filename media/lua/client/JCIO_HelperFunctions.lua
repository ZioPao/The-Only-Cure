-- TODO this needs to be moved away
function TocGetKitInInventory(surgeon)
    local playerInv = surgeon:getInventory();
    local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or
        playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
    return item

end

-- Unequip Prosthesis

local function PartNameToBodyLocationProsthesis(name)
    if name == "Right_Hand" then return "JCIO_ArmRightProsthesis" end
    if name == "Right_LowerArm" then return "JCIO_ArmRightProsthesis" end
    if name == "Right_UpperArm" then return "JCIO_ArmRightProsthesis" end
    if name == "Left_Hand" then return "JCIO_ArmLeftProsthesis" end
    if name == "Left_LowerArm" then return "JCIO_ArmLeftProsthesis" end
    if name == "Left_UpperArm" then return "JCIO_ArmLeftProsthesis" end
end

local function PartNameToBodyLocationAmputation(name)
    if name == "Right_Hand" then return "JCIO_ArmRight" end
    if name == "Right_LowerArm" then return "JCIO_ArmRight" end
    if name == "Right_UpperArm" then return "JCIO_ArmRight" end
    if name == "Left_Hand" then return "JCIO_ArmLeft" end
    if name == "Left_LowerArm" then return "JCIO_ArmLeft" end
    if name == "Left_UpperArm" then return "JCIO_ArmLeft" end

    if name == "Left_Foot" then return "JCIO_LegLeft" end
    if name == "Right_Foot" then return "JCIO_LegRight" end
end

function TocFindItemInProstBodyLocation(partName, patient)
    -- Can't be used for online purposes, since we can't get the online inventory of another player
    local worn_items = patient:getWornItems()

    for i = 1, worn_items:size() - 1 do -- Maybe wornItems:size()-1
        local item = worn_items:get(i):getItem()
        if item:getBodyLocation() == PartNameToBodyLocationProsthesis(partName) then
            return item
        end
    end

end

-- Debug cheat and update every minute for cicatrization
function TocFindAmputationOrProsthesisName(partName, player, choice)
    local worn_items = player:getWornItems()
    for i = 1, worn_items:size() - 1 do 
        local item = worn_items:get(i):getItem()

        if choice == "Amputation" then
            
            if item:getBodyLocation() == PartNameToBodyLocationAmputation(partName) then
                return item:getFullType()
            end
        elseif choice == "Prosthesis" then

            if item:getBodyLocation() == PartNameToBodyLocationProsthesis(partName) then
                return item:getFullType()

            end
        end

    end

end


