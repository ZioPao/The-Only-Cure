local StaticData = require("TOC/StaticData")
------------------------

local CommandsData = {}

CommandsData.modules = {
    TOC_DEBUG = "TOC_DEBUG",
    TOC_RELAY = "TOC_RELAY"
}

CommandsData.client = {
    Relay = {
        ReceiveDamageDuringAmputation = "ReceiveDamageDuringAmputation",            ---@alias receiveDamageDuringAmputationParams { limbName : string}
        ReceiveExecuteAmputationAction = "ReceiveExecuteAmputationAction"       ---@alias receiveExecuteAmputationActionParams {surgeonNum : number, limbName : string}
    }
}

CommandsData.server = {
    Debug = {
        PrintTocData = "PrintTocData",                                  ---@alias printTocDataParams {username : string}
        PrintAllTocData = "PrintAllTocData"
    },

    Relay = {
        RelayDamageDuringAmputation = "RelayDamageDuringAmputation",                ---@alias relayDamageDuringAmputationParams {patientNum : number, limbName : string}
        RelayExecuteAmputationAction = "RelayExecuteAmputationAction"         ---@alias relayExecuteAmputationActionParams {patientNum : number, limbName : string}

    }
}

---Get the correct key for that particular player to be used in the global mod data table
---@param username string
---@return string
function CommandsData.GetKey(username)
    return StaticData.MOD_NAME .. "_" .. username
end


return CommandsData
