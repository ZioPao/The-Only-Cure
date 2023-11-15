-- TODO This part is still one of the weakest and we don't have a better solution yet
require("TOC/Debug")

-- AddBodyLocationBefore("TOC_Arm_R", "Shoes")
-- AddBodyLocationBefore("TOC_Arm_L", "Shoes")

-- AddBodyLocationBefore("TOC_ArmProst_R", "TOC_Arm_R")
-- AddBodyLocationBefore("TOC_ArmProst_L", "TOC_Arm_L")

-- Locations must be declared in render-order.
-- Location IDs must match BodyLocation= and CanBeEquipped= values in items.txt.
local group = BodyLocations.getGroup("Human")

group:getOrCreateLocation("TOC_Arm_R")
group:getOrCreateLocation("TOC_ArmProst_R")

group:getOrCreateLocation("TOC_Arm_L")
group:getOrCreateLocation("TOC_ArmProst_L")
