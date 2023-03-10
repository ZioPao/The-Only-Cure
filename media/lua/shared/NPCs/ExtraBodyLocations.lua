require "NPCs/BodyLocationsAPI"

local bodyLocations = {"TOC_ArmRight", "TOC_ArmLeft", "TOC_ArmRightProsthesis", "TOC_ArmLeftProsthesis"}


for _, v in ipairs(bodyLocations) do
  print(v)
  BodyLocationsAPI.moveOrCreateBefore(v, "Shoes")

end
