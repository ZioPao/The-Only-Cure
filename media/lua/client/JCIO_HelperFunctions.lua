-- TODO this needs to be moved away
function JCIO_Common.GetKitInInventory(surgeon)
    local playerInv = surgeon:getInventory()
    local item = playerInv:getItemFromType('JCIO.Real_surgeon_kit') or playerInv:getItemFromType('JCIO.Surgeon_kit') or
        playerInv:getItemFromType('JCIO.Improvised_surgeon_kit')
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

function JCIO_Common.FindItemInProstBodyLocation(partName, patient)
    -- Can't be used for online purposes, since we can't get the online inventory of another player
    local wornItems = patient:getWornItems()

    -- Particular case where i= 1 and size - 1 I guess?
    for i = 1, wornItems:size() - 1 do
        local item = wornItems:get(i):getItem()
        if item:getBodyLocation() == PartNameToBodyLocationProsthesis(partName) then
            return item
        end
    end

end

-- Debug cheat and update every minute for cicatrization
function JCIO_Common.FindAmputationOrProsthesisName(partName, player, choice)
    local wornItems = player:getWornItems()
    for i = 1, wornItems:size() - 1 do
        local item = wornItems:get(i):getItem()

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


