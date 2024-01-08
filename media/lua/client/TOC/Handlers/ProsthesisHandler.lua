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
    if item == nil then return false end
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

---Check if a prosthesis is equippable. It depends whether the player has a cut limb or not on that specific side. There's an exception for Upper arm, obviously
---@param bodyLocation string
---@return boolean
function ProsthesisHandler.CheckIfEquippable(bodyLocation)
    TOC_DEBUG.print("current item is a prosthesis")
    local side = CommonMethods.GetSide(bodyLocation)
    TOC_DEBUG.print("checking side: " .. tostring(side))

    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(getPlayer():getUsername())
    for k, _ in pairs(amputatedLimbs) do
        local limbName = k
        if string.contains(limbName, side) and not string.contains(limbName, "UpperArm") then
            TOC_DEBUG.print("found acceptable limb to use prosthesis")
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
    TOC_DEBUG.print("applying prosthesis stuff for " .. group)
    local dcInst = DataController.GetInstance()
    dcInst:setIsProstEquipped(group, isEquipping)
    dcInst:apply()
    
end


-------------------------
--* Events *--




-------------------------
--* Overrides *--


---@diagnostic disable-next-line: duplicate-set-field
local og_ISWearClothing_isValid = ISWearClothing.isValid
function ISWearClothing:isValid()
    local isEquippable = og_ISWearClothing_isValid(self)

    -- TODO Do we actually need this?
    local isProst = ProsthesisHandler.CheckIfProst(self.item)

    if not isProst then return isEquippable end

    --the item that we gets is the OG one, so if we're coming from the left one and wanna switch to the right one we're still gonna get the Left bodylocation
    local bodyLocation = self.item:getBodyLocation()
    if isEquippable and string.contains(bodyLocation, bodyLocArmProst) then
        isEquippable = ProsthesisHandler.CheckIfEquippable(bodyLocation)
    end

    return isEquippable
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

     --the item that we gets is the OG one, so if we're coming from the left one and wanna switch to the right one we're still gonna get the Left bodylocation
    local testItem = InventoryItemFactory.CreateItem(self.extra)
    local isProst = ProsthesisHandler.CheckIfProst(testItem)

    -- Early exit if it's not a prostheesis
    if not isProst then return isEquippable end

    if isEquippable and isProst then 
        local bodyLocation = testItem:getBodyLocation()
        isEquippable = ProsthesisHandler.CheckIfEquippable(bodyLocation)

        -- Just to let the player know
        if not isEquippable then
            -- TODO if its in here then it's gonna run at least 2 times
            getPlayer():Say(getText("UI_Say_CantEquip"))
        end

    end

    return isEquippable
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
