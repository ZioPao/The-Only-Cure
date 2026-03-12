local og_ISObjectClickHandler_doClickSpecificObject = ISObjectClickHandler.doClickSpecificObject

---@param object IsoObject
---@param playerNum any
---@param playerObj IsoPlayer
function ISObjectClickHandler.doClickSpecificObject(object, playerNum, playerObj)
    local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
    if playerObj and CachedDataHandler.GetBothHandsFeasibility(playerObj:getUsername()) then
        og_ISObjectClickHandler_doClickSpecificObject(object, playerNum, playerObj)
    end

    return false
end
