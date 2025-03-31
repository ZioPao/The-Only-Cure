local ProsthesisHandler = require("TOC/Handlers/ProsthesisHandler")     -- declared in common
local OverridenMethodsArchive = require("TOC/OverridenMethodsArchive")
local CommonMethods = require("TOC/CommonMethods")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")

-- FIX in B42 for some reason unequipping prosthesis doesn't work. Still not sure why

local og_ISClothingExtraAction_isValid = OverridenMethodsArchive.Get("ISClothingExtraAction_isValid")
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()
    local isEquippable = og_ISClothingExtraAction_isValid(self)
    -- self.extra is a string, not the item
    local testItem = instanceItem(self.extra)
    return ProsthesisHandler.Validate(testItem, isEquippable)
end


local og_ISClothingExtraAction_perform = OverridenMethodsArchive.Get("ISClothingExtraAction_perform")
function ISClothingExtraAction:perform()
    local extraItem = instanceItem(self.extra)
    ProsthesisHandler.SearchAndSetupProsthesis(extraItem, true)
    og_ISClothingExtraAction_perform(self)
end


local og_ISUnequipAction_complete = ISUnequipAction.complete
function ISUnequipAction:complete()
    local isProst = ProsthesisHandler.SearchAndSetupProsthesis(self.item, false)
    local group
    if isProst then
        group = BodyLocations.getGroup("Human")
        group:setMultiItem("TOC_ArmProst", false)
    end
    og_ISUnequipAction_complete(self)

    if isProst then
        group:setMultiItem("TOC_ArmProst", true)
    end

    -- TODO RUN WORKAROUND FOR MULTI ITEM HERE!!!!


end