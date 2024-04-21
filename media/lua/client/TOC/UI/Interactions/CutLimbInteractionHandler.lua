local BaseHandler = require("TOC/UI/Interactions/HealthPanelBaseHandler")
local StaticData = require("TOC/StaticData")
local DataController = require("TOC/Controllers/DataController")

local CutLimbAction = require("TOC/TimedActions/CutLimbAction")
---------------------

-- TODO Add interaction to cut and bandage!


--* Various functions to help during these pesky checks

---Check if the item type corresponds to a compatible saw
---@param itemType string
local function CheckIfSaw(itemType)
    return itemType:contains(StaticData.SAWS_TYPES_IND_STR.saw) or itemType:contains(StaticData.SAWS_TYPES_IND_STR.gardenSaw)
end

---Return a compatible bandage
---@param player IsoPlayer
---@return InventoryItem?
local function GetBandageItem(player)
    local plInv = player:getInventory()
    local bandageItem = plInv:FindAndReturn("Base.Bandage") or plInv:FindAndReturn("Base.RippedSheets")

    ---@cast bandageItem InventoryItem

    return bandageItem
end

---Return a suture needle or thread (only if the player has a needle too)
---@param player IsoPlayer
---@return InventoryItem?
local function GetStitchesConsumableItem(player)
    local plInv = player:getInventory()

    -- Suture needle has priority

    local sutureNeedle = plInv:FindAndReturn("Base.SutureNeedle")
    ---@cast sutureNeedle DrainableComboItem

    if sutureNeedle and sutureNeedle:getUsedDelta() > 0 then
        return sutureNeedle
    else
        -- Didn't find the suture one, so let's search for the normal one + thread

        local needleItem = plInv:FindAndReturn("Base.Needle")

        if needleItem == nil then return nil end

        -- Found the normal one, searching for thread

        local threadItem = plInv:FindAndReturn("Base.Thread")
        ---@cast threadItem DrainableComboItem

        if threadItem and threadItem:getUsedDelta() > 0 then
            return threadItem
        end
    end

end


---Add the action to the queue
---@param limbName string
---@param surgeon IsoPlayer
---@param patient IsoPlayer
---@param sawItem InventoryItem
---@param stitchesItem InventoryItem?
---@param bandageItem InventoryItem?
local function PerformAction(surgeon, patient, limbName, sawItem, stitchesItem, bandageItem)
    -- get saw in hand
    -- todo primary or secondary depending on amputation status of surgeon
    ISTimedActionQueue.add(ISEquipWeaponAction:new(surgeon, sawItem, 50, true, false))

    local lHandItem = surgeon:getSecondaryHandItem()
    if lHandItem then
        ISTimedActionQueue.add(ISUnequipAction:new(surgeon, lHandItem, 50))
    end


    ISTimedActionQueue.add(CutLimbAction:new(surgeon, patient, limbName, sawItem, stitchesItem, bandageItem))
end


local textAmp = getText("ContextMenu_Amputate")
local textAmpBandage = getText("ContextMenu_Amputate_Bandage")
local textAmpStitch = getText("ContextMenu_Amputate_Stitch")
local textAmpStitchBandage = getText("ContextMenu_Amputate_Stitch_Bandage")

---Adds the actions to the inventory context menu
---@param player IsoPlayer
---@param context ISContextMenu
---@param sawItem InventoryItem
---@param stitchesItem InventoryItem?
---@param bandageItem InventoryItem?
local function AddInvAmputationOptions(player, context, sawItem, stitchesItem, bandageItem)
    local text

    -- Set the correct text option
    if stitchesItem and bandageItem then
        --TOC_DEBUG.print("stitches and bandage")
        text = textAmpStitchBandage
    elseif not bandageItem and stitchesItem then
        --TOC_DEBUG.print("only stitches")
        text = textAmpStitch
    elseif not stitchesItem and bandageItem then
        --TOC_DEBUG.print("only bandages")
        text = textAmpBandage
    else
        text = textAmp
    end

    TOC_DEBUG.print("Current text " .. tostring(text))
    local option = context:addOption(text, nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(option, subMenu)



    -- TODO Separate into groups


    -- Amputate -> Top/Bottom - > Left/Right - > Limb
    -- for i=1, #StaticData.PROSTHESES_GROUPS_STR do
    --     local group = StaticData.PROSTHESES_GROUPS_STR[i]

    --     for j=1, #StaticData.SIDES_IND_STR do

    --     end

    -- end

    -- for k,v in pairs(StaticData.LIMBS_TO_PROST_GROUP_MATCH_IND_STR) do
    --     TOC_DEBUG.print(k)

    -- end


    local dc = DataController.GetInstance()
    for i = 1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        if not dc:getIsCut(limbName) then
            local limbTranslatedName = getText("ContextMenu_Limb_" .. limbName)
            subMenu:addOption(limbTranslatedName, player, PerformAction, player, limbName, sawItem, stitchesItem, bandageItem)
        end
    end
end


---Handler for OnFillInventoryObjectContextMenu
---@param playerNum number
---@param context ISContextMenu
---@param items table
local function AddInventoryAmputationMenu(playerNum, context, items)
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
        local player = getSpecificPlayer(playerNum)
        local sawItem = item
        local stitchesItem = GetStitchesConsumableItem(player)
        local bandageItem = GetBandageItem(player)

        TOC_DEBUG.print("Stitches item: " .. tostring(stitchesItem))
        TOC_DEBUG.print("Bandage item: " .. tostring(bandageItem))

        AddInvAmputationOptions(player, context, sawItem, stitchesItem, bandageItem)
    end
end


Events.OnFillInventoryObjectContextMenu.Add(AddInventoryAmputationMenu)

-------------------------------------

---@class CutLimbInteractionHandler : BaseHandler
---@field items table
---@field limbName string
---@field itemType string temporary
local CutLimbInteractionHandler = BaseHandler:derive("CutLimbInteractionHandler")


---Creates new CutLimbInteractionHandler
---@param panel ISUIElement
---@param bodyPart BodyPart
---@return CutLimbInteractionHandler
function CutLimbInteractionHandler:new(panel, bodyPart)
    local o = BaseHandler.new(self, panel, bodyPart)
    o.items.ITEMS = {}
    o.limbName = BodyPartType.ToString(bodyPart:getType())
    o.itemType = "Saw"
    --TOC_DEBUG.print("init CutLimbInteractionHandler")
    return o
end

---@param item InventoryItem
function CutLimbInteractionHandler:checkItem(item)
    --TOC_DEBUG.print("CutLimbInteractionHandler checkItem")
    local itemType = item:getType()

    if CheckIfSaw(itemType) then
        TOC_DEBUG.print("added to list -> " .. itemType)
        self:addItem(self.items.ITEMS, item)
    end
end

---@param context ISContextMenu
function CutLimbInteractionHandler:addToMenu(context)
    --TOC_DEBUG.print("CutLimbInteractionHandler addToMenu")
    local types = self:getAllItemTypes(self.items.ITEMS)
    local patientUsername = self:getPatient():getUsername()
    if #types > 0 and StaticData.BODYLOCS_IND_BPT[self.limbName] and not DataController.GetInstance(patientUsername):getIsCut(self.limbName) then
        TOC_DEBUG.print("addToMenu, types > 0")
        for i=1, #types do
            context:addOption(getText("ContextMenu_Amputate"), self, self.onMenuOptionSelected, types[i])
        end
    end
end

function CutLimbInteractionHandler:dropItems(items)
    local types = self:getAllItemTypes(items)
    if #self.items.ITEMS > 0 and #types == 1 and StaticData.BODYLOCS_IND_BPT[self.limbName] then
        self:onMenuOptionSelected(types[1])
        return true
    end
    return false
end

---Check if CutLimbInteractionHandler is valid, the limb must not be cut to be valid
---@return boolean
function CutLimbInteractionHandler:isValid()
    --TOC_DEBUG.print("CutLimbInteractionHandler isValid")
    self:checkItems()
    local patientUsername = self:getPatient():getUsername()
    return not DataController.GetInstance(patientUsername):getIsCut(self.limbName)
end

function CutLimbInteractionHandler:perform(previousAction, itemType)
    local item = self:getItemOfType(self.items.ITEMS, itemType)
    previousAction = self:toPlayerInventory(item, previousAction)
    TOC_DEBUG.print("Perform CutLimbInteractionHandler on " .. self.limbName)
    local action = CutLimbAction:new(self:getDoctor(),self:getPatient(), self.limbName, item)
    ISTimedActionQueue.addAfter(previousAction, action)
end

return CutLimbInteractionHandler
