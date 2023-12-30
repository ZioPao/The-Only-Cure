
local BaseHandler = require("TOC/UI/HealthPanelBaseHandler")
local CommonMethods = require("TOC/CommonMethods")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")

local CleanWoundAction = require("TOC/TimedActions/CleanWoundAction")
-------------------------
---@class WoundCleaningHandler : BaseHandler
---@field username string
---@field limbName string
local WoundCleaningHandler = BaseHandler:derive("WoundCleaningHandler")

---comment
---@param panel any
---@param bodyPart any
---@param username string
---@return table
function WoundCleaningHandler:new(panel, bodyPart, username)
    local o = BaseHandler.new(self, panel, bodyPart)
    o.items.ITEMS = {}
    o.username = username

    o.limbName = CommonMethods.GetLimbNameFromBodyPart(bodyPart)

    return o
end

function WoundCleaningHandler:checkItem(item)
    if item:getBandagePower() >= 2 then
        self:addItem(self.items.ITEMS, item)
    end
end

function WoundCleaningHandler:addToMenu(context)
    local types = self:getAllItemTypes(self.items.ITEMS)
    if #types > 0 and self:isValid() then
        local option = context:addOption("Clean Wound", nil)
        local subMenu = context:getNew(context)
        context:addSubMenu(option, subMenu)
        for i=1,#types do
            local item = self:getItemOfType(self.items.ITEMS, types[i])
            subMenu:addOption(item:getName(), self, self.onMenuOptionSelected, item:getFullType())
        end
    end
end

function WoundCleaningHandler:dropItems(items)
    local types = self:getAllItemTypes(items)
    if #self.items.ITEMS > 0 and #types == 1 and self:isInjured() and self.bodyPart:isNeedBurnWash() then
        -- FIXME: A bandage can be used to clean a burn or bandage it
        self:onMenuOptionSelected(types[1])
        return true
    end
    return false
end

function WoundCleaningHandler:isValid()
    -- TODO Check if cut and not cicatrized and dirty

    -- todo get username 
    if self.limbName == nil then return false end

    local modDataHandler = ModDataHandler.GetInstance(self.username)

    --and modDataHandler:getWoundDirtyness(self.limbName) > 0.1

    return modDataHandler:getIsCut(self.limbName) and not modDataHandler:getIsCicatrized(self.limbName)
    --return self:getItemOfType(self.items.ITEMS, itemType)
end

function WoundCleaningHandler:perform(previousAction, itemType)
    local item = self:getItemOfType(self.items.ITEMS, itemType)
    previousAction = self:toPlayerInventory(item, previousAction)
    local action = CleanWoundAction:new(self:getDoctor(), self:getPatient(), item, self.bodyPart)
    ISTimedActionQueue.addAfter(previousAction, action)
end


return WoundCleaningHandler