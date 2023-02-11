
-- Side functions
local function TocGetAmputationFullTypeFromInventory(player, side, limb)
    local player_inventory = player:getInventory()
    local item_name = "TOC.Amputation_" .. side .. "_" .. limb
    local found_item = player_inventory:FindAndReturn(item_name)
    if found_item then
        return found_item:getFullType()

    end

end

local function TocGetEquippedProsthesisFullTypeFromInventory(player, side, limb)
    local player_inventory = player:getInventory()
    for _, prost in ipairs(GetProsthesisList()) do
        local item_name = TocFindCorrectClothingProsthesis(prost, side .."_" .. limb)
        local found_item = player_inventory:FindAndReturn(item_name)
        if found_item then
            return found_item:getFullType()
        end
    end
end


function TocResetEverything()
    -- This has to be run on the local player to be sure that we're correctly reassigning everything
    local player = getPlayer()
    local player_inventory = player:getInventory()
    local mod_data = player:getModData()
    mod_data.TOC = nil

    -- Removes traits just to be sure
    local toc_traits = player:getTraits()
    toc_traits:remove("Amputee_Hand")
    toc_traits:remove("Amputee_LowerArm")
    toc_traits:remove("Amputee_UpperArm")


    TheOnlyCure.InitTheOnlyCure(_, player)

    -- Destroy the amputation or prosthesis item
    for _, v in ipairs(GetBodyParts()) do
        -- TODO This is incredibly shitty, but we can't use worn items since we need to consider the case that the item wasn't applied
        local amputation_item_name = TocFindAmputationOrProsthesisName(v, player, "Amputation")
        local prosthesis_item_name = TocFindAmputationOrProsthesisName(v, player, "Prosthesis")

        if amputation_item_name ~= nil then
            local amputation_item = player_inventory:FindAndReturn(amputation_item_name)
            if amputation_item ~= nil then
                print("Resetting " .. amputation_item:getName())
                player:removeWornItem(amputation_item)
                player:getInventory():Remove(amputation_item)
            end
            amputation_item = nil -- reset it
        end
        if prosthesis_item_name ~= nil then
            local prosthesis_item = player_inventory:FindAndReturn(prosthesis_item_name)
            if prosthesis_item ~= nil then
                print("Resetting " .. prosthesis_item:getName())
                player:removeWornItem(prosthesis_item)
                player:getInventory():Remove(prosthesis_item)
            end
            prosthesis_item = nil -- reset it
        end


    end
end


-- Set correct body locations for items in inventory
function TocResetClothingItemBodyLocation(player, side, limb)
    local player_inventory = player:getInventory()
    local limbs_data = player:getModData().TOC.Limbs
    local amputation_item_name = TocGetAmputationFullTypeFromInventory(player, side, limb)
    local equipped_prosthesis_item_name = TocGetEquippedProsthesisFullTypeFromInventory(player, side, limb)
    print(amputation_item_name)
    print(equipped_prosthesis_item_name)

    if amputation_item_name ~= nil then

        local amputation_item = player_inventory:FindAndReturn(amputation_item_name)
        if amputation_item ~= nil then
            player:removeWornItem(amputation_item)
            player:getInventory():Remove(amputation_item)
            amputation_item = player_inventory:AddItem(amputation_item_name)
            TocSetCorrectTextureForAmputation(amputation_item, player, limbs_data[side .. "_" .. limb].is_cicatrized)

            player:setWornItem(amputation_item:getBodyLocation(), amputation_item)
        end
        amputation_item = nil -- reset it
    end

    if equipped_prosthesis_item_name ~= nil then
        local prosthesis_item = player_inventory:FindAndReturn(equipped_prosthesis_item_name)
        if prosthesis_item ~= nil then
            print("Resetting " .. prosthesis_item:getName())
            player:removeWornItem(prosthesis_item)
            player:getInventory():Remove(prosthesis_item)
            prosthesis_item = player_inventory:AddItem(equipped_prosthesis_item_name)
            player:setWornItem(prosthesis_item:getBodyLocation(), prosthesis_item)

        end
        prosthesis_item = nil -- reset it
    end
end
-----------------------------------------------------------------------


function TocTestBodyLocations()

    local group = BodyLocations.getGroup("Human")
    local list = getClassFieldVal(group, getClassField(group, 1))

    for i=1, list:size() do
 
            print(list:get(i -1):getId())

    end
end