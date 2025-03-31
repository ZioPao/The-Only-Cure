local LimitActionsController = require("TOC/Controllers/LimitActionsController")     -- declared in common

local og_ISClothingExtraAction_isValid = ISClothingExtraAction.isValid
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()
    return LimitActionsController.WrapClothingAction(self, og_ISClothingExtraAction_isValid, instanceItem(self.extra))
end