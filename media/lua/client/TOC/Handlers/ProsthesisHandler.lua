local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
-------------------------

---@class ProsthesisHandler
local ProsthesisHandler = {}

local bodyLocArmProst = StaticData.MOD_BODYLOCS_BASE_IND_STR.TOC_ArmProst

---comment
---@param item InventoryItem
function ProsthesisHandler.CheckIfProst(item)
    -- TODO Won't be correct when prost for legs are gonna be in
    return item:getBodyLocation():contains(bodyLocArmProst)
end

---Get the grouping for the prosthesis
---@param item InventoryItem
---@return string
function ProsthesisHandler.GetGroup(item)
    if item:getBodyLocation():contains(bodyLocArmProst) then
        return StaticData.PROSTHESES_GROUPS.top
    else
        return StaticData.PROSTHESES_GROUPS.bottom
    end
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

    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(getPlayer():getUsername())
    for i = 1, #amputatedLimbs do
        local limbName = amputatedLimbs[i]
        if string.contains(limbName, side) and not string.contains(limbName, "UpperArm") then
            return true
        end
    end

    -- No acceptable cut limbs
    getPlayer():Say("I can't equip this")
    return false
end
-------------------------
--* Events *--




-------------------------
--* Overrides *--

---@diagnostic disable-next-line: duplicate-set-field
function ISWearClothing:isValid()
    local bodyLocation = self.item:getBodyLocation()
    if not string.contains(bodyLocation, bodyLocArmProst) then
        return true
    else
        return ProsthesisHandler.CheckIfEquippable(bodyLocation)
    end
end

local og_ISClothingExtraAction_isValid = ISClothingExtraAction.isValid
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()
    local bodyLocation = self.item:getBodyLocation()
    local isEquippable = false
    if og_ISClothingExtraAction_isValid(self) and not string.contains(bodyLocation, bodyLocArmProst) then
        isEquippable = true
    else
        isEquippable = ProsthesisHandler.CheckIfEquippable(bodyLocation)
    end

    return isEquippable
end


local og_ISClothingExtraAction_perform = ISClothingExtraAction.perform
function ISClothingExtraAction:perform()
    og_ISClothingExtraAction_perform(self)

    if ProsthesisHandler.CheckIfProst(self.item) then
        local group = ProsthesisHandler.GetGroup(self.item)
        TOC_DEBUG.print("applying prosthesis stuff for " .. group)
        local modDataHandler = ModDataHandler.GetInstance()
        modDataHandler:setIsProstEquipped(group, true)
        modDataHandler:apply()
    end
end



return ProsthesisHandler
