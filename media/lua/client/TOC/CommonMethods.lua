local StaticData = require("TOC/StaticData")
-----------------------------------

local CommonMethods = {}

---@param val number
---@param min number
---@param max number
function CommonMethods.Normalize(val, min, max)
    if (max - min) == 0 then return 1 end
    return (val - min)/(max-min)

end

function CommonMethods.GetLimbNameFromBodyPart(bodyPart)
    local bodyPartTypeStr = BodyPartType.ToString(bodyPart:getType())
    return StaticData.LIMBS_IND_STR[bodyPartTypeStr]
end

---Returns the side for a certain limb or prosthesis
---@param name string
---@return string "L" or "R"
function CommonMethods.GetSide(name)
    if string.find(name, "_L") then return "L" else return "R" end
end

---Stops and start an event, making sure that we don't stack them up
---@param event string
---@param method function
function CommonMethods.SafeStartEvent(event, method)
    Events[event].Remove(method)
    Events[event].Add(method)
end

return CommonMethods