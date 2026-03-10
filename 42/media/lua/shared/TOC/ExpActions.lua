local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local CommonMethods = require("TOC/CommonMethods")

local XP_PER_TICK = 0.01

---Adds TOC XP to all amputated limb perks. Server and SP only.
---@param action ISBaseTimedAction
local function AddTOCXp(action)
    if isClient() then return end
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
            TOC_DEBUG.print("AddTOCXp | " .. perkName .. "=" .. tostring(ampLevel))
            if ampLevel < 10 then
                addXp(character, Perks[perkName], XP_PER_TICK)
            end
            if dcInst:getIsProstEquipped(limbName) then
                local prostLevel = character:getPerkLevel(Perks["ProstFamiliarity"])
                TOC_DEBUG.print("AddTOCXp | ProstFamiliarity=" .. tostring(prostLevel))
                if prostLevel < 10 then
                    addXp(character, Perks["ProstFamiliarity"], XP_PER_TICK)
                end
            end
        end
    end
end

---Wraps an action class's update() to inject TOC XP each tick.
---Safely skips if the class is nil (e.g. not loaded on this side).
---@param actionClass table
local function WrapUpdate(actionClass)
    if not actionClass then return end
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
WrapUpdate(ISGrabItemAction)        -- client-only class, WrapUpdate handles nil safely

return { AddTOCXp = AddTOCXp, WrapUpdate = WrapUpdate }
