local PlayerHandler = require("TOC_PlayerHandler.lua")


------------------
---@class Initialization
local Initialization = {}


function Initialization.StartMain()
    -- Starts initialization for local client
    Events.OnCreatePlayer.Add(PlayerHandler.InitializePlayer)

    Initialization.SetupTraits()

end

function Initialization.SetupTraits()
    -- TODO Where is Perks.Left_Hand?
    local amp1 = TraitFactory.addTrait("Amputee_Hand", getText("UI_trait_Amputee_Hand"), -8, getText("UI_trait_Amputee_Hand_desc"), false, false)
    amp1:addXPBoost(Perks.Left_Hand, 4)
    amp1:addXPBoost(Perks.Fitness, -1)
    amp1:addXPBoost(Perks.Strength, -1)

    local amp2 = TraitFactory.addTrait("Amputee_LowerArm", getText("UI_trait_Amputee_LowerArm"), -10, getText("UI_trait_Amputee_LowerArm_desc"), false, false)
    amp2:addXPBoost(Perks.Left_Hand, 4)
    amp2:addXPBoost(Perks.Fitness, -1)
    amp2:addXPBoost(Perks.Strength, -1)

    local amp3 = TraitFactory.addTrait("Amputee_UpperArm", getText("UI_trait_Amputee_UpperArm"), -20, getText("UI_trait_Amputee_UpperArm_desc"), false, false)
    amp3:addXPBoost(Perks.Left_Hand, 4)
    amp3:addXPBoost(Perks.Fitness, -1)
    amp3:addXPBoost(Perks.Strength, -1)

    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false,
        false)
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_LowerArm")
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_UpperArm")
    TraitFactory.setMutualExclusive("Amputee_LowerArm", "Amputee_UpperArm")
end



Events.OnGameBoot.Add(Initialization.StartMain)