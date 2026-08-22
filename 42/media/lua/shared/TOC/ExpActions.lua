local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local CommonMethods = require("TOC/CommonMethods")
local CommandsData = require("TOC/CommandsData")

local XP_PER_TICK = 0.01

---Iterates all valid amputated limbs and calls applyXp(character, perkName) for each.
---Shared logic — no XP mechanism assumed.
---@param action ISBaseTimedAction
---@param applyXp fun(character: IsoPlayer, perkName: string)
local function IterateTOCXp(action, applyXp)
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
            local perkName = "Side_" .. CommonMethods.GetSide(limbName)
            if character:getPerkLevel(Perks[perkName]) < 10 then
                --TOC_DEBUG.print("IterateTOCXp | " .. perkName)
                applyXp(character, perkName)
            end
            if dcInst:getIsProstEquipped(limbName) and character:getPerkLevel(Perks["ProstFamiliarity"]) < 10 then
                --TOC_DEBUG.print("IterateTOCXp | ProstFamiliarity")
                applyXp(character, "ProstFamiliarity")
            end
        end
    end
end

---CLIENT: send what an action accumulated, one packet per perk, and clear it.
---@param action ISBaseTimedAction
local function FlushTOCXp(action)
    ---@diagnostic disable-next-line: undefined-field
    local acc = action.tocXpAccumulator
    if not acc then return end
    ---@diagnostic disable-next-line: inject-field
    action.tocXpAccumulator = nil

    for perkName, xp in pairs(acc) do
        if xp > 0 then
            sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayAddXp,
                {perkName = perkName, xp = xp})
        end
    end
end

-- TODO Confirm this
---Adds TOC XP for one tick: directly via addXp() on the server and in SP, or
---accumulated for relay on a client.
---
---This used to be `if isClient() then return end`, leaving the work to the server.
---The server never does it: ISBaseTimedAction:update() is only ever ticked by the
---ISTimedActionQueue of the client that owns the character, so a dedicated server
---never calls update() on a player's timed action even though these classes exist
---server-side. The client bailed out, the server was never asked, and no XP was
---granted anywhere in MP.
---
---Clients accumulate and flush once when the action ends rather than relaying per
---tick, because update() runs every frame - a per-tick sendClientCommand would be
---roughly 120 packets for a two-second action.
---@param action ISBaseTimedAction
local function AddTOCXp(action)
    if isClient() then
        IterateTOCXp(action, function(_, perkName)
            ---@diagnostic disable-next-line: undefined-field
            local acc = action.tocXpAccumulator
            if not acc then
                acc = {}
                ---@diagnostic disable-next-line: inject-field
                action.tocXpAccumulator = acc
            end
            acc[perkName] = (acc[perkName] or 0) + XP_PER_TICK
        end)
        return
    end

    IterateTOCXp(action, function(character, perkName)
        addXp(character, Perks[perkName], XP_PER_TICK)
    end)
end

-- TODO Confirm this
--* The flush hooks go on ISBaseTimedAction rather than on each wrapped subclass.
--* Every timed action ends by calling up into ISBaseTimedAction.perform / .stop, so
--* one pair of wraps covers all of them - and unlike assigning perform/stop onto
--* each subclass, it does not freeze an inherited method as an own field on 20+
--* classes and block another mod from overriding it later.
if isClient() then
    local og_ISBaseTimedAction_perform = ISBaseTimedAction.perform
    ---@diagnostic disable-next-line: duplicate-set-field
    function ISBaseTimedAction:perform()
        FlushTOCXp(self)
        og_ISBaseTimedAction_perform(self)
    end

    local og_ISBaseTimedAction_stop = ISBaseTimedAction.stop
    ---@diagnostic disable-next-line: duplicate-set-field
    function ISBaseTimedAction:stop()
        FlushTOCXp(self)
        og_ISBaseTimedAction_stop(self)
    end
end

---Wraps an action class's update() to inject TOC XP each tick.
---Safely skips if the class is nil (e.g. not loaded on this side).
---@param actionClass table
local function WrapUpdate(actionClass)
    if not actionClass then return end
    TOC_DEBUG.print("WrapUpdate: " .. tostring(actionClass.Type))

    local og = actionClass.update
    function actionClass:update()
        og(self)
        AddTOCXp(self)
    end
end

--* Firearms
WrapUpdate(ISReloadWeaponAction)
WrapUpdate(ISInsertMagazine)
WrapUpdate(ISLoadBulletsInMagazine)
WrapUpdate(ISUnloadBulletsFromFirearm)
WrapUpdate(ISUnloadBulletsFromMagazine)
WrapUpdate(ISRackFirearm)
WrapUpdate(ISUpgradeWeapon)
WrapUpdate(ISRemoveWeaponUpgrade)

--* Building / demolition
WrapUpdate(ISBarricadeAction)
WrapUpdate(ISUnbarricadeAction)
WrapUpdate(ISChopTreeAction)
WrapUpdate(ISDismantleAction)
WrapUpdate(ISDestroyStuffAction)

--* Crafting
WrapUpdate(ISCraftAction)

--* Medical
WrapUpdate(ISApplyBandage)
WrapUpdate(ISCleanBandage)
WrapUpdate(ISDisinfect)
WrapUpdate(ISRemoveBullet)
WrapUpdate(ISSplint)
WrapUpdate(ISStitch)
WrapUpdate(ISCleanBurn)
WrapUpdate(ISRemovePatch)

--* Item handling
WrapUpdate(ISPickUpGroundCoverItem)
WrapUpdate(ISPickAxeGroundCoverItem)

return { IterateTOCXp = IterateTOCXp, WrapUpdate = WrapUpdate }