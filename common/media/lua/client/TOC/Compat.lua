
---@class Compat
---@field handlers table<string, {fun : function, isActive : boolean}>
local Compat = {
    handlers = {}
}

--- Brutal hands has a TOC_COMPAT but its check is wrong and uses an old API.
function Compat.BrutalHandwork()
    BrutalHands = BrutalHands or {}
    BrutalHands.TOC = require("TOC/API")

end

--- Was handled inside old TOC
function Compat.FancyHandwork()
    require("TimedActions/FHSwapHandsAction")
    local og_FHSwapHandsAction_isValid = FHSwapHandsAction.isValid
    function FHSwapHandsAction:isValid()
        local tocApi = require("TOC/API")
        if tocApi.hasBothHands(self.character) then
            return og_FHSwapHandsAction_isValid(self)
        else
            return false
        end
    end
end


function Compat.iMeds()
    require("Component/Interface/Service/ContextMenu/Menu/HealthPanel/HealthPanelMenuInitializer")
    -- placeholder, in case we need to do something more drastic with it.
end


------------------------------

Compat.handlers = {
    ["BrutalHandwork"] = {
        fun = Compat.BrutalHandwork,
        isActive = false},
    ["FancyHandwork"] = {
        fun = Compat.FancyHandwork,
        isActive = false},

    -- either or
    ['iMeds'] = {
        fun = Compat.iMeds,
        isActive = false},
    ['iMedsFixed'] = {
        fun = Compat.iMeds,
        isActive = false}
}


function Compat.RunModCompatibility()
    local activatedMods = getActivatedMods()
    TOC_DEBUG.print("Checking for mods compatibility")

    for k, modCompatHandler in pairs(Compat.handlers) do
        if activatedMods:contains(k) then
            TOC_DEBUG.print("Found " .. k .. ", running compatibility handler")
            modCompatHandler.fun()
            modCompatHandler.isActive = true
        end
    end



end


Events.OnGameStart.Add(Compat.RunModCompatibility)

return Compat