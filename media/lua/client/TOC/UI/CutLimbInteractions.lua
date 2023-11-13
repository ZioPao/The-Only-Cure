local BaseHandler = require("TOC/UI/HealthPanelBaseHandler")
local CutLimbAction = require("TOC/TimedActions/CutLimbAction")
local StaticData = require("TOC/StaticData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
---------------------


---Check if the item name corresponds to a compatible saw
---@param itemName string
local function CheckIfSaw(itemName)
    return itemName == "Saw" or itemName == "GardenSaw" or itemName == "Chainsaw"
end

---Add the action to the queue
---@param limbName string
---@param surgeon IsoPlayer
---@param patient IsoPlayer
local function PerformAction(limbName, surgeon, patient)
    ISTimedActionQueue.add(CutLimbAction:new(surgeon, patient, limbName))
end

---Adds the actions to the inventory context menu
---@param surgeonNum number
---@param context ISContextMenu
local function AddInventoryAmputationOptions(surgeonNum, context)
    local surgeonObj = getSpecificPlayer(surgeonNum)
    local option = context:addOption(getText("ContextMenu_Amputate"), nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(option, subMenu)
    for i = 1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        if not ModDataHandler.GetInstance():getIsCut(limbName) then
            local limbTranslatedName = getText("ContextMenu_Limb_" .. limbName)
            subMenu:addOption(limbTranslatedName, limbName, PerformAction, surgeonObj, surgeonObj) -- TODO Should be patient, not surgeon
        end
    end
end

---Handler for OnFillInventoryObjectContextMenu
---@param player number
---@param context ISContextMenu
---@param items table
local function AddInventoryAmputationMenu(player, context, items)
    local item = items[1] -- Selected item
    if CheckIfSaw(item.name) then
        AddInventoryAmputationOptions(player, context)
    end
end


Events.OnFillInventoryObjectContextMenu.Add(AddInventoryAmputationMenu)

-------------------------------------

---@class CutLimbHandler : BaseHandler
local CutLimbHandler = BaseHandler:derive("CutLimbHandler")


---Creates new CutLimbHandler
---@param panel ISUIElement
---@param bodyPart BodyPart
---@return CutLimbHandler
function CutLimbHandler:new(panel, bodyPart)
    local o = BaseHandler.new(self, panel, bodyPart)
    o.items.ITEMS = {}
    return o
end

---@param item InventoryItem
function CutLimbHandler:checkItem(item)
    local itemType = item:getType()
    if CheckIfSaw(itemType) then
        self:addItem(self.items.ITEMS, item)
    end
end

---@param context ISContextMenu
function CutLimbHandler:addToMenu(context)

    --TOC_DEBUG.print("addToMenu running")
    local limbName = BodyPartType.ToString(self.bodyPart:getType())
    --TOC_DEBUG.print(limbName)
    if StaticData.BODYPARTSTYPES_ENUM[limbName] then
        if not ModDataHandler.GetInstance():getIsCut(limbName) then
            context:addOption(getText("ContextMenu_Amputate"), self, self.onMenuOptionSelected)
        end
    end
end

function CutLimbHandler:dropItems(items)
    local types = self:getAllItemTypes(items)
    if #self.items.ITEMS > 0 and #types == 1 then
        self:onMenuOptionSelected(types[1])
        return true
    end
    return false
end

function CutLimbHandler:isValid(itemType)
    return true     -- TODO Workaround for now
end

function CutLimbHandler:perform(previousAction, itemType)
    --local item = self:getItemOfType(self.items.ITEMS, itemType)
    --previousAction = self:toPlayerInventory(item, previousAction)

    local limbName = BodyPartType.ToString(self.bodyPart:getType())
    TOC_DEBUG.print("perform CutLimbHandler on " .. limbName)
    local action = CutLimbAction:new(self:getPatient(), self:getDoctor(), limbName)
    ISTimedActionQueue.add(action)
end

return CutLimbHandler
