local StaticData = require("TOC/StaticData")

local CommandsData = {}


CommandsData.modules = {
    TOC_SYNC = "TOC_SYNC"
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
    }
}

---Get the correct key for that particular player to be used in the global mod data table
---@param username string
---@return string
function CommandsData.GetKey(username)
    return StaticData.MOD_NAME .. "_" .. username
end

return CommandsData