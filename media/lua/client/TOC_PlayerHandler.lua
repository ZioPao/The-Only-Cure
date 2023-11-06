local ModDataHandler = require("TOC_ModDataHandler")
local StaticData = require("TOC_StaticData")
-----------


---@class PlayerHandler
local PlayerHandler = {}


---Setup player modData
---@param _ nil
---@param playerObj IsoPlayer
function PlayerHandler.InitializePlayer(_, playerObj)

    PlayerHandler.modDataHandler = ModDataHandler:new(playerObj)
    PlayerHandler.modDataHandler:setup()

end

---...
---@param playerObj IsoPlayer
function PlayerHandler.ManageTraits(playerObj)

    for k,v in pairs(StaticData.TRAITS_BP) do
        if playerObj:HasTrait(k) then PlayerHandler.ForceCutLimb(v) end
    end
    
    -- -- Setup traits
    -- if player:HasTrait("Amputee_Hand") then
    --     TOC.CutLimbForTrait(player, modData.TOC, "Left_Hand")
    -- elseif player:HasTrait("Amputee_LowerArm") then
    --     TOC.CutLimbForTrait(player, modData.TOC, "Left_LowerArm")
    -- elseif player:HasTrait("Amputee_UpperArm") then
    --     TOC.CutLimbForTrait(player, modData.TOC, "Left_UpperArm")
    -- end
end

---comment
---@param limbName string 
function PlayerHandler.ForceCutLimb(limbName)
    PlayerHandler.modDataHandler:setCutLimb(limbName, true, true, true)
    -- TODO Spawn amputation item
end


return PlayerHandler