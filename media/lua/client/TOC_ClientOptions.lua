--Default options.
local options = {
  box1 = true,
  box2 = false
}

-- Connecting the options to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
  ModOptions:getInstance(options, "Amputation2", "The Only Cure but better")
end

--Make a link
TOC_Options = {}
TOC_Options = options
