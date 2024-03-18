-- local ItemsController = require("TOC/Controllers/ItemsController")
-- local StaticData = require("TOC/StaticData")

-- --------------------

-- This is low priority, work on it AFTER everything else is ok

-- I doubt I can get this working, too many limitations

-- -------------------


-- ---@param zombie IsoZombie
-- ---@param character IsoPlayer
-- ---@param bodyPartType any
-- ---@param handWeapon any
-- local function test(zombie, character, bodyPartType, handWeapon)

--     -- LOCAL ONLY!!!
--     if character ~= getPlayer() then return end

--     -- For now, if there's a single TOC item on it don't go any further
--     local zombieVisuals = zombie:getItemVisuals()
--     if zombieVisuals == nil then return end
--     local zombieInv = zombie:getInventory()

--     local function predicate(item)
--         return (item:getType():contains("Amputation_"))
--     end
--     local foundItem = zombieInv:containsEvalRecurse(predicate)

--     if foundItem then
--         print("Item already in")
--         return
--     end




--     local clothingItemFullTypes = {}
--     -- Common function?
--     for i=1, #StaticData.LIMBS_STR do
--         local limbName = StaticData.LIMBS_STR[i]
--         local clothingName = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName
--         table.insert(clothingItemFullTypes, clothingName)
--     end

--     local index = ZombRand(1, #clothingItemFullTypes)
--     local randomFullType = clothingItemFullTypes[index]


--     local texId = ItemsController.Zombie.GetAmputationTexturesIndex(zombie)


--     local clothingInventoryItem = zombieInv:AddItem(randomFullType)
--     ---@cast clothingInventoryItem InventoryItem

--     clothingInventoryItem:getVisual():setTextureChoice(texId)
--     zombie:setWornItem(clothingInventoryItem:getBodyLocation(), clothingInventoryItem)

    
    
--     local itemVisual = ItemVisual:new()
--     itemVisual:setItemType(randomFullType)
--     itemVisual:setTextureChoice(texId)
--     zombieVisuals:add(itemVisual)
--     zombie:resetModelNextFrame()
    
--     --zombieInv = zombie:getInventory():add
--     -- foundItem = zombieInv:containsEvalRecurse(predicate)

--     -- print(foundItem)

    
--     -- zombieInv = zombie:getInventory()



--     --ItemsController.Zombie.SpawnAmputationItem(zombie, randomFullType)








--     -- local usableClothingAmputations = {}



--     -- local index = ZombRand(1, #usableClothingAmputations)
--     -- local amputationFullType = usableClothingAmputations[index]



-- end

-- Events.OnHitZombie.Add(test)