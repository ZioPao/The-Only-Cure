local CommonMethods = {}

---Returns the side for a certain limb or prosthesis
---@param name string
---@return string "L" or "R"
function CommonMethods.GetSide(name)
    if string.find(name, "_L") then return "L" else return "R" end
end

---comment
---@param bodyPart BodyPart
function CommonMethods.GetLimbNameFromBodyPart(bodyPart)
    local bodyPartType = bodyPart:getType()
    
end
return CommonMethods