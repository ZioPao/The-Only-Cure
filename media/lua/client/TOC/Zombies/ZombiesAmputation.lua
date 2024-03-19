local ItemsController = require("TOC/Controllers/ItemsController")
local StaticData = require("TOC/StaticData")
local CommandsData = require("TOC/CommandsData")


local trackedZombies = {
    [412412] = {
        "FullTypeTest"
    }
}


local function predicate(item)
    return (item:getType():contains("Amputation_"))
end

---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
---@return integer trueID
local function GetZombieID(zombie)
    local pID = zombie:getPersistentOutfitID()
    local bits = string.split(string.reverse(Long.toUnsignedString(pID, 2)), "")
    while #bits < 16 do bits[#bits+1] = 0 end

    -- trueID
    bits[16] = 0
    local trueID = Long.parseUnsignedLong(string.reverse(table.concat(bits, "")), 2)

    return trueID
end



---@param zombie IsoZombie
---@param fullType string
local function AddZombieAmp(zombie, fullType)
    local texId = ItemsController.Zombie.GetAmputationTexturesIndex(zombie)
    local zombieVisuals = zombie:getItemVisuals()
    local itemVisual = ItemVisual:new()
    itemVisual:setItemType(fullType)
    itemVisual:setTextureChoice(texId)
    zombieVisuals:add(itemVisual)
    zombie:resetModelNextFrame()

    local zombieInv = zombie:getInventory()
    zombieInv:AddItem(fullType)
end



---@param zombie IsoZombie
function TestZombieThing(zombie)
    local zombieInv = zombie:getInventory()

    local foundItem = zombieInv:containsEvalRecurse(predicate)

    if foundItem then
        print("Item already in")
        return
    else

        local clothingItemFullTypes = {}
        -- Common function?
        for i=1, #StaticData.LIMBS_STR do
            local limbName = StaticData.LIMBS_STR[i]
            local clothingName = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName
            table.insert(clothingItemFullTypes, clothingName)
        end

        local index = ZombRand(1, #clothingItemFullTypes)
        local randomFullType = clothingItemFullTypes[index]


        AddZombieAmp(zombie, randomFullType)


        -- TODO Add reference and transmit it to server
        local pID = GetZombieID(zombie)
        local zombieKey = CommandsData.GetZombieKey()
        local zombiesMD = ModData.getOrCreate(zombieKey)
        zombiesMD[pID] = randomFullType
        ModData.add(zombieKey, zombiesMD)
        ModData.transmit(zombieKey)
    end
end



---@param zombie IsoZombie
---@param character any
---@param bodyPartType any
---@param handWeapon any
local function test(zombie, character, bodyPartType, handWeapon)
    TestZombieThing(zombie)
end
















Events.OnHitZombie.Add(test)








---@param zombie IsoZombie
local function ReapplyAmputation(zombie)
    local zombieKey = CommandsData.GetZombieKey()
    local zombiesMD = ModData.getOrCreate(zombieKey)
    local pID = GetZombieID(zombie)

    -- TODO Remove already checked zombies
    if zombiesMD[pID] ~= nil then
        -- check if zombie has amputation
        local fullType = zombiesMD[pID]
        local zombieInv =  zombie:getInventory()
        local foundItem = zombieInv:containsEvalRecurse(predicate)

        if foundItem then
            return
        else
            AddZombieAmp(zombie, fullType)

        end
    end
end




Events.OnZombieUpdate.Add(ReapplyAmputation)



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

