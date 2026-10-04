if isClient() then return end       -- The event makes this necessary to prevent clients from running this file
local StaticData = require("TOC/StaticData")
------------------------

local ServerDataHandler = {}
ServerDataHandler.modData = {}

---Get the server mod data table containing that player TOC data
---@param key string
---@return tocModDataType
function ServerDataHandler.GetTable(key)
    return ServerDataHandler.modData[key]
end

---Add table to the ModData and a local table
---@param key string
---@param table tocModDataType
function ServerDataHandler.AddTable(key, table)
    -- Check if key is valid
    if not luautils.stringStarts(key, StaticData.MOD_NAME .. "_") then return end

    TOC_DEBUG.print("Received TOC ModData: " .. tostring(key))
    --TOC_DEBUG.printTable(table)

    -- Set that the data has been modified and it's updated on the server
    ModData.add(key, table)     -- Add it to the server mod data
    ServerDataHandler.modData[key] = table


    -- Check integrity of table. if it doesn't contains toc data, it means that we received a reset 
    if table.limbs == nil then return end

end

Events.OnReceiveGlobalModData.Add(ServerDataHandler.AddTable)


return ServerDataHandler
