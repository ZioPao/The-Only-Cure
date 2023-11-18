if isClient() then return end       -- The event makes this necessary to prevent clients from running this file
local StaticData = require("TOC/StaticData")
------------------------

local ServerDataHandler = {}
ServerDataHandler.modData = {}


---Get the server mod data table containing that player TOC data
---@param key string
---@return tocModData
function ServerDataHandler.GetTable(key)
    return ServerDataHandler.modData[key]
end

---Add table to the ModData and a local table
---@param key string
---@param table tocModData
function ServerDataHandler.AddTable(key, table)
    -- Check if key is valid
    if not luautils.stringStarts(key, StaticData.MOD_NAME .. "_") then return end

    TOC_DEBUG.print("received TOC ModData: " .. tostring(key))
    ModData.add(key, table)     -- Add it to the server mod data
    ServerDataHandler.modData[key] = table
end

Events.OnReceiveGlobalModData.Add(ServerDataHandler.AddTable)


return ServerDataHandler
