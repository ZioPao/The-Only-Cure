

local function HandleModCompatibility()



    local activatedMods = getActivatedMods()
    TOC_DEBUG.print("Checking for mods compatibility")

    --[[
        Brutal hands has a TOC_COMPAT but its check is wrong and uses an old API.
    ]]
    if activatedMods:contains('BrutalHandwork') then
        TOC_DEBUG.print("found BrutalHandwork, activating compat module")
        BrutalHands = BrutalHands or {}
        BrutalHands.TOC = require("TOC/API")
    end

    --[[
        Was handled inside old TOC
    ]]
    if activatedMods:contains('FancyHandwork') then
        TOC_DEBUG.print("found FancyHandwork, activating compat module")

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
end

Events.OnGameStart.Add(HandleModCompatibility)

