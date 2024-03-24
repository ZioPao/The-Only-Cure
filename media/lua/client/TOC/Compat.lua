
--* BRUTAL HANDS -- *

local function HandleModCompatibility()

    if getActivatedMods():contains('BrutalHandwork') then
        BrutalHands = BrutalHands or {}
        BrutalHands.TOC = require("TOC/API")

        -- Brutal hands has a TOC_COMPAT but its check is wrong and uses an old API.
    end
end

Events.OnGameStart.Add(HandleModCompatibility)

