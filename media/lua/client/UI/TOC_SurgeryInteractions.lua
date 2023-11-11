local PlayerHandler = require("Handlers/TOC_PlayerHandler")
local StaticData = require("TOC_StaticData")
local ModDataHandler = require("Handlers/TOC_ModDataHandler")

---------------

-- TODO Surgery Kits

local function AddInventorySurgeryMenu(playerNum, context, items)

end

Events.OnFillInventoryObjectContextMenu.Add(AddInventorySurgeryMenu)


-- TODO Oven

-- TODO We need a class to handle operations, this is just a placeholder
local function Cauterize(limbName)
    
end


local function AddOvenContextMenu(playerNum, context, worldObjects, test)
    local pl = getSpecificPlayer(playerNum)

    if not ModDataHandler.GetInstance():getIsAnyLimbCut() then return end
    local amputatedLimbs = PlayerHandler.GetAmputatedLimbs()

    local foundStove = false
    for _, obj in pairs(worldObjects) do
        if instanceof(obj, "IsoStove") and obj:getCurrentTemperature() > 250 then
            foundStove = true
            break
        end
    end

    if foundStove == false then return end

    local option = context:addOption(getText("ContextMenu_Cauterize"), nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(option, subMenu)

    if pl:HasTrait("Brave") or pl:getPerkLevel(Perks.Strength) > 5 then
        for i=1, #amputatedLimbs do
            local limbName = amputatedLimbs[i]
            subMenu:addOption(getText("ContextMenu_Limb_" .. limbName), limbName, Cauterize)
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(AddOvenContextMenu)


-- TODO Other stuff?