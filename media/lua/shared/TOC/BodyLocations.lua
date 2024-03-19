require("TOC/Debug")
require("NPCs/BodyLocations")

local BodyLocationsAPI = {}
local function customGetVal(obj, int) return getClassFieldVal(obj, getClassField(obj, int)) end
local group = BodyLocations.getGroup("Human")

---@type ArrayList
local list = customGetVal(group, 1)

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
        local curItem = group:getOrCreateLocation(toRelocateOrCreate) -- get current item - or create
        list:remove(curItem) -- remove from the list
        local index = group:indexOf(locationElement) -- get current index after removal of the location to move to
        if afterBoolean then index = index + 1 end -- if we want it after it, we increase the index to move to by one
        list:add(index, curItem) -- we add the item again


        return curItem
    else -- we did not find the location to move to, so we throw an error.
        error("Could not find the BodyLocation [".. tostring(locationElement) .."] - please check the passed arguments!", 2)
    end
end

function TestBodyLocations()
    local group = BodyLocations.getGroup("Human")
    local x = group:getAllLocations()

    for i=0, x:size() -1 do

        ---@type BodyLocation
        local bl = x:get(i)

        print(bl:getId())
    end

end

local locationArm = BodyLocationsAPI.MoveOrCreateBeforeOrAfter("TOC_Arm", "FullTop", true)
locationArm:setMultiItem(true)


local locationArmProst = BodyLocationsAPI.MoveOrCreateBeforeOrAfter("TOC_ArmProst", "TOC_Arm", true)
locationArmProst:setMultiItem(true)
