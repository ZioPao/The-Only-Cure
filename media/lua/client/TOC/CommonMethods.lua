local CommonMethods = {}

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