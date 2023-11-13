local StaticData = require("TOC/StaticData")

------------------------

local CommandsData = {}

CommandsData.modules = {
    TOC_DEBUG = "TOC_DEBUG"
}


CommandsData.client = {}

CommandsData.server = {
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


return CommandsData
