local StaticData = require("TOC/StaticData")

local CommandsData = {}


CommandsData.modules = {
    TOC_SYNC = "TOC_SYNC",
    TOC_DEBUG = "TOC_DEBUG"
}


CommandsData.client = {
    Sync = {
        SendPlayerData = "SendPlayerData",          ---@alias sendPlayerDataParams {surgeonNum : number}
        ReceivePlayerData = "ReceivePlayerData"     ---@alias receivePlayerDataParams {patientNum : number, tocData : tocModData}
    }
}

CommandsData.server = {
    Sync = {
        AskPlayerData = "AskPlayerData",            ---@alias askPlayerDataParams {patientNum : number}
        RelayPlayerData = "RelayPlayerData"         ---@alias relayPlayerDataParams {surgeonNum : number, tocData : tocModData}
    },

    Debug = {
        PrintTocData = "PrintTocData",              ---@alias printTocDataParams {username : string}
        PrintAllTocData = "PrintAllTocData"
    }
}

---Get the correct key for that particular player to be used in the global mod data table
---@param username string
---@return string
function CommandsData.GetKey(username)
    return StaticData.MOD_NAME .. "_" .. username
end

-- ---comment
-- ---@param key string
-- ---@return string
-- function CommandsData.GetUsernameFromKey(key)
--     local subSize = #StaticData.MOD_NAME + 1
--     local username = key:sub(subSize)
--     return username
-- end

return CommandsData