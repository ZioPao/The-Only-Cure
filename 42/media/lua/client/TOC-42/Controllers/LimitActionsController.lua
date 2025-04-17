local LimitActionsController = require("TOC/Controllers/LimitActionsController")     -- declared in common
local OverridenMethodsArchive = require("TOC/OverridenMethodsArchive")

local og_ISClothingExtraAction_isValid = OverridenMethodsArchive.Get("ISClothingExtraAction_isValid")
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()
    TOC_DEBUG.print("Inside ISClothingExtraAction:isValid 42")
    TOC_DEBUG.print(OverridenMethodsArchive.Get("ISClothingExtraAction_isValid"))
    return LimitActionsController.WrapClothingAction(self, og_ISClothingExtraAction_isValid, instanceItem(self.extra))
end