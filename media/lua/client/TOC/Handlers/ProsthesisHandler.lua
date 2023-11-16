local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
-------------------------

---@class ProsthesisHandler
local ProsthesisHandler = {}

local bodyLocArmProst = StaticData.MOD_BODYLOCS_BASE_IND_STR.TOC_ArmProst

---Check if the following item is a prosthesis or not
---@param item InventoryItem
---@return boolean
function ProsthesisHandler.CheckIfProst(item)
    -- TODO Won't be correct when prost for legs are gonna be in
    return item:getBodyLocation():contains(bodyLocArmProst)
end

---Get the grouping for the prosthesis
---@param item InventoryItem
---@return string
function ProsthesisHandler.GetGroup(item)

    local bodyLocation = item:getBodyLocation()
    local side = CommonMethods.GetSide(bodyLocation)
    local index

    if bodyLocation:contains(bodyLocArmProst) then
        index = "Top_" .. side
    else
        index = "Bottom_" .. side
    end

    local group = StaticData.PROSTHESES_GROUPS_IND_STR[index]
    return group
end

---Cache the correct texture for the Health Panel for the currently equipped prosthesis
function ProsthesisHandler.SetHealthPanelTexture()
    -- TODO do it
end

---Check if a prosthesis is equippable. It depends whether the player has a cut limb or not on that specific side. There's an exception for Upper arm, obviously
---@param bodyLocation string
---@return boolean
function ProsthesisHandler.CheckIfEquippable(bodyLocation)
    TOC_DEBUG.print("current item is a prosthesis")
    local side = CommonMethods.GetSide(bodyLocation)
    TOC_DEBUG.print("checking side: " .. tostring(side))

    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(getPlayer():getUsername())
    for i = 1, #amputatedLimbs do
        local limbName = amputatedLimbs[i]
        if string.contains(limbName, side) and not string.contains(limbName, "UpperArm") then
            TOC_DEBUG.print("found acceptable limb to use prosthesis")
            return true
        end
    end

    -- No acceptable cut limbs
    return false
end
-------------------------
--* Events *--




-------------------------
--* Overrides *--

-- ---@diagnostic disable-next-line: duplicate-set-field
-- function ISWearClothing:isValid()
--     TOC_DEBUG.print("ISWearClothing:isValid")
--     local bodyLocation = self.item:getBodyLocation()
--     if not string.contains(bodyLocation, bodyLocArmProst) then
--         return true
--     else
--         return ProsthesisHandler.CheckIfEquippable(bodyLocation)
--     end
-- end

local og_ISClothingExtraAction_isValid = ISClothingExtraAction.isValid
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()

    --the item that we gets is the OG one, so if we're coming from the left one and wanna switch to the right one we're still gonna get the Left bodylocation
    -- TODO isValid can be run multiple times, for some reason. 
    local testItem = InventoryItemFactory.CreateItem(self.extra)
    local bodyLocation = testItem:getBodyLocation()
    local isEquippable = og_ISClothingExtraAction_isValid(self)
    if isEquippable and not string.contains(bodyLocation, bodyLocArmProst) then
        isEquippable = true
    else
        isEquippable = ProsthesisHandler.CheckIfEquippable(bodyLocation)
    end

    return isEquippable
end

local og_ISClothingExtraAction_stop = ISClothingExtraAction.stop
function ISClothingExtraAction:stop()
    og_ISClothingExtraAction_stop(self)
    if ProsthesisHandler.CheckIfProst(self.item) then
        getPlayer():Say(getText("UI_Say_CantEquip"))

    end
end

local og_ISClothingExtraAction_perform = ISClothingExtraAction.perform
function ISClothingExtraAction:perform()
    if ProsthesisHandler.CheckIfProst(self.item) then
        local group = ProsthesisHandler.GetGroup(self.item)
        TOC_DEBUG.print("applying prosthesis stuff for " .. group)
        local modDataHandler = ModDataHandler.GetInstance()
        modDataHandler:setIsProstEquipped(group, true)
        modDataHandler:apply()
    end

    og_ISClothingExtraAction_perform(self)
end



return ProsthesisHandler
