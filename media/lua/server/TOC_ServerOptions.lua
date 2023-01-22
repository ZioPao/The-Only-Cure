local options = TOC_Options

-- Check actual options at game loading.
Events.OnGameStart.Add(function()
  if not isClient() then -- only host may take these options
    print("checkbox1 = ", options.box1)
    print("checkbox2 = ", options.box2)
  end
end)
