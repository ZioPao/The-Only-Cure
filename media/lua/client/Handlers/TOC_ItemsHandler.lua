local StaticData = require("TOC_StaticData")
local CommonMethods = require("TOC_Common")

---------------------------

--- Submodule to handle spawning the correct items after certain actions (ie: cutting a hand)
---@class ItemsHandler
local ItemsHandler = {}

---Returns the correct index for the textures of the amputation
---@param isCicatrized boolean
---@return number
---@private
function ItemsHandler.GetAmputationTexturesIndex(playerObj, isCicatrized)
    local textureString = playerObj:getHumanVisual():getSkinTexture()
    local isHairy = string.find(textureString, "a$")
    -- Hairy bodies
    if isHairy then
        textureString = textureString:sub(1, -2)      -- Removes b at the end to make it compatible
    end

    local matchedIndex = string.match(textureString, "%d$")

    -- TODO Rework this
    if isHairy then
        matchedIndex = matchedIndex + 5
    end

    if isCicatrized then
        if isHairy then
            matchedIndex = matchedIndex + 5           -- to use the cicatrized texture on hairy bodies
        else
            matchedIndex = matchedIndex + 10          -- cicatrized texture only, no hairs
        end
    end

    return matchedIndex - 1
end

---Main function to delete a clothing item
---@param playerObj IsoPlayer
---@param clothingItem InventoryItem?
---@return boolean
---@private
function ItemsHandler.RemoveClothingItem(playerObj, clothingItem)
    if clothingItem and instanceof(clothingItem, "InventoryItem") then
        playerObj:removeWornItem(clothingItem)

        playerObj:getInventory():Remove(clothingItem)       -- Can be a InventoryItem too.. I guess? todo check it
        print("TOC: found and deleted " .. tostring(clothingItem))
        return true
    end
    return false
end

---Search and deletes an old amputation clothing item on the same side
---@param playerObj IsoPlayer
---@param limbName string
function ItemsHandler.DeleteOldAmputationItem(playerObj, limbName)
    local side = CommonMethods.GetSide(limbName)
    for partName, _ in pairs(StaticData.PARTS_STRINGS) do
        local othLimbName = partName .. "_" .. side
        local othClothingItemName = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. othLimbName

        -- TODO FindAndReturn could return an ArrayList. We need to check for that
        local othClothingItem = playerObj:getInventory():FindAndReturn(othClothingItemName)


        -- If we manage to find and remove an item, then we should stop this function.
        ---@cast othClothingItem InventoryItem
        if ItemsHandler.RemoveClothingItem(playerObj, othClothingItem) then return end
    end
end

---Deletes all the old amputation items, used for resets
---@param playerObj IsoPlayer
function ItemsHandler.DeleteAllOldAmputationItems(playerObj)

    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        local clothItemName = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName
        local clothItem = playerObj:getInventory():FindAndReturn(clothItemName)
        ---@cast clothItem InventoryItem
        ItemsHandler.RemoveClothingItem(playerObj, clothItem)
    end
end

---Spawns and equips the correct amputation item to the player.
function ItemsHandler.SpawnAmputationItem(playerObj, limbName)
    print("Clothing name " .. StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName)
    local clothingItem = playerObj:getInventory():AddItem(StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName)
    local texId = ItemsHandler.GetAmputationTexturesIndex(playerObj, false)

    ---@cast clothingItem InventoryItem
    clothingItem:getVisual():setTextureChoice(texId) -- it counts from 0, so we have to subtract 1
    playerObj:setWornItem(clothingItem:getBodyLocation(), clothingItem)
end

--------------------------
--* Overrides *--

local og_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer

---Get the list of items for the container and remove the reference to the amputation items
function ISInventoryPane:refreshContainer()
    og_ISInventoryPane_refreshContainer(self)
    if TOC_DEBUG.disablePaneMod then return end
    for i=1, #self.itemslist do
        local cItem = self.itemslist[i]
        if cItem and cItem.cat == "Amputation" then
            --print("TOC: current item is an amputation, removing it from the list")
            table.remove(self.itemslist, i)
        end
    end
end

return ItemsHandler