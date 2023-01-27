local options = TOC_Options

-- TODO Can't trigger OnGameBoot from here since it's client only



-- Check actual options at game loading.
Events.OnGameStart.Add(function()
  if not isClient() then -- only host may take these options
    print("Roll up sleeves for amputated limbs = ", options.rollUpSleeveForAmputatedLimbs)



  end
end)


