local StaticData = require("TOC/StaticData")
local CommonMethods = require("TOC/CommonMethods")
---------------------------

--- Submodule to handle spawning the correct items after certain actions (ie: cutting a hand). LOCAL ONLY!
---@class ItemsController
local ItemsController = {}


--* Player Methods *--
---@class ItemsController.Player
ItemsController.Player = {}

---Returns the correct index for the textures of the amputation
---@param playerObj IsoPlayer
---@param isCicatrized boolean
---@return number
---@private
function ItemsController.Player.GetAmputationTexturesIndex(playerObj, isCicatrized)
    local textureString = playerObj:getHumanVisual():getSkinTexture()
    local isHairy = textureString:sub(-1) == "a"

    local matchedIndex = tonumber(textureString:match("%d%d"))      -- it must always be at least 1
    TOC_DEBUG.print("Texture string: " .. tostring(textureString))

    if isHairy then
        matchedIndex = matchedIndex + 5
    end

    if isCicatrized then
        matchedIndex = matchedIndex + (isHairy and 5 or 10) -- We add 5 is it's the texture, else 10
    end

    TOC_DEBUG.print("isCicatrized = " .. tostring(isCicatrized))
    TOC_DEBUG.print("Amputation Texture Index: " .. tostring(matchedIndex))
    return matchedIndex - 1
end

---Main function to delete a clothing item
---@param playerObj IsoPlayer
---@param clothingItem InventoryItem
---@return boolean
---@private
function ItemsController.Player.RemoveClothingItem(playerObj, clothingItem)
    if clothingItem and instanceof(clothingItem, "InventoryItem") then
        playerObj:removeWornItem(clothingItem)

        ---@diagnostic disable-next-line: param-type-mismatch
        playerObj:getInventory():Remove(clothingItem) -- Umbrella is wrong, can be an InventoryItem too
        TOC_DEBUG.print("found and deleted" .. tostring(clothingItem))

        -- Reset model
        playerObj:resetModelNextFrame()

        return true
    end
    return false
end

---Search and deletes an old amputation clothing item on the same side
---@param playerObj IsoPlayer
---@param limbName string
function ItemsController.Player.DeleteOldAmputationItem(playerObj, limbName)
    local side = CommonMethods.GetSide(limbName)
    for partName, _ in pairs(StaticData.PARTS_IND_STR) do
        local othLimbName = partName .. "_" .. side
        local othClothingItemName = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. othLimbName

        local othClothingItem = playerObj:getInventory():FindAndReturn(othClothingItemName)


        -- If we manage to find and remove an item, then we should stop this function.
        ---@cast othClothingItem InventoryItem
        if ItemsController.Player.RemoveClothingItem(playerObj, othClothingItem) then return end
    end
end

---Deletes all the old amputation items, used for resets
---@param playerObj IsoPlayer
function ItemsController.Player.DeleteAllOldAmputationItems(playerObj)
    -- This part is a workaround for a pretty shitty implementation on the java side. Check ProsthesisHandler for more infos
    local group = BodyLocations.getGroup("Human")
    group:setMultiItem("TOC_Arm", false)
    group:setMultiItem("TOC_ArmProst", false)

    for i = 1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        local clothItemName = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName
        local clothItem = playerObj:getInventory():FindAndReturn(clothItemName)
        ---@cast clothItem InventoryItem
        ItemsController.Player.RemoveClothingItem(playerObj, clothItem)
    end
    -- Reset model just in case
    playerObj:resetModel()

    group:setMultiItem("TOC_Arm", true)
    group:setMultiItem("TOC_ArmProst", true)
end

---Spawns and equips the correct amputation item to the player.
---@param playerObj IsoPlayer
---@param limbName string
function ItemsController.Player.SpawnAmputationItem(playerObj, limbName)
    TOC_DEBUG.print("clothing name " .. StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName)
    local clothingItem = playerObj:getInventory():AddItem(StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName)
    local texId = ItemsController.Player.GetAmputationTexturesIndex(playerObj, false)

    ---@cast clothingItem InventoryItem
    clothingItem:getVisual():setTextureChoice(texId) -- it counts from 0, so we have to subtract 1
    playerObj:setWornItem(clothingItem:getBodyLocation(), clothingItem)
end

---Search through worn items and modifies a specific amputation item
---@param playerObj IsoPlayer
---@param limbName string
---@param isCicatrized boolean
function ItemsController.Player.OverrideAmputationItemVisuals(playerObj, limbName, isCicatrized)
    local wornItems = playerObj:getWornItems()
    local fullType = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName

    for i = 1, wornItems:size() do
        local it = wornItems:get(i - 1)
        if it then
            local wornItem = wornItems:get(i - 1):getItem()
            TOC_DEBUG.print(wornItem:getFullType())
            if wornItem:getFullType() == fullType then
                TOC_DEBUG.print("Found amputation item for " .. limbName)

                -- change it here
                local texId = ItemsController.Player.GetAmputationTexturesIndex(playerObj, isCicatrized)
                wornItem:getVisual():setTextureChoice(texId)
                playerObj:resetModelNextFrame()     -- necessary to update the model
                return
            end
        end
    end
end

--* Zombie Methods *--
---@class ItemsController.Zombie
ItemsController.Zombie = {}

---Set an amputation to a zombie
---@param zombie IsoZombie
---@param amputationFullType string Full Type
function ItemsController.Zombie.SpawnAmputationItem(zombie, amputationFullType)
    local texId = ItemsController.Zombie.GetAmputationTexturesIndex(zombie)
    local zombieVisuals = zombie:getItemVisuals()
    local itemVisual = ItemVisual:new()
    itemVisual:setItemType(amputationFullType)
    itemVisual:setTextureChoice(texId)
    if zombieVisuals then zombieVisuals:add(itemVisual) end
    zombie:resetModelNextFrame()

    -- Spawn the item too in the inventory to keep track of stuff this way. It's gonna get deleted when we reload the game
    local zombieInv = zombie:getInventory()
    zombieInv:AddItem(amputationFullType)


    -- TODO Remove objects in that part of the body to prevent items floating in mid air
end

function ItemsController.Zombie.GetAmputationTexturesIndex(zombie)
    local x = zombie:getHumanVisual():getSkinTexture()

    -- Starting ID for zombies = 20
    -- 3 levels
    local matchedIndex = tonumber(x:match("ZedBody0(%d)")) - 1
    matchedIndex = matchedIndex * 3

    local level = tonumber(x:match("%d$")) - 1 -- it's from 1 to 3, but we're using it like 0 indexed arrays

    local finalId = 20 + matchedIndex + level
    --print("Zombie texture index: " .. tostring(finalId))
    return finalId
end

return ItemsController
