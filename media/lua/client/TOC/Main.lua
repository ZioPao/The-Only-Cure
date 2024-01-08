local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local CommonMethods = require("TOC/CommonMethods")
local CommandsData = require("TOC/CommandsData")
------------------


---@class Main
local Main = {}

---Setups the custom traits
function Main.SetupTraits()
    -- Perks.Left_Hand is defined in perks.txt

    local traitsTable = {
        [1] = TraitFactory.addTrait("Amputee_Hand", getText("UI_trait_Amputee_Hand"), -8, getText("UI_trait_Amputee_Hand_desc"), false, false),
        [2] = TraitFactory.addTrait("Amputee_LowerArm", getText("UI_trait_Amputee_LowerArm"), -10, getText("UI_trait_Amputee_LowerArm_desc"), false, false),
        [3] = TraitFactory.addTrait("Amputee_UpperArm", getText("UI_trait_Amputee_UpperArm"), -20, getText("UI_trait_Amputee_UpperArm_desc"), false, false)
    }

    for i=1, #traitsTable do

        ---@type Trait
        local t = traitsTable[i]
        ---@diagnostic disable-next-line: undefined-field
        t:addXPBoost(Perks.Left_Hand, 4)
        t:addXPBoost(Perks.Fitness, -1)
        t:addXPBoost(Perks.Strength, -1)
    end

    TraitFactory.addTrait("Insensitive", getText("UI_trait_Insensitive"), 6, getText("UI_trait_Insensitive_desc"), false, false)

    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_LowerArm")
    TraitFactory.setMutualExclusive("Amputee_Hand", "Amputee_UpperArm")
    TraitFactory.setMutualExclusive("Amputee_LowerArm", "Amputee_UpperArm")
end

function Main.Start()
    TOC_DEBUG.print("running Start method")
    Main.SetupTraits()
    Main.SetupEvents()
    -- Starts initialization for local client
    Events.OnGameStart.Add(Main.Initialize)

end

function Main.SetupEvents()
    --Triggered when a limb has been amputated
    LuaEventManager.AddEvent("OnAmputatedLimb")

    -- Triggered when data is ready
    LuaEventManager.AddEvent("OnReceivedTocData")
    local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
    Events.OnReceivedTocData.Add(CachedDataHandler.CalculateHighestAmputatedLimbs)

end

function Main.Initialize()
    ---Looop until we've successfully initialized the mod
    local function TryToInitialize()
        local pl = getPlayer()
        TOC_DEBUG.print("[Main] Current username in TryToInitialize: " .. pl:getUsername())
        if pl:getUsername() == "Bob" then
            TOC_DEBUG.print("Username is still Bob, waiting")
            return
        end

        LocalPlayerController.InitializePlayer(false)
        Events.OnTick.Remove(TryToInitialize)
    end
    CommonMethods.SafeStartEvent("OnTick", TryToInitialize)
end

---Clean the TOC table for that SP player, to prevent from clogging it up
---@param player IsoPlayer
function Main.WipeSinglePlayerData(player)
    local key = CommandsData.GetKey(player:getUsername())
    ModData.remove(key)
    ModData.transmit(key)
end

--* Events *--

Events.OnGameBoot.Add(Main.Start)

if not isClient() and not isServer() then
    Events.OnPlayerDeath.Add(Main.WipeSinglePlayerData)
end
