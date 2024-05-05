local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local CommonMethods = require("TOC/CommonMethods")
local CommandsData = require("TOC/CommandsData")
require("TOC/Events")
------------------

---@class Main
local Main = {
    _version = "2.0.5"
}

function Main.Start()
    TOC_DEBUG.print("Starting The Only Cure version " .. tostring(Main._version))
    --Main.SetupTraits()
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
