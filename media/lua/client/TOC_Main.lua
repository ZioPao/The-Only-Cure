local PlayerHandler = require("TOC_PlayerHandler")


------------------
---@class Main
local Main = {}


---Setups the custom traits
function Main.SetupTraits()
    -- Perks.Left_Hand is defined in perks.txt

    local traitsTable = {}
    local trait1 = TraitFactory.addTrait("Amputee_Hand", getText("UI_trait_Amputee_Hand"), -8, getText("UI_trait_Amputee_Hand_desc"), false, false)
    traitsTable[1] = trait1

    local trait2 = TraitFactory.addTrait("Amputee_LowerArm", getText("UI_trait_Amputee_LowerArm"), -10, getText("UI_trait_Amputee_LowerArm_desc"), false, false)
    traitsTable[2] = trait2

    local trait3 = TraitFactory.addTrait("Amputee_UpperArm", getText("UI_trait_Amputee_UpperArm"), -20, getText("UI_trait_Amputee_UpperArm_desc"), false, false)
    traitsTable[2] = trait3

    for i=1, #traitsTable do
        local t = traitsTable[i]
        t:addXPBoost(Perks.Left_Hand, 4)
        t:addXPBoost(Perks.Fitness, -1)
        t:addXPBoost(Perks.Strength, -1)
    end

    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitivedesc"), false, false)

    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_LowerArm")
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_UpperArm")
    TraitFactory.setMutualExclusive("Amputee_LowerArm", "Amputee_UpperArm")
end


function Main.Start()
    Main.SetupTraits()



    -- Starts initialization for local client
    Events.OnCreatePlayer.Add(PlayerHandler.InitializePlayer)

end

--* Events *--

Events.OnGameBoot.Add(Main.Start)