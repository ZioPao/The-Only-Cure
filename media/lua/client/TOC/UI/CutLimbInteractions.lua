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
local function PerformAction(surgeon, patient, limbName, item)
    ISTimedActionQueue.add(CutLimbAction:new(surgeon, patient, limbName, item))
end

---Adds the actions to the inventory context menu
---@param surgeonNum number
---@param context ISContextMenu
---@param item InventoryItem
local function AddInventoryAmputationOptions(surgeonNum, context, item)
    local surgeonObj = getSpecificPlayer(surgeonNum)
    local option = context:addOption(getText("ContextMenu_Amputate"), nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(option, subMenu)
    for i = 1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        if not ModDataHandler.GetInstance():getIsCut(limbName) then
            local limbTranslatedName = getText("ContextMenu_Limb_" .. limbName)
            subMenu:addOption(limbTranslatedName, surgeonObj, PerformAction, surgeonObj, limbName, item) -- TODO Should be patient, not surgeon
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
        AddInventoryAmputationOptions(player, context, item)
    end
end


Events.OnFillInventoryObjectContextMenu.Add(AddInventoryAmputationMenu)

-------------------------------------

---@class CutLimbHandler : BaseHandler
---@field items table
local CutLimbHandler = BaseHandler:derive("CutLimbHandler")


---Creates new CutLimbHandler
---@param panel ISUIElement
---@param bodyPart BodyPart
---@return CutLimbHandler
function CutLimbHandler:new(panel, bodyPart)
    local o = BaseHandler.new(self, panel, bodyPart)
    o.items.ITEMS = {}
    TOC_DEBUG.print("init CutLimbHandler")
    return o
end

---@param item InventoryItem
function CutLimbHandler:checkItem(item)
    local itemType = item:getType()
    if string.contains(itemType, "Saw") then
        self:addItem(self.items.ITEMS, item)
    end
end

---@param context ISContextMenu
function CutLimbHandler:addToMenu(context)
    local types = self:getAllItemTypes(self.items.ITEMS)
    local limbName = BodyPartType.ToString(self.bodyPart:getType())
    if #types > 0 and StaticData.BODYPARTSTYPES_ENUM[limbName] then
        TOC_DEBUG.print("addToMenu, types > 0")
        if not ModDataHandler.GetInstance():getIsCut(limbName) then
            context:addOption(getText("ContextMenu_Amputate"), self, self.onMenuOptionSelected)
        end
    end
end

function CutLimbHandler:dropItems(items)
    local types = self:getAllItemTypes(items)
    local limbName = BodyPartType.ToString(self.bodyPart:getType())
    if #self.items.ITEMS > 0 and #types == 1 and StaticData.BODYPARTSTYPES_ENUM[limbName] then
        self:onMenuOptionSelected(types[1])
        return true
    end
    return false
end

function CutLimbHandler:isValid(itemType)
    local limbName = BodyPartType.ToString(self.bodyPart:getType())
    return (not ModDataHandler.GetInstance():getIsCut(limbName)) and self:getItemOfType(self.items.ITEMS, itemType)
end

function CutLimbHandler:perform(previousAction, itemType)
    local item = self:getItemOfType(self.items.ITEMS, itemType)
    previousAction = self:toPlayerInventory(item, previousAction)
    local limbName = BodyPartType.ToString(self.bodyPart:getType())
    TOC_DEBUG.print("perform CutLimbHandler on " .. limbName)
    local action = CutLimbAction:new(self:getDoctor(),self:getPatient(), limbName, item)
    ISTimedActionQueue.addAfter(previousAction, action)
end

return CutLimbHandler
