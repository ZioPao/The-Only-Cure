-- Had to copy and paste this stuff from the base game since this is a local only class. Kinda shit, but eh

---@class BaseHandler : ISBaseObject
---@field panel ISUIElement
---@field bodyPart BodyPart
---@field items table
local BaseHandler = ISBaseObject:derive("BaseHandler")

---@param panel ISUIElement
---@param bodyPart BodyPart
---@return table
function BaseHandler:new(panel, bodyPart)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.panel = panel
    o.bodyPart = bodyPart
    o.items = {}
    return o
end

function BaseHandler:isInjured()
    TOC_DEBUG.print("Running isInjured")
    local bodyPart = self.bodyPart
    return (bodyPart:HasInjury() or bodyPart:stitched() or bodyPart:getSplintFactor() > 0) and not bodyPart:bandaged()
end

function BaseHandler:checkItems()
    for k,v in pairs(self.items) do
        table.wipe(v)
    end

    local containers = ISInventoryPaneContextMenu.getContainers(self:getDoctor())
    local done = {}
    local childContainers = {}
    if containers ~= nil then
        for i=1, containers:size() do
            local container = containers:get(i-1)
            done[container] = true
            table.wipe(childContainers)
            self:checkContainerItems(container, childContainers)
            for _,container2 in ipairs(childContainers) do
                if not done[container2] then
                    done[container2] = true
                    self:checkContainerItems(container2, nil)
                end
            end
        end
    end
end

function BaseHandler:checkContainerItems(container, childContainers)
    local containerItems = container:getItems()
    for i=1,containerItems:size() do
        local item = containerItems:get(i-1)
        if item:IsInventoryContainer() then
            if childContainers then
                table.insert(childContainers, item:getInventory())
            end
        else
            ---@diagnostic disable-next-line: undefined-field
            self:checkItem(item)        -- This is in inherited classes, we never use this class by itself
        end
    end
end

function BaseHandler:dropItems(items)
    return false
end

function BaseHandler:addItem(items, item)
    table.insert(items, item)
end

function BaseHandler:getAllItemTypes(items)
    local done = {}
    local types = {}
    for _,item in ipairs(items) do
        if not done[item:getFullType()] then
            table.insert(types, item:getFullType())
            done[item:getFullType()] = true
        end
    end
    return types
end

function BaseHandler:getItemOfType(items, type)
    for _,item in ipairs(items) do
        if item:getFullType() == type then
            return item
        end
    end
    return nil
end

function BaseHandler:getItemOfTag(items, type)
    for _,item in ipairs(items) do
        if item:hasTag(type) then
            return item
        end
    end
    return nil
end

function BaseHandler:getAllItemsOfType(items, type)
    items = {}
    for _,item in ipairs(items) do
        if item:getFullType() == type then
            table.insert(items, item)
        end
    end
    return items
end

function BaseHandler:onMenuOptionSelected(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ISTimedActionQueue.add(HealthPanelAction:new(self:getDoctor(), self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8))
end

function BaseHandler:toPlayerInventory(item, previousAction)
    if item:getContainer() ~= self:getDoctor():getInventory() then
        local action = ISInventoryTransferAction:new(self:getDoctor(), item, item:getContainer(), self:getDoctor():getInventory())
        ISTimedActionQueue.addAfter(previousAction, action)
        -- FIX: ISHealthPanel.actions never gets cleared
        self.panel.actions = self.panel.actions or {}
        self.panel.actions[action] = self.bodyPart
        return action
    end
    return previousAction
end

---@return IsoPlayer
function BaseHandler:getDoctor()
    return self.panel.otherPlayer or self.panel.character
end

---@return IsoPlayer
function BaseHandler:getPatient()
    return self.panel.character
end

return BaseHandler