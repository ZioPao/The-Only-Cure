-- TODO Switch EVERYTHING to global mod data

local CommandsData = require("TOC/CommandsData")

local ServerDataCommands = {}
local moduleName = "test_sync"


local function PrintModDataTable(key, table)
    print("Received key: " .. key)
end


Events.OnReceiveGlobalModData.Add(PrintModDataTable)



-- TODO Consider delays




-- TODO Use transmit from client
-- ---comment
-- ---@param playerObj IsoPlayer
-- ---@param args any
-- function ServerDataCommands.AddTable(playerObj, args)
--     ModData.add(GetKey(playerObj), args.tocData)
-- end


-- function ServerDataCommands.GetTable(playerObj, args)
--     local requestedPlayer = getSpecificPlayer(args.playerNum)
--     local data = ModData.get(CommandsData.GetKey(requestedPlayer))

--     -- TODO Request from that client again just to be sure that it's synced?

--     sendServerCommand()
-- end



------------------------------

-- local function OnClientDataCommand(module, command, playerObj, args)
--     if module == moduleName and ServerDataCommands[command] then
--         ServerDataCommands[command](playerObj, args)
--     end
-- end

-- Events.OnClientCommand.Add(OnClientDataCommand)



