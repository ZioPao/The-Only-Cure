require("TOC/Debug")
require("NPCs/BodyLocations")
local StaticData = require("TOC/StaticData")

local BodyLocationsAPI = {}
local function customGetVal(obj, int) return getClassFieldVal(obj, getClassField(obj, int)) end
local group = BodyLocations.getGroup("Human")

---@type ArrayList
local list = customGetVal(group, 1)

---@param bodyLoc string
function BodyLocationsAPI.New(bodyLoc)
    local curItem
    if StaticData.COMPAT_42 then
        curItem = BodyLocation.new(group, bodyLoc) -- create new item
        group:getAllLocations():add(curItem) -- add to the list
    else
        curItem = group:getOrCreateLocation(bodyLoc) -- get current item - or create
    end
    return curItem
end

-- TODO Not sure if this method actually works as intende with b42, but for our use case it's fine...
---@param toRelocateOrCreate string
---@param locationElement string
---@param afterBoolean boolean
---@return BodyLocation
function BodyLocationsAPI.MoveOrCreateBeforeOrAfter(toRelocateOrCreate, locationElement, afterBoolean)
    -- Check type of arg 2 == string - if not error out.
    if type(locationElement) ~= "string" then error("Argument 2 is not of type string. Please re-check!", 2) end
    local itemToMoveTo = group:getLocation(locationElement) -- get location to move to
    if itemToMoveTo ~= nil then
        -- Check type of arg 1 == string - if not, error out.
        if type(toRelocateOrCreate) ~= "string" then error("Argument 1 is not of type string. Please re-check!", 2) end

        local curItem = BodyLocationsAPI.New(toRelocateOrCreate)
        list:remove(curItem) -- remove from the list
        local index = group:indexOf(locationElement) -- get current index after removal of the location to move to
        if afterBoolean then index = index + 1 end -- if we want it after it, we increase the index to move to by one
        list:add(index, curItem) -- we add the item again


        return curItem
    else -- we did not find the location to move to, so we throw an error.
        error("Could not find the BodyLocation [".. tostring(locationElement) .."] - please check the passed arguments!", 2)
    end
end



-- function TestBodyLocations()
--     local group = BodyLocations.getGroup("Human")
--     local x = group:getAllLocations()

--     for i=0, x:size() -1 do

--         ---@type BodyLocation
--         local bl = x:get(i)

--         print(bl:getId())
--     end
-- end

-- MultiItem causes a ton of issues... fucking hell

-- local curItem = BodyLocation.new(group, "TOC_Arm_L")
-- group:getAllLocations():add(curItem)

-- local curItem = BodyLocation.new(group, "TOC_Arm_R")
-- group:getAllLocations():add(curItem)


BodyLocationsAPI.New("TOC_Arm_L")
BodyLocationsAPI.New("TOC_Arm_R")
BodyLocationsAPI.New("TOC_ArmProst_L")
BodyLocationsAPI.New("TOC_ArmProst_R")
BodyLocationsAPI.New("TOC_ArmAccessory_L")
BodyLocationsAPI.New("TOC_ArmAccessory_R")