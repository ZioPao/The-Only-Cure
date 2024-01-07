local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
---------------



-- TODO Surgery Kits

local function AddInventorySurgeryMenu(playerNum, context, items)

end

Events.OnFillInventoryObjectContextMenu.Add(AddInventorySurgeryMenu)


-- TODO Oven

-- TODO We need a class to handle operations, this is just a placeholder
local function Cauterize(limbName)
    local modDataHandler = ModDataHandler.GetInstance()
    modDataHandler:setCicatrizationTime(limbName, 0)
    modDataHandler:setIsCicatrized(limbName, true)
    modDataHandler:setIsCauterized(limbName, true)

    -- we don't care bout the depended limbs, since they're alread "cicatrized"

    modDataHandler:apply()
end

---@param playerNum number
---@param context ISContextMenu
---@param worldObjects any
---@param test any
local function AddOvenContextMenu(playerNum, context, worldObjects, test)
    if test then return true end

    local pl = getSpecificPlayer(playerNum)

    local modDataHandler = ModDataHandler.GetInstance()
    if not modDataHandler:getIsAnyLimbCut() then return end
    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(pl:getUsername())

    local stoveObj = nil
    for _, obj in pairs(worldObjects) do
        if instanceof(obj, "IsoStove") then
            stoveObj = obj
            break
        end
    end
    if stoveObj == nil then return end
    if pl:HasTrait("Brave") or pl:getPerkLevel(Perks.Strength) > 5 then
        local isTempLow = stoveObj:getCurrentTemperature() < 250
        local tempTooltip = ISToolTip:new()
        tempTooltip:initialise()
        tempTooltip:setName(getText("ContextMenu_Cauterize_TempTooLow_tooltip"))
        tempTooltip.description = getText("Tooltip_Surgery_TempTooLow")
        tempTooltip:setVisible(false)

        local addMainOption = false
        local subMenu

        for k, _ in pairs(amputatedLimbs) do

            -- We need to let the player cauterize ONLY the visible one!
            local limbName = k
            if modDataHandler:getIsVisible(limbName) and not modDataHandler:getIsCicatrized(limbName) then
                if addMainOption == false then
                    -- Adds the cauterize option ONLY when it's needed
                    local optionMain = context:addOption(getText("ContextMenu_Cauterize"), nil)
                    subMenu = context:getNew(context)
                    context:addSubMenu(optionMain, subMenu)
                    addMainOption = true
                end

                local option = subMenu:addOption(getText("ContextMenu_Limb_" .. limbName), limbName, Cauterize)
                option.notAvailable = isTempLow
                if isTempLow then
                    option.toolTip = tempTooltip
                end
            end

        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(AddOvenContextMenu)


-- TODO Other stuff?