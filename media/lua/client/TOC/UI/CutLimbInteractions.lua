local BaseHandler = require("TOC/UI/HealthPanelBaseHandler")
local CutLimbAction = require("TOC/TimedActions/CutLimbAction")
local StaticData = require("TOC/StaticData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
---------------------




---Check if the item type corresponds to a compatible saw
---@param itemType string
local function CheckIfSaw(itemType)
    return itemType:contains(StaticData.SAWS_TYPES_IND_STR.saw) or itemType:contains(StaticData.SAWS_TYPES_IND_STR.gardenSaw)
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
    for i = 1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
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
    local item

    -- We can't access the item if we don't create the loop and start ipairs.
    for _, v in ipairs(items) do
        item = v
        if not instanceof(v, "InventoryItem") then
            item = v.items[1]
        end
        break
    end

    local itemType = item:getType()
    if CheckIfSaw(itemType) then
        AddInventoryAmputationOptions(player, context, item)
    end
end


Events.OnFillInventoryObjectContextMenu.Add(AddInventoryAmputationMenu)

-------------------------------------

---@class CutLimbHandler : BaseHandler
---@field items table
---@field limbName string
local CutLimbHandler = BaseHandler:derive("CutLimbHandler")


---Creates new CutLimbHandler
---@param panel ISUIElement
---@param bodyPart BodyPart
---@return CutLimbHandler
function CutLimbHandler:new(panel, bodyPart)
    local o = BaseHandler.new(self, panel, bodyPart)
    o.items.ITEMS = {}
    o.limbName = BodyPartType.ToString(bodyPart:getType())
    TOC_DEBUG.print("init CutLimbHandler")
    return o
end

---@param item InventoryItem
function CutLimbHandler:checkItem(item)
    local itemType = item:getType()
    TOC_DEBUG.print("checkItem: " .. tostring(itemType))

    if CheckIfSaw(itemType) then
        self:addItem(self.items.ITEMS, item)
    end
end

---@param context ISContextMenu
function CutLimbHandler:addToMenu(context)
    local types = self:getAllItemTypes(self.items.ITEMS)
    if #types > 0 and StaticData.BODYLOCS_IND_BPT[self.limbName] then
        TOC_DEBUG.print("addToMenu, types > 0")
        if not ModDataHandler.GetInstance():getIsCut(self.limbName) then
            context:addOption(getText("ContextMenu_Amputate"), self, self.onMenuOptionSelected)
        end
    end
end

function CutLimbHandler:dropItems(items)
    local types = self:getAllItemTypes(items)
    if #self.items.ITEMS > 0 and #types == 1 and StaticData.BODYLOCS_IND_BPT[self.limbName] then
        self:onMenuOptionSelected(types[1])
        return true
    end
    return false
end

function CutLimbHandler:isValid(itemType)
    return (not ModDataHandler.GetInstance():getIsCut(self.limbName)) and self:getItemOfType(self.items.ITEMS, itemType)
end

function CutLimbHandler:perform(previousAction, itemType)
    local item = self:getItemOfType(self.items.ITEMS, itemType)
    previousAction = self:toPlayerInventory(item, previousAction)
    TOC_DEBUG.print("perform CutLimbHandler on " .. self.limbName)
    local action = CutLimbAction:new(self:getDoctor(),self:getPatient(), self.limbName, item)
    ISTimedActionQueue.addAfter(previousAction, action)
end

return CutLimbHandler
