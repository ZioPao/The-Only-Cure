local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local CommonMethods = require("TOC/CommonMethods")
local CommandsData = require("TOC/CommandsData")

local XP_PER_TICK = 0.01

---Adds TOC XP via relay for client-side actions (MP client only).
---@param action ISBaseTimedAction
local function AddTOCXpRelay(action)
    ---@diagnostic disable-next-line: undefined-field
    if action.skipTOC or action.noExp then return end

    local character = action.character
    local username = character:getUsername()
    local dcInst = DataController.GetInstance(username)
    if not dcInst or not dcInst:getIsAnyLimbCut() then return end

    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(username)
    if not amputatedLimbs then return end

    for limbName, _ in pairs(amputatedLimbs) do
        if dcInst:getIsCut(limbName) and dcInst:getIsVisible(limbName) then
            local side = CommonMethods.GetSide(limbName)
            local perkName = "Side_" .. side
            local ampLevel = character:getPerkLevel(Perks[perkName])
            TOC_DEBUG.print("AddTOCXpRelay | " .. perkName .. "=" .. tostring(ampLevel))
            if ampLevel < 10 then
                sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayAddXp, {perkName = perkName, xp = XP_PER_TICK})
            end
            if dcInst:getIsProstEquipped(limbName) then
                local prostLevel = character:getPerkLevel(Perks["ProstFamiliarity"])
                TOC_DEBUG.print("AddTOCXpRelay | ProstFamiliarity=" .. tostring(prostLevel))
                if prostLevel < 10 then
                    sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayAddXp, {perkName = "ProstFamiliarity", xp = XP_PER_TICK})
                end
            end
        end
    end
end

--* ISInventoryTransferAction runs on the client, so it needs the relay exception
local og_ISInventoryTransferAction_update = ISInventoryTransferAction.update
---@diagnostic disable-next-line: duplicate-set-field
function ISInventoryTransferAction:update()
    og_ISInventoryTransferAction_update(self)
    AddTOCXpRelay(self)
end
