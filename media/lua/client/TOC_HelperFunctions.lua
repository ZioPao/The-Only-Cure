-- CutLimb
function TocCheckIfStillInfected(limbs_data)
    if limbs_data == nil then
        return
    end
    -- Check ALL body part types to check if the player is still gonna die
    local check = false


    for _, v in ipairs(GetBodyParts()) do
        if limbs_data[v].is_infected then
            check = true
        end
    end

    if limbs_data.is_other_bodypart_infected then
        check = true
    end

    return check
end

function TocCureInfection(body_damage, part_name)

    local body_part_type = body_damage:getBodyPart(TocGetBodyPartFromPartName(part_name))

    body_damage:setInfected(false)
    body_part_type:SetInfected(false)
    body_damage:setInfectionMortalityDuration(-1)
    body_damage:setInfectionTime(-1)
    body_damage:setInfectionLevel(0)
    local body_part_types = body_damage:getBodyParts()

    -- TODO I think this is enough... we should just cycle if with everything instead of that crap up there
    for i = body_part_types:size() - 1, 0, -1 do
        local bodyPart = body_part_types:get(i);
        bodyPart:SetInfected(false);
    end
    
    if body_part_type:scratched() then body_part_type:setScratched(false, false) end
    if body_part_type:haveGlass() then body_part_type:setHaveGlass(false) end
    if body_part_type:haveBullet() then body_part_type:setHaveBullet(false, 0) end
    if body_part_type:isInfectedWound() then body_part_type:setInfectedWound(false) end
    if body_part_type:isBurnt() then body_part_type:setBurnTime(0) end
    if body_part_type:isCut() then body_part_type:setCut(false, false) end --Lacerations
    if body_part_type:getFractureTime() > 0 then body_part_type:setFractureTime(0) end
end

function TocDeleteOtherAmputatedLimbs(side)

    -- if left hand is cut and we cut left lowerarm, then delete hand


    for _, limb in pairs(TOC_limbs) do
        local part_name = "TOC.Amputation_" .. side .. "_" .. limb
        local amputated_limb = getPlayer():getInventory():FindAndReturn(part_name)
        if amputated_limb then
            getPlayer():getInventory():Remove(amputated_limb)
        end

    end

end

function TocGetKitInInventory(surgeon)
    local playerInv = surgeon:getInventory();
    local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or
        playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
    return item

end

function TocGetSawInInventory(surgeon)

    local player_inv = surgeon:getInventory()
    local item = player_inv:getItemFromType("Saw") or player_inv:getItemFromType("GardenSaw") or
        player_inv:getItemFromType("Chainsaw")
    return item
end

function TocDamagePlayerDuringAmputation(patient, part_name)

    -- Since we're cutting that specific part, it only makes sense that the bleeding starts from there. 
    -- Then, we just delete the bleeding somewhere else before applying the other damage to to upper part of the limb
    local body_part_type = TocGetBodyPartFromPartName(part_name)
    local body_damage = patient:getBodyDamage()
    local body_damage_part = body_damage:getBodyPart(body_part_type)


    body_damage_part:setBleeding(true)
    body_damage_part:setCut(true)
    body_damage_part:setBleedingTime(ZombRand(10, 20))
end

---@param heal_bite boolean
function TocSetParametersForMissingLimb(body_part, heal_bite)
    body_part:setBleeding(false)
    body_part:setBleedingTime(0)
    body_part:setDeepWounded(false)
    body_part:setDeepWoundTime(0)
    body_part:setScratched(false, false)        -- why the fuck are there 2 booleans TIS?
    body_part:setScratchTime(0)
    body_part:setCut(false)
    body_part:setCutTime(0)

    if heal_bite then
        body_part:SetBitten(false)
        body_part:setBiteTime(0)
    end

end
-- OperateLimb
local function FixSingleBodyPartType(body_part_type, use_oven)
    body_part_type:setDeepWounded(false) --Basically like stitching
    body_part_type:setDeepWoundTime(0)
    if use_oven then
        body_part_type:AddDamage(100)
        body_part_type:setAdditionalPain(100);
        body_part_type:setBleeding(false)
        body_part_type:setBleedingTime(0) -- no bleeding since it's been cauterized
    else
        -- TODO Think a little better about this, do we want to trigger bleeding or not?
        body_part_type:setBleeding(false)

        --body_part_type:setBleedingTime(ZombRand(1, 5))   -- Reset the bleeding, maybe make it random
    end
end

function SetBodyPartsStatusAfterOperation(player, limbs_data, part_name, use_oven)
    --for _, v in ipairs(GetBodyParts()) do


    local body_part_type = player:getBodyDamage():getBodyPart(TocGetAdiacentBodyPartFromPartName(part_name))
    FixSingleBodyPartType(body_part_type, use_oven)

    for _, v in ipairs(limbs_data[part_name].depends_on) do
        local depended_body_part_type = player:getBodyDamage():getBodyPart(TocGetAdiacentBodyPartFromPartName(v))
        FixSingleBodyPartType(depended_body_part_type, use_oven)

    end
end




-- Unequip Prosthesis

local function PartNameToBodyLocationProsthesis(name)
    if name == "Right_Hand" then return "TOC_ArmRightProsthesis" end
    if name == "Right_LowerArm" then return "TOC_ArmRightProsthesis" end
    if name == "Right_UpperArm" then return "TOC_ArmRightProsthesis" end
    if name == "Left_Hand" then return "TOC_ArmLeftProsthesis" end
    if name == "Left_LowerArm" then return "TOC_ArmLeftProsthesis" end
    if name == "Left_UpperArm" then return "TOC_ArmLeftProsthesis" end
end

local function PartNameToBodyLocationAmputation(name)
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


-- Debug cheat
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
-- Override helper

function CheckIfItemIsAmputatedLimb(item)
    -- TODO Benchmark if this is faster
    local item_full_type = item:getFullType()


    if string.find(item_full_type, "TOC.Amputation_") then
        return true
    else
        return false
    end


end

function CheckIfItemIsProsthesis(item)

    -- TODO find a cleaner way
    local item_full_type = item:getFullType()
    local prosthesis_list = GetProsthesisList()

    for _, v in pairs(prosthesis_list) do
        if v == item_full_type then
            return true
        end
    end

    return false

end

function CheckIfItemIsInstalledProsthesis(item)
    local item_full_type = item:getFullType()
    if string.find(item_full_type, "TOC.Prost_") then
        return true
    else
        return false
    end

end

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

    return 

end