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
        ReceiveExecuteAmputationAction = "ReceiveExecuteAmputationAction",       ---@alias receiveExecuteAmputationActionParams {surgeonNum : number, limbName : string, damagePlayer : boolean}

        --* APPLY *--
        ReceiveApplyFromServer = "ReceiveApplyFromServer",

        --* ADMIN ONLY --*
        ReceiveExecuteInitialization = "ReceiveExecuteInitialization",
        ReceiveForcedCicatrization = "ReceiveForcedCicatrization"               ---@alias receiveForcedCicatrizationParams {limbName : string}
    }
}

CommandsData.server = {
    Debug = {
        PrintTocData = "PrintTocData",                                  ---@alias printTocDataParams {username : string}
        PrintAllTocData = "PrintAllTocData"
    },

    Relay = {
        RelayDamageDuringAmputation = "RelayDamageDuringAmputation",                ---@alias relayDamageDuringAmputationParams {patientNum : number, limbName : string}
        RelayExecuteAmputationAction = "RelayExecuteAmputationAction",              ---@alias relayExecuteAmputationActionParams {patientNum : number, limbName : string}
        
        --* ADMIN ONLY *--
        RelayExecuteInitialization = "RelayExecuteInitialization",                                ---@alias relayExecuteInitializationParams {patientNum : number}
        RelayForcedAmputation = "RelayForcedAmputation"                                           ---@alias relayForcedAmputationParams {patientNum : number, limbName : string}
    }
}

---Get the correct key for that particular player to be used in the global mod data table
---@param username string
---@return string
function CommandsData.GetKey(username)
    return StaticData.MOD_NAME .. "_" .. username
end

function CommandsData.GetUsername(key)
    return string.sub(key, #StaticData.MOD_NAME + 2, #key)      -- Not sure why +2... Something with kahlua, it should be +1
end

function CommandsData.GetZombieKey()
    return StaticData.MOD_NAME .. "_ZOMBIES"
end


return CommandsData
