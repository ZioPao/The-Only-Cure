local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
-------------------------

---@class ProsthesisHandler
local ProsthesisHandler = {}

local bodyLocArmProst = StaticData.MOD_BODYLOCS_BASE_IND_STR.TOC_ArmProst

---Check if the following item is a prosthesis or not
---@param item InventoryItem?
---@return boolean
function ProsthesisHandler.CheckIfProst(item)
    -- TODO Won't be correct when prost for legs are gonna be in
    TOC_DEBUG.print("Checking if item is prost")
    if item == nil then
        TOC_DEBUG.print("Not prost")

        return false
    end
    return item:getBodyLocation():contains(bodyLocArmProst)
end

---Get the grouping for the prosthesis
---@param item InventoryItem
---@return string
function ProsthesisHandler.GetGroup(item)
    local bodyLocation = item:getBodyLocation()
    local side = CommonMethods.GetSide(bodyLocation)
    local index = bodyLocation:contains(bodyLocArmProst) and "Top_" .. side or "Bottom_" .. side
    local group = StaticData.PROSTHESES_GROUPS_IND_STR[index]
    return group
end

---Check if a prosthesis is equippable. It depends whether the player has a cut limb or not on that specific side. There's an exception for Upper arm, obviously
---@param name string
---@return boolean
function ProsthesisHandler.CheckIfEquippable(name)
    TOC_DEBUG.print("Current item is a prosthesis")
    local side = CommonMethods.GetSide(name)
    TOC_DEBUG.print("Checking side: " .. tostring(side))

    local highestAmputatedLimbs = CachedDataHandler.GetHighestAmputatedLimbs(getPlayer():getUsername())

    if highestAmputatedLimbs then
        local hal = highestAmputatedLimbs[side]
        if not string.contains(hal, "UpperArm") then
            TOC_DEBUG.print("Found acceptable limb to use prosthesis => " .. tostring(hal))
            return true
        end
    end

    -- No acceptable cut limbs
    return false
end


---Handle equipping or unequipping prosthetics
---@param item InventoryItem
---@param isEquipping boolean
function ProsthesisHandler.SearchAndSetupProsthesis(item, isEquipping)
    if not ProsthesisHandler.CheckIfProst(item) then return end

    local group = ProsthesisHandler.GetGroup(item)
    TOC_DEBUG.print("Setup Prosthesis => " .. group .. " - is equipping? " .. tostring(isEquipping))
    local dcInst = DataController.GetInstance()
    dcInst:setIsProstEquipped(group, isEquipping)
    dcInst:apply()
end

-------------------------
--* Overrides *--


---@param item InventoryItem
---@param isEquippable boolean
---@return unknown
local function HandleProsthesisValidation(item, isEquippable)
    local isProst = ProsthesisHandler.CheckIfProst(item)
    if not isProst then return isEquippable end

    local itemName = item:getName()        -- use name for side
    if isEquippable then
        isEquippable = ProsthesisHandler.CheckIfEquippable(itemName)
    end


    if not isEquippable then
        getPlayer():Say(getText("UI_Say_CantEquip"))
    end

    return isEquippable
end


---@diagnostic disable-next-line: duplicate-set-field
local og_ISWearClothing_isValid = ISWearClothing.isValid
function ISWearClothing:isValid()
    local isEquippable = og_ISWearClothing_isValid(self)
    return HandleProsthesisValidation(self.item, isEquippable)
end

local og_ISWearClothing_perform = ISWearClothing.perform
function ISWearClothing:perform()
    ProsthesisHandler.SearchAndSetupProsthesis(self.item, true)
    og_ISWearClothing_perform(self)
end

local og_ISClothingExtraAction_isValid = ISClothingExtraAction.isValid
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()
    local isEquippable = og_ISClothingExtraAction_isValid(self)
    return HandleProsthesisValidation(self.item, isEquippable)
end

local og_ISClothingExtraAction_perform = ISClothingExtraAction.perform
function ISClothingExtraAction:perform()
    og_ISClothingExtraAction_perform(self)
    ProsthesisHandler.SearchAndSetupProsthesis(self.item, true)
end

local og_ISUnequipAction_perform = ISUnequipAction.perform
function ISUnequipAction:perform()
    og_ISUnequipAction_perform(self)
    ProsthesisHandler.SearchAndSetupProsthesis(self.item, false)
end


return ProsthesisHandler
