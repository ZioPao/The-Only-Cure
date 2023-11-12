TOC_DEBUG = {}
TOC_DEBUG.disablePaneMod = false


function TOC_DEBUG.togglePaneMod()
    TOC_DEBUG.disablePaneMod = not TOC_DEBUG.disablePaneMod
end

---comment
---@param string string
function TOC_DEBUG.print(string)
    if isDebugEnabled() then
        print("TOC: " .. string)
    end
end