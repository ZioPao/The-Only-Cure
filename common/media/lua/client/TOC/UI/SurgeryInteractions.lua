local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local DataController = require("TOC/Controllers/DataController")
local CauterizeAction = require("TOC/TimedActions/CauterizeAction")
---------------


---@param tooltip ISToolTip
---@param desc string
local function AppendToDescription(tooltip, desc)
    if tooltip.description == "" then
        desc = string.upper(string.sub(desc, 1, 1)) .. string.sub(desc, 2)
        tooltip.description = desc
    else
        desc = string.lower(string.sub(desc, 1, 1)) .. string.sub(desc, 2)
        tooltip.description = tooltip.description .. getText("Tooltip_Surgery_And") .. desc
    end
end

---@param playerNum number
---@param context ISContextMenu
---@param worldObjects any
---@param test any
local function AddStoveContextMenu(playerNum, context, worldObjects, test)
    if test then return true end

    local pl = getSpecificPlayer(playerNum)

    local dcInst = DataController.GetInstance()
    if not dcInst:getIsAnyLimbCut() then return end
    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(pl:getUsername())

    ---@type IsoStove?
    local stoveObj = nil
    for _, obj in pairs(worldObjects) do
        if instanceof(obj, "IsoStove") then
            stoveObj = obj
            break
        end
    end
    if stoveObj == nil then return end
    local tempTooltip = ISToolTip:new()
    tempTooltip:initialise()
    tempTooltip.description = ""
    tempTooltip:setVisible(false)

    local addMainOption = false
    local subMenu

    for k, _ in pairs(amputatedLimbs) do

        -- We need to let the player cauterize ONLY the visible one!
        ---@type string
        local limbName = k
        if dcInst:getIsVisible(limbName) and not dcInst:getIsCicatrized(limbName) then
            if addMainOption == false then
                -- Adds the cauterize option ONLY when it's needed
                local optionMain = context:addOption(getText("ContextMenu_Cauterize"), nil)
                subMenu = context:getNew(context)
                context:addSubMenu(optionMain, subMenu)
                addMainOption = true
            end

            local option = subMenu:addOption(getText("ContextMenu_Limb_" .. limbName), nil, function()
                local adjacent = AdjacentFreeTileFinder.Find(stoveObj:getSquare(), pl)
                ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, adjacent))
                ISTimedActionQueue.add(CauterizeAction:new(pl, limbName, stoveObj))
            end)


            -- Notifications, in case the player can't do the action
            local isPlayerCourageous = pl:HasTrait("Brave") or pl:getPerkLevel(Perks.Strength) > 5
            local isTempHighEnough = stoveObj:getCurrentTemperature() >= 250
            local isLimbFree = not dcInst:getIsProstEquipped(limbName)

            option.notAvailable = not(isPlayerCourageous and isTempHighEnough and isLimbFree)
            if not isTempHighEnough then
                AppendToDescription(tempTooltip,  getText("Tooltip_Surgery_TempTooLow"))
            end

            if not isPlayerCourageous then
                AppendToDescription(tempTooltip, getText("Tooltip_Surgery_Coward"))
            end

            if not isLimbFree then
                AppendToDescription(tempTooltip, getText("Tooltip_Surgery_LimbNotFree"))
            end

            if option.notAvailable then
                tempTooltip:setName(getText("Tooltip_Surgery_CantCauterize"))
                option.toolTip = tempTooltip
            end
        end

    end

end

Events.OnFillWorldObjectContextMenu.Add(AddStoveContextMenu)
