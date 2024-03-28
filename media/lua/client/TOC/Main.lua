local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local CommonMethods = require("TOC/CommonMethods")
local CommandsData = require("TOC/CommandsData")
require("TOC/Events")
------------------

---@class Main
local Main = {
    _version = 2.0
}

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
end

function Main.SetupEvents()
    local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
    Events.OnReceivedTocData.Add(CachedDataHandler.CalculateCacheableValues)
end

function Main.InitializePlayer()
    ---Looop until we've successfully initialized the mod
    local function TryToInitialize()
        local pl = getPlayer()
        TOC_DEBUG.print("Current username in TryToInitialize: " .. pl:getUsername())
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
function Main.WipeData(player)
    TOC_DEBUG.print("Wiping data after death")
    local key = CommandsData.GetKey(player:getUsername())

    --ModData.remove(key)



    if not isClient() then
        -- For SP, it's enough just removing the data this way
        ModData.remove(key)
    else
        -- Different story for MP, we're gonna 'force' it to reload it
        -- at the next character by passing an empty mod data
        ModData.add(key, {})
        ModData.transmit(key)
    end
end

--* Events *--

Events.OnGameStart.Add(Main.Start)
Events.OnCreatePlayer.Add(Main.InitializePlayer)
Events.OnPlayerDeath.Add(Main.WipeData)
