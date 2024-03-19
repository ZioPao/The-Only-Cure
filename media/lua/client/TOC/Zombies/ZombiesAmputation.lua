local ItemsController = require("TOC/Controllers/ItemsController")
local StaticData = require("TOC/StaticData")
local CommandsData = require("TOC/CommandsData")
-------------------------------

---@param item InventoryItem
local function PredicateAmputationItems(item)
    return item:getType():contains("Amputation_")
end


---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
---@return integer trueID
local function GetZombieID(zombie)

    -- Big love to Chuck and Sir Doggy Jvla for this code
    local pID = zombie:getPersistentOutfitID()
    local bits = string.split(string.reverse(Long.toUnsignedString(pID, 2)), "")
    while #bits < 16 do bits[#bits+1] = 0 end

    -- trueID
    bits[16] = 0
    local trueID = Long.parseUnsignedLong(string.reverse(table.concat(bits, "")), 2)

    return trueID
end

-------------------------------

---@param zombie IsoZombie
function HandleZombiesAmputations(zombie, character, bodyPartType, handWeapon)
    local zombieInv = zombie:getInventory()
    local foundItem = zombieInv:containsEvalRecurse(PredicateAmputationItems)

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
        local amputationFullType = clothingItemFullTypes[index]


        ItemsController.Zombie.SpawnAmputationItem(zombie, amputationFullType)


        -- TODO Add reference and transmit it to server
        local pID = GetZombieID(zombie)
        local zombieKey = CommandsData.GetZombieKey()
        local zombiesMD = ModData.getOrCreate(zombieKey)
        zombiesMD[pID] = amputationFullType
        ModData.add(zombieKey, zombiesMD)
        ModData.transmit(zombieKey)
    end
end


Events.OnHitZombie.Add(HandleZombiesAmputations)

-----------------------------


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
        local foundItem = zombieInv:containsEvalRecurse(PredicateAmputationItems)

        if foundItem then
            return
        else
            AddZombieAmp(zombie, fullType)

        end
    end
end

Events.OnZombieUpdate.Add(ReapplyAmputation)
