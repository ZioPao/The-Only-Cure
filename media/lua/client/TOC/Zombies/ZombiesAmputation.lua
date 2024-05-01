-- todo activate after some more testing


-- local ItemsController = require("TOC/Controllers/ItemsController")
-- local StaticData = require("TOC/StaticData")
-- local CommandsData = require("TOC/CommandsData")
-- -------------------------------

-- ---@param item InventoryItem
-- local function PredicateAmputationItems(item)
--     return item:getType():contains("Amputation_")
-- end



-- local function PredicateAmputationItemLeft(item)
--     return item:getType():contains("Amputation_") and item:getType():contains("_L")
-- end

-- local function PredicateAmputationItemRight(item)
--     return item:getType():contains("Amputation_") and item:getType():contains("_R")
-- end

-- ---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
-- ---@return integer trueID
-- local function GetZombieID(zombie)

--     -- Big love to Chuck and Sir Doggy Jvla for this code
-- ---@diagnostic disable-next-line: param-type-mismatch
--     local pID = zombie:getPersistentOutfitID()
--     local bits = string.split(string.reverse(Long.toUnsignedString(pID, 2)), "")
--     while #bits < 16 do bits[#bits+1] = 0 end

--     -- trueID
--     bits[16] = 0
--     local trueID = Long.parseUnsignedLong(string.reverse(table.concat(bits, "")), 2)

--     return trueID
-- end


-- ---@param zombie IsoZombie
-- local function SpawnAmputation(zombie, side)
--     local index = ZombRand(1, #StaticData.PARTS_STR)
--     local limb = StaticData.PARTS_STR[index] .. "_" .. side
--     local amputationFullType = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limb


--     ItemsController.Zombie.SpawnAmputationItem(zombie, amputationFullType)


--     -- Add reference and transmit it to server
--     local pID = GetZombieID(zombie)
--     local zombieKey = CommandsData.GetZombieKey()
--     local zombiesMD = ModData.getOrCreate(zombieKey)
--     if zombiesMD[pID] == nil then zombiesMD[pID] = {} end
--     zombiesMD[pID][side] = amputationFullType
--     ModData.add(zombieKey, zombiesMD)
--     ModData.transmit(zombieKey)
-- end

-- -------------------------------

-- ---@param player IsoGameCharacter
-- ---@param zombie IsoZombie
-- ---@param handWeapon HandWeapon
-- function HandleZombiesAmputations(player, zombie, handWeapon, damage)
--     if not instanceof(zombie, "IsoZombie") or not instanceof(player, "IsoPlayer") then return end
--     if player ~= getPlayer() then return end
    
--     -- TODO Check type of weapon. No hands, only knifes or such

    

--     if damage < 3 or ZombRand(0,100) < 25 then return end

--     TOC_DEBUG.print(handWeapon:getName())


--     local zombieInv = zombie:getInventory()


--     -- Check left or right
--     local leftItem = zombieInv:containsEval(PredicateAmputationItemLeft)

--     if not leftItem then
--         SpawnAmputation(zombie, "L")
--         return
--     end


--     local rightItem = zombieInv:containsEval(PredicateAmputationItemRight)
--     if not rightItem then
--         SpawnAmputation(zombie, "R")
--         return
--     end
-- end


-- Events.OnWeaponHitCharacter.Add(HandleZombiesAmputations)

-- -----------------------------

-- local localOnlyZombiesMD

-- local function SetupZombiesModData()
--     local zombieKey = CommandsData.GetZombieKey()
--     localOnlyZombiesMD = ModData.getOrCreate(zombieKey)

-- end

-- Events.OnInitGlobalModData.Add(SetupZombiesModData)




-- ---@param zombie IsoZombie
-- local function ReapplyAmputation(zombie)
--     local pID = GetZombieID(zombie)

--     if localOnlyZombiesMD[pID] ~= nil then
--         -- check if zombie has amputation
--         local zombiesAmpData = localOnlyZombiesMD[pID]
--         local zombieInv =  zombie:getInventory()
--         local foundItem = zombieInv:containsEvalRecurse(PredicateAmputationItems)

--         if foundItem then
--             return
--         else
--             local leftAmp = zombiesAmpData['L']
--             if leftAmp then
--                 ItemsController.Zombie.SpawnAmputationItem(zombie, leftAmp)
--             end

--             local rightAmp = zombiesAmpData['R']
--             if rightAmp then
--                 ItemsController.Zombie.SpawnAmputationItem(zombie, rightAmp)
--             end

--             -- Removes reference, local only
--             localOnlyZombiesMD[pID] = nil
--         end
--     end
-- end

-- Events.OnZombieUpdate.Add(ReapplyAmputation)





