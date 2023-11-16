local ItemsHandler = require("TOC/Handlers/ItemsHandler")

--------------------

-- TODO This is low priority, work on it AFTER everything else is ok


-------------------

local function test(zombie, character, bodyPartType, handWeapon)
    --ItemsHandler.Zombie.SpawnAmputationItem(zombie)
end

Events.OnHitZombie.Add(test)


-- local function test2(zombie, player, handWeapon, damage)
--     if not instanceof(zombie, "IsoZombie") then return end

--     print(zombie)
    
-- end

-- Events.OnWeaponHitCharacter.Add(test2)