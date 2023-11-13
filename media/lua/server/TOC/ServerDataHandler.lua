if isClient() then return end





local ServerDataHandler = {}
ServerDataHandler.modData = {}

---Get the server mod data table containing that player TOC data
---@param key string
---@return tocModData
function ServerDataHandler.GetTable(key)
    return ServerDataHandler.modData[key]
end


function ServerDataHandler.AddTable(key, table)
    ModData.add(key, table)     -- Add it to the server mod data
    ServerDataHandler.modData[key] = table
end

Events.OnReceiveGlobalModData.Add(ServerDataHandler.AddTable)


return ServerDataHandler
