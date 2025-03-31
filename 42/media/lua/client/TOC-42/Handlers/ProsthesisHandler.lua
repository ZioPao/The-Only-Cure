local ProsthesisHandler = require("TOC/Handlers/ProsthesisHandler")     -- declared in common



local og_ISClothingExtraAction_isValid = ISClothingExtraAction.isValid
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()
    local isEquippable = og_ISClothingExtraAction_isValid(self)
    -- self.extra is a string, not the item
    local testItem = instanceItem(self.extra)
    return ProsthesisHandler.Validate(testItem, isEquippable)
end


local og_ISClothingExtraAction_perform = ISClothingExtraAction.perform
function ISClothingExtraAction:perform()
    local extraItem = instanceItem(self.extra)
    ProsthesisHandler.SearchAndSetupProsthesis(extraItem, true)
    og_ISClothingExtraAction_perform(self)
end

