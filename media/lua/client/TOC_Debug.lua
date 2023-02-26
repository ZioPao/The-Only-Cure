------------------------------------------
-------- JUST CUT IT OFF --------
------------------------------------------
------------ DEBUG FUNCTIONS -------------


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


    JCIO.Init(_, player)

    -- Destroy the amputation or prosthesis item

    for _, side in pairs(JCIO.sideNames) do
        for _, limb in pairs(JCIO.limbNames) do
        
            local part_name = side .. "_" .. limb
            local amputation_item_name = TocFindAmputationOrProsthesisName(part_name, player, "Amputation")
            local prosthesis_item_name = TocFindAmputationOrProsthesisName(part_name, player, "Prosthesis")
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


    -- Reset special flag for legs amputations
    JCIO_Anims.SetMissingFootAnimation(false)

end


-- Set correct body locations for items in inventory
function TocResetClothingItemBodyLocation(player, side, limb)

    local playerInv = player:getInventory()
    local limbsData = player:getModData().JCIO.limbs

    local amputationItemName = TocGetAmputationFullTypeFromInventory(player, side, limb)
    local equippedProsthesisItemName = TocGetEquippedProsthesisFullTypeFromInventory(player, side, limb)

    if amputationItemName ~= nil then

        local amputationItem = playerInv:FindAndReturn(amputationItemName)
        if amputationItem ~= nil then
            player:removeWornItem(amputationItem)
            player:getInventory():Remove(amputationItem)
            amputationItem = playerInv:AddItem(amputationItemName)
            JCIO_Visuals.SetTextureForAmputation(amputationItem, player, limbsData[side .. "_" .. limb].is_cicatrized)
            player:setWornItem(amputationItem:getBodyLocation(), amputationItem)
        end
        amputationItem = nil -- reset it
    end

    if equippedProsthesisItemName ~= nil then
        local prosthesisItem = playerInv:FindAndReturn(equippedProsthesisItemName)
        if prosthesisItem ~= nil then
            print("Resetting " .. prosthesisItem:getName())
            player:removeWornItem(prosthesisItem)
            player:getInventory():Remove(prosthesisItem)
            prosthesisItem = playerInv:AddItem(equippedProsthesisItemName)
            player:setWornItem(prosthesisItem:getBodyLocation(), prosthesisItem)

        end
        prosthesisItem = nil -- reset it
    end
end

-----------------------------------------------------------------------





------ TEST FUNCTIONS, DON'T USE THESE!!! ---------------

function TocTestBodyLocations()

    local group = BodyLocations.getGroup("Human")
    local list = getClassFieldVal(group, getClassField(group, 1))

    for i=1, list:size() do
 
            print(list:get(i -1):getId())

    end
end

function TocTestItem()
    local player = getPlayer()
    local player_inventory = player:getInventory()
    local item_name = "TOC.Amputation_" .. "Right" .. "_" .. "Hand"
    local found_item = player_inventory:FindAndReturn(item_name)

    print(found_item:getID())
    print("_______________")
    found_item:setID(12334)
    print(found_item:getID())
end