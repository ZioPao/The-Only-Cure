if isClient() then return end       -- The event makes this necessary to prevent clients from running this file
local StaticData = require("TOC/StaticData")
local CommandsData = require("TOC/CommandsData")
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
    table.isUpdateFromServer = true -- FIX this is useless as of now

    ModData.add(key, table)     -- Add it to the server mod data
    ServerDataHandler.modData[key] = table


    -- Check integrity of table. if it doesn't contains toc data, it means that we received a reset 
    if table.limbs == nil then return end

    -- Since this could be triggered by a different client than the one referenced in the key, we're gonna
    -- apply the changes back to the key client again to be sure that everything is in sync
    local username = CommandsData.GetUsername(key)
    TOC_DEBUG.print("Reapplying to " .. username)

    -- Since getPlayerFromUsername doesn't work in mp, we're gonna do this workaround. ew
    local onlinePlayers = getOnlinePlayers()
    local selectedPlayer
    for i=0, onlinePlayers:size() - 1 do

        ---@type IsoPlayer
        local player = onlinePlayers:get(i)
        if player:getUsername() == username then
            selectedPlayer = player
            break
        end
    end

    TOC_DEBUG.print("Player username from IsoPlayer: " .. selectedPlayer:getUsername())
    sendServerCommand(selectedPlayer, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveApplyFromServer, {})

end

Events.OnReceiveGlobalModData.Add(ServerDataHandler.AddTable)


return ServerDataHandler
