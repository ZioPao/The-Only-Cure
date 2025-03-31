local ProsthesisHandler = require("TOC/Handlers/ProsthesisHandler")     -- declared in common
local OverridenMethodsArchive = require("TOC/OverridenMethodsArchive")

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
	TOC_DEBUG.print("ISUnequipAction:complete")
    TOC_DEBUG.print(self.item:getFullType())
    self.character:removeWornItem(self.item)
    og_ISUnequipAction_complete(self)


end