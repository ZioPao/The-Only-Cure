local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local StaticData = require("TOC/StaticData")

-- Since amputations are actually clothing items, we need to override ISWashYourself to account for that

-- TODO Clean this up

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

            local coveredParts = BloodClothingType.getCoveredParts(foundItem:getBloodClothingType())
            for j=0, coveredParts:size() - 1 do
                foundItem:setBlood(coveredParts:get(j), 0)
				foundItem:setDirt(coveredParts:get(j), 0)
            end
        end

    end


    og_ISWashYourself_perform(self)


end


local og_ISWashYourself_GetRequiredWater = ISWashYourself.GetRequiredWater


---@param character IsoPlayer
---@return integer
function ISWashYourself.GetRequiredWater(character)

    local units = og_ISWashYourself_GetRequiredWater(character)
    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(character:getUsername())
    local plInv = character:getInventory()
    for limbName, _ in pairs(amputatedLimbs) do

        TOC_DEBUG.print("Checking if " .. limbName .. " is in inventory and washing it")

        -- get clothing item 
        local item = plInv:FindAndReturn(StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. limbName)
        if item and instanceof(item, "Clothing") then
            local coveredParts = BloodClothingType.getCoveredParts(item:getBloodClothingType())
            if coveredParts then
                for i=1,coveredParts:size() do
                    local part = coveredParts:get(i-1)
                    if item:getBlood(part) > 0 then
                        units = units + 1
                    end
                end
            end
        end

    end

	return units
end