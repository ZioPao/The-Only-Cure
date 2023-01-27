--Default options.
local options = {
  roll_up_sleeves_on_amputated_limbs = true,

}

--https://steamcommunity.com/workshop/filedetails/discussion/2169435993/4260919351480715709/#c4260919351482087243


-- Connecting the options to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
  print("TOC: Found ModOptions, loading it")
  local settings = ModOptions:getInstance(options, "Amputation2", "The Only Cure but better")
  
  settings.names = {
    roll_up_sleeves_on_amputated_limbs = "Roll up jacket sleeves for amputated limbs",
  }
  
  
  ModOptions:loadFile()

  local roll_up_sleeves = settings:getData("roll_up_sleeves_on_amputated_limbs")







  function roll_up_sleeves:OnApply(val)
    self:resetLua()
  end

  local function TocOnResetLua(reason)
    print("TOC: OnResetLua running TocSetSleeves")
    TocSetSleeves(options.roll_up_sleeves_on_amputated_limbs)

  end
  Events.OnResetLua.Add(TocOnResetLua)
else
  -------------------
  -- DEFAULT SETTINGS
  ------------------
  -- TODO Test this when mod options is not installed
  TocSetSleeves(false)

end

--Make a link
TOC_Options = {}
TOC_Options = options

