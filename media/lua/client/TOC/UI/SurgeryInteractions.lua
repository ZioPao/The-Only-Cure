local PlayerHandler = require("TOC/Handlers/PlayerHandler")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")

---------------

-- TODO Surgery Kits

local function AddInventorySurgeryMenu(playerNum, context, items)

end

Events.OnFillInventoryObjectContextMenu.Add(AddInventorySurgeryMenu)


-- TODO Oven

-- TODO We need a class to handle operations, this is just a placeholder
local function Cauterize(limbName)
    
end

---comment
---@param playerNum any
---@param context ISContextMenu
---@param worldObjects any
---@param test any
local function AddOvenContextMenu(playerNum, context, worldObjects, test)
    local pl = getSpecificPlayer(playerNum)

    if not ModDataHandler.GetInstance():getIsAnyLimbCut() then return end
    local amputatedLimbs = PlayerHandler.GetAmputatedLimbs()

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
        tempTooltip:setName("ContextMenu_Cauterize_TempTooLow_tooltip")
        tempTooltip.description = getText("Tooltip_Surgery_TempTooLow")
        tempTooltip:setVisible(false)

        local optionMain = context:addOption(getText("ContextMenu_Cauterize"), nil)
        local subMenu = context:getNew(context)
        context:addSubMenu(optionMain, subMenu)
        for i=1, #amputatedLimbs do
            local limbName = amputatedLimbs[i]
            local option = subMenu:addOption(getText("ContextMenu_Limb_" .. limbName), limbName, Cauterize)
            option.notAvailable = isTempLow
            if isTempLow then
                option.toolTip = tempTooltip
            end
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(AddOvenContextMenu)


-- TODO Other stuff?