local CommonMethods = {}

---Returns the side for a certain limb
---@param limbName string
---@return string "L" or "R"
function CommonMethods.GetSide(limbName)
    if string.find(limbName, "_L") then return "L" else return "R" end
end

return CommonMethods