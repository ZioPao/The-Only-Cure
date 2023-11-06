local BaseHandler = require("UI/TOC_HealthPanelBaseHandler")
local CutLimbAction = require("TimedActions/TOC_CutLimbAction")

---@class CutLimbHandler
local CutLimbHandler = BaseHandler:derive("CutLimbHandler")


---Creates new CutLimbHandler
---@param panel any
---@param bodyPart any
---@return CutLimbHandler
function CutLimbHandler:new(panel, bodyPart)
    local o = BaseHandler.new(self, panel, bodyPart)
    o.items.ITEMS = {}
    return o
end

function CutLimbHandler:checkItem(item)
    local itemType = item:getType()
    if itemType == "Saw" or itemType == "GardenSaw" or itemType == "Chainsaw" then
        self:addItem(self.items.ITEMS, item)
    end

end

function CutLimbHandler:addToMenu(context)
    local types = self:getAllItemTypes(self.items.ITEMS)
    if #types > 0 then
        context:addOption(getText("ContextMenu_Amputate"), self, self.onMenuOptionSelected)
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
    return self:getItemOfType(self.items.ITEMS, itemType)
end

function CutLimbHandler:perform(previousAction, itemType)
    print("perform cutlimbhandler")
    local item = self:getItemOfType(self.items.ITEMS, itemType)
    previousAction = self:toPlayerInventory(item, previousAction)

    local action = CutLimbAction:new(self:getPatient(), self:getDoctor(), self.bodyPart)
    ISTimedActionQueue.addAfter(previousAction, action)
end

return CutLimbHandler