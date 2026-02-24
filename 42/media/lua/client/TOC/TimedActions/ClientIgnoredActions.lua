-- TODO This section must be overhauled

local DataController = require("TOC/Controllers/DataController")
local StaticData = require("TOC/StaticData")

---@diagnostic disable: duplicate-set-field
-- Bunch of actions shouldn't be modified by the adjusted time 

-----------------------------------------------
---* Some actions have specific maxTime calculations and we must account for that
---ISAttachItemHotbar
---ISDetachItemHotbar
---ISEquipWeaponAction
---ISUnequipAction

--- We're forced to re-run this crap to fix it
---@param o ISBaseTimedAction
---@param maxTime number
local function OverrideAction(o, maxTime)
    -- TODO Add forced debuff instead of just relying on the vanilla values?
    o.skipTOC = true
    o.maxTime = maxTime
    o.animSpeed = 1.0
end


local og_ISDetachItemHotbar_new = ISDetachItemHotbar.new
function ISDetachItemHotbar:new(character, item)
    local action = og_ISDetachItemHotbar_new(self, character, item)
    OverrideAction(action, 25)      -- Default time for this action
    return action
end



------------------------------------------------------
--- Normal cases


local og_ISCampingInfoAction_new = ISCampingInfoAction.new
function ISCampingInfoAction:new(character, campfireObject, campfire)
    local action = og_ISCampingInfoAction_new(self, character, campfireObject, campfire)
    --TOC_DEBUG.print("Override ISCampingInfoAction")
    action.skipTOC = true
    return action
end







-- if StaticData.COMPAT_42 == false then
--     -- TODO confirm that this doesn't exist anymore in B42
--     -- B42 nenen
--     local og_ISFinalizeDealAction_new = ISFinalizeDealAction.new
--     function ISFinalizeDealAction:new(player, otherPlayer, itemsToGive, itemsToReceive, time)
--         local action = og_ISFinalizeDealAction_new(self, player, otherPlayer, itemsToGive, itemsToReceive, time)
--         --TOC_DEBUG.print("Override ISFinalizeDealAction")
--         action.skipTOC = true
--         return action
--     end

-- end


