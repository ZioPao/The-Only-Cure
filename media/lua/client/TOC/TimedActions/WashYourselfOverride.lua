local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local StaticData = require("TOC/StaticData")

-- Since amputations are actually clothing items, we need to override ISWashYourself to account for that


local og_ISWashYourself_perform = ISWashYourself.perform
function ISWashYourself:perform()

    TOC_DEBUG.print("ISWashYourself override")

    ---@type IsoPlayer
    local pl = self.character
    local plInv = pl:getInventory()
    -- Search for amputations and clean them here
    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(pl:getUsername())
    for limbName, _ in pairs(amputatedLimbs) do

        TOC_DEBUG.print("Checking if " .. limbName .. " is in inventory and washing it")

        -- get clothing item 
        local foundItem = plInv:FindAndReturn(StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName)
        if foundItem and instanceof(foundItem, "Clothing") then

            TOC_DEBUG.print("Washing " .. limbName)

            ---@cast foundItem Clothing
            foundItem:setWetness(100)
            foundItem:setBloodLevel(0)
            foundItem:setDirtyness(0)       -- TODO Integrate with other dirtyness

        end

    end


    og_ISWashYourself_perform(self)


end