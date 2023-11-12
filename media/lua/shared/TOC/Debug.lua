TOC_DEBUG = {}
TOC_DEBUG.disablePaneMod = false


function TOC_DEBUG.togglePaneMod()
    TOC_DEBUG.disablePaneMod = not TOC_DEBUG.disablePaneMod
end

---Print debug
---@param string string
function TOC_DEBUG.print(string)
    if isDebugEnabled() then
        print("TOC: " .. string)
    end
end

function TOC_DEBUG.printTable(table, indent)
    if not table then return end
    indent = indent or ""

    for key, value in pairs(table) do
        if type(value) == "table" then
            print(indent .. key .. " (table):")
            TOC_DEBUG.printTable(value, indent .. "  ")
        else
            print(indent .. key .. ":", value)
        end
    end
end

function TOC_DEBUG.printGlobalModDataServer(username)
    local CommandsData = require("TOC/CommandsData")

    ---@type printTocDataParams
    local params = {username = username}
    sendClientCommand(CommandsData.modules.TOC_DEBUG, CommandsData.server.Debug.PrintTocData, params)
end