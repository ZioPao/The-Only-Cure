local StaticData = require("TOC_StaticData.lua")

----------------

---@class ModDataHandler
local ModDataHandler = {}

-- TODO This class should handle all the stuff related to the mod data

---...
---@param playerObj IsoPlayer
function ModDataHandler.Setup(playerObj)
    ModDataHandler.player = playerObj
end


--------------------

function ModDataHandler.GetModData()
    return ModDataHandler.player:getModData()[StaticData.MOD_NAME]
end