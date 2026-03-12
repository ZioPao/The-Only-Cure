local ExpActions = require("TOC/ExpActions")
local CommandsData = require("TOC/CommandsData")

local XP_PER_TICK = 0.01

---Adds TOC XP via relay for client-side actions (MP client only).
---@param action ISBaseTimedAction
local function AddTOCXpRelay(action)
    ExpActions.IterateTOCXp(action, function(_, perkName)
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayAddXp, {perkName = perkName, xp = XP_PER_TICK})
    end)
end

--* ISInventoryTransferAction runs on the client, so it needs the relay exception
local og_ISInventoryTransferAction_update = ISInventoryTransferAction.update
---@diagnostic disable-next-line: duplicate-set-field
function ISInventoryTransferAction:update()
    og_ISInventoryTransferAction_update(self)
    AddTOCXpRelay(self)
end
