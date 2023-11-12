local CommandsData = {}


CommandsData.modules = {
    TOC_SYNC = "TOC_SYNC"
}


CommandsData.client = {
    Sync = {
        SendPlayerData = "SendPlayerData",
        ReceivePlayerData = "ReceivePlayerData"
    }
}

CommandsData.server = {
    Sync = {
        AskPlayerData = "AskPlayerData",
        RelayPlayerData = "RelayPlayerData"
    }
}

return CommandsData