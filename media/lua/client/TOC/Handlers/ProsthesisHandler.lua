local CommonMethods = require("TOC/CommonMethods")
local PlayerHandler = require("TOC/Handlers/PlayerHandler")

-------------------------

---@class ProsthesisHandler
local ProsthesisHandler = {}


---Cache the correct texture for the Health Panel for the currently equipped prosthesis
function ProsthesisHandler.SetHealthPanelTexture()
    -- TODO do it
end

---Check if a prosthesis is equippable. It depends whether the player has a cut limb or not on that specific side. There's an exception for Upper arm, obviously
---@param bodyLocation string
---@return boolean
function ProsthesisHandler.CheckIfEquippable(bodyLocation)
    print("Current item is a prosthesis")
    local side = CommonMethods.GetSide(bodyLocation)

    for i=1, #PlayerHandler.amputatedLimbs do
        local limbName = PlayerHandler.amputatedLimbs[i]
        if string.contains(limbName, side) and not string.contains(limbName, "UpperArm") then
            return true
        end
    end

    -- No acceptable cut limbs
    getPlayer():Say("I can't equip this")
    return false
end

--* Overrides *--

function ISWearClothing:isValid()
    local bodyLocation = self.item:getBodyLocation()
    if not string.contains(bodyLocation, "TOC_ArmProst") then
        return true
    else
        return ProsthesisHandler.CheckIfEquippable(bodyLocation)
    end
end

local og_ISClothingExtraAction_isValid = ISClothingExtraAction.isValid
function ISClothingExtraAction:isValid()
    local bodyLocation = self.item:getBodyLocation()

    if og_ISClothingExtraAction_isValid(self) and not string.contains(bodyLocation, "TOC_ArmProst") then
        return true
    else
        return ProsthesisHandler.CheckIfEquippable(bodyLocation)

    end
end


return ProsthesisHandler