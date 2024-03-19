-- TODO This part is still one of the weakest and we don't have a better solution yet
require("TOC/Debug")
require("NPCs/BodyLocations")

local BodyLocationsAPI = {}
local function customGetVal(obj, int) return getClassFieldVal(obj, getClassField(obj, int)) end
local group = BodyLocations.getGroup("Human")
local list = customGetVal(group, 1)

---@param toRelocateOrCreate string
---@param locationElement string
---@param afterBoolean boolean
---@return BodyLocation
function BodyLocationsAPI:moveOrCreateBeforeOrAfter(toRelocateOrCreate, locationElement, afterBoolean)
    -- Check type of arg 2 == string - if not error out.
    if type(locationElement) ~= "string" then error("Argument 2 is not of type string. Please re-check!", 2) end
    local itemToMoveTo = group:getLocation(locationElement) -- get location to move to
    if itemToMoveTo ~= nil then
        -- Check type of arg 1 == string - if not, error out.
        if type(toRelocateOrCreate) ~= "string" then error("Argument 1 is not of type string. Please re-check!", 2) end
        local curItem = group:getOrCreateLocation(toRelocateOrCreate) -- get current item - or create
        list:remove(curItem) -- remove from the list
        local index = group:indexOf(locationElement) -- get current index after removal of the location to move to
        if afterBoolean then index = index + 1 end -- if we want it after it, we increase the index to move to by one
        list:add(index, curItem) -- we add the item again
        return curItem
    else -- we did not find the location to move to, so we throw an error.
        error("Could not find the BodyLocation [",locationElement,"] - please check the passed arguments!", 2)
    end
end

---@param toRelocateOrCreate string
---@param locationElement string
---@return BodyLocation
function BodyLocationsAPI.moveOrCreateBefore(toRelocateOrCreate, locationElement) -- for simpler and clearer usage
    return BodyLocationsAPI.moveOrCreateBeforeOrAfter(toRelocateOrCreate, locationElement, false)
end


---@param toRelocateOrCreate string
---@param locationElement string
---@return BodyLocation
function BodyLocationsAPI.moveOrCreateAfter(toRelocateOrCreate, locationElement) -- for simpler and clearer usage
    return BodyLocationsAPI.moveOrCreateBeforeOrAfter(toRelocateOrCreate, locationElement, true)
end

---@param loc1 string
---@param alias string
---@return BodyLocation
function BodyLocationsAPI.removeAlias(loc1, alias) -- will remove 2nd arg (alias) from location 1
    local item = group:getLocation(loc1)
    if item ~= nil and type(alias) == "string" then
        local aliases = customGetVal(item, 2)
        aliases:remove(alias)
    end
    return item
end

---@param loc1 string
---@param loc2 string
---@return BodyLocation
function BodyLocationsAPI.unsetExclusive(loc1, loc2) -- will remove exclusive from each other
    local item1 = group:getLocation(loc1)
    local item2 = group:getLocation(loc2)
    if item1 ~= nil and item2 ~= nil then
        local exclusives1 = customGetVal(item1, 3)
        exclusives1:remove(loc2)
        local exclusives2 = customGetVal(item2, 3)
        exclusives2:remove(loc1)
    end
    return item1
end

---@param loc1 string
---@param loc2 string
---@return BodyLocation
function BodyLocationsAPI.unhideModel(loc1, loc2) -- remove loc2 from loc1's hidemodel list
    local item1 = group:getLocation(loc1)
    local item2 = group:getLocation(loc2)
    if item1 ~= nil and item2 ~= nil then
        local hidemodels = customGetVal(item1, 4)
        hidemodels:remove(loc2)
    end
    return item1
end
-- AddBodyLocationBefore("TOC_Arm_R", "Shoes")
-- AddBodyLocationBefore("TOC_Arm_L", "Shoes")

-- AddBodyLocationBefore("TOC_ArmProst_R", "TOC_Arm_R")
-- AddBodyLocationBefore("TOC_ArmProst_L", "TOC_Arm_L")

-- Locations must be declared in render-order.
-- Location IDs must match BodyLocation= and CanBeEquipped= values in items.txt.
function TestBodyLocations()
    local group = BodyLocations.getGroup("Human")
    local x = group:getAllLocations()

    for i=0, x:size() -1 do

        ---@type BodyLocation
        local bl = x:get(i)

        print(bl:getId())
    end

end



-- TODO Breaks if both arms are cut with one prost!!!
-- TODO Breaks even if you have both amputations in general. We need a way to fix this piece of shit before realising
group:getOrCreateLocation("TOC_Arm_R")
group:getOrCreateLocation("TOC_Arm_L")

group:getOrCreateLocation("TOC_ArmProst_R")
group:getOrCreateLocation("TOC_ArmProst_L")
