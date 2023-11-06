local BaseHandler = require("TOC_HealthPanelBaseHandler")
local CutLimbAction = require("TOC_CutLimbAction")

---@class CutLimbHandler
local CutLimbHandler = BaseHandler:derive("CutLimbHandler")


local contextMenuCutLimb = "Cut"

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
        local option = context:addOption(contextMenuCutLimb, nil)
        local subMenu = context:getNew(context)
        context:addSubMenu(option, subMenu)
        for i=1,#types do
            local item = self:getItemOfType(self.items.ITEMS, types[i])
            subMenu:addOption(item:getName(), self, self.onMenuOptionSelected, item:getFullType())
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
    return self:isInjured() and self:getItemOfType(self.items.ITEMS, itemType)
end

function CutLimbHandler:perform(previousAction, itemType)
    local item = self:getItemOfType(self.items.ITEMS, itemType)
    previousAction = self:toPlayerInventory(item, previousAction)

    local action = CutLimbAction:new(self:getPatient(), self:getDoctor(), self.bodyPart)
    ISTimedActionQueue.addAfter(previousAction, action)
end

return CutLimbHandler