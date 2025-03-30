local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
-------------------------

---@class ProsthesisHandler
local ProsthesisHandler = {}

local bodyLocArmProst = StaticData.MOD_BODYLOCS_BASE_IND_STR.TOC_ArmProst
local bodyLocLegProst = StaticData.MOD_BODYLOCS_BASE_IND_STR.TOC_LegProst

---Check if the following item is a prosthesis or not
---@param item InventoryItem?
---@return boolean
function ProsthesisHandler.CheckIfProst(item)
    -- TODO Won't be correct when prost for legs are gonna be in
    --TOC_DEBUG.print("Checking if item is prost")
    if item == nil then
        --TOC_DEBUG.print("Not prost")

        return false
    end
    return item:getBodyLocation():contains(bodyLocArmProst)
end

---Get the grouping for the prosthesis
---@param item InventoryItem
---@return string
function ProsthesisHandler.GetGroup(item)
    local fullType = item:getFullType()
    local side = CommonMethods.GetSide(fullType)


    local bodyLocation = item:getBodyLocation()
    local position
    if bodyLocation == bodyLocArmProst then
        position = "Top_"
    elseif bodyLocation == bodyLocLegProst then
        position = "Bottom_"
    else
        TOC_DEBUG.print("Something is wrong, no position in this item")
        position = nil
    end

    local index = position .. side
    local group = StaticData.AMP_GROUPS_IND_STR[index]
    return group
end

---Check if a prosthesis is equippable. It depends whether the player has a cut limb or not on that specific side. There's an exception for Upper arm, obviously
---@param fullType string
---@return boolean
function ProsthesisHandler.CheckIfEquippable(fullType)
    --TOC_DEBUG.print("Current item is a prosthesis")
    local side = CommonMethods.GetSide(fullType)
    --TOC_DEBUG.print("Checking side: " .. tostring(side))

    local highestAmputatedLimbs = CachedDataHandler.GetHighestAmputatedLimbs(getPlayer():getUsername())

    if highestAmputatedLimbs then
        local hal = highestAmputatedLimbs[side]
        if hal and not string.contains(hal, "UpperArm") then
            --TOC_DEBUG.print("Found acceptable limb to use prosthesis => " .. tostring(hal))
            return true
        end
    end

    -- No acceptable cut limbs
    return false
end

---Handle equipping or unequipping prosthetics
---@param item InventoryItem
---@param isEquipping boolean
---@return boolean
function ProsthesisHandler.SearchAndSetupProsthesis(item, isEquipping)
    if not ProsthesisHandler.CheckIfProst(item) then return false end

    local group = ProsthesisHandler.GetGroup(item)
    TOC_DEBUG.print("Setup Prosthesis => " .. group .. " - is equipping? " .. tostring(isEquipping))
    local dcInst = DataController.GetInstance()
    dcInst:setIsProstEquipped(group, isEquipping)
    dcInst:apply()

    -- Calculates hands feasibility once again
    CachedDataHandler.CalculateBothHandsFeasibility()
    return true
end

-------------------------
--* Overrides *--


---@param item InventoryItem
---@param isEquippable boolean
---@return unknown
local function HandleProsthesisValidation(item, isEquippable)
    local isProst = ProsthesisHandler.CheckIfProst(item)
    if not isProst then return isEquippable end

    local fullType = item:getFullType() -- use fulltype for side
    if isEquippable then
        isEquippable = ProsthesisHandler.CheckIfEquippable(fullType)
    else
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
    -- self.extra is a string, not the item
    local testItem = instanceItem(self.extra)
    return HandleProsthesisValidation(testItem, isEquippable)
end


local og_ISClothingExtraAction_perform = ISClothingExtraAction.perform
function ISClothingExtraAction:perform()
    local extraItem = instanceItem(self.extra)
    ProsthesisHandler.SearchAndSetupProsthesis(extraItem, true)
    og_ISClothingExtraAction_perform(self)
end

local og_ISUnequipAction_perform = ISUnequipAction.perform
function ISUnequipAction:perform()

    --[[
    Horrendous workaround

    To unequp items, the java side uses WornItems.setItem, which has
    a check for multiItem. Basically, if it's active, it won't actually remove the item,
    fucking things up. So, to be 100% sure that we're removing the items, we're gonna
    disable and re-enable the multi-item bool for the Unequip Action.
    ]]

    local isProst = ProsthesisHandler.SearchAndSetupProsthesis(self.item, false)
    local group
    if isProst then
        group = BodyLocations.getGroup("Human")
        group:setMultiItem("TOC_ArmProst", false)
    end
    og_ISUnequipAction_perform(self)

    if isProst then
        group:setMultiItem("TOC_ArmProst", true)

        -- we need to fetch the limbname associated to the prosthesis
        local side = CommonMethods.GetSide(self.item:getFullType())
        local highestAmputatedLimbs = CachedDataHandler.GetHighestAmputatedLimbs(getPlayer():getUsername())
        if highestAmputatedLimbs then
            local hal = highestAmputatedLimbs[side]
            if hal then
            -- This could break if amputated limbs aren't cached for some reason
                triggerEvent("OnProsthesisUnequipped", hal)
            end

        end
    end
end

return ProsthesisHandler
