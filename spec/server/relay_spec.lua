-- Server-side relay specs.
--
-- These run on the DEDICATED SERVER (spec/server/ is executed by the server API,
-- see ZBSpec's MPHarness). They exercise TOC's server relay handlers directly,
-- so they verify the server half of the client<->server relay without needing a
-- client to complete the (currently racy) non-Steam connection.
--
-- Handlers that push data to a player (dcInst:apply / sendServerCommand) need a
-- real IsoPlayer and are only exercised when a client is actually connected;
-- the player-free handlers run unconditionally.

if isClient() then
    return ZBSpec.run()
end

local DataController = require("TOC/Controllers/DataController")
local ServerDataController = require("TOC/Controllers/ServerDataController")
local ServerRelayCommands = require("TOC/ServerRelayCommands")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")

-- A lightweight stand-in for an IsoPlayer, good enough for the relay handlers
-- that only need a username / online id.
local function stubPlayer(username, onlineID)
    return {
        _username = username,
        _onlineID = onlineID or 1,
        getUsername = function(self) return self._username end,
        getOnlineID = function(self) return self._onlineID end,
    }
end

local function reset(username)
    ServerDataController.Initialize(username, true)
    CachedDataHandler.Setup(username)
end

describe("TOC server relay (dedicated server)", function()
    it("initialises server data for a username", function()
        reset("MPTest")
        local dc = DataController.GetInstance("MPTest")
        assert.is_not_nil(dc)
        assert.is_true(dc:getIsDataReady())
        assert.is_false(dc:getIsAnyLimbCut())
    end)

    it("UpdateDataControllerFromClient applies cicatrization fields", function()
        reset("MPTest")
        local pl = stubPlayer("MPTest")

        ServerRelayCommands.UpdateDataControllerFromClient(pl, {
            limbName = "Hand_L",
            cicTime = 42,
            dirtyness = 0.5,
            isCicatrized = true,
        })

        local dc = DataController.GetInstance("MPTest")
        assert.eq(42, dc:getCicatrizationTime("Hand_L"))
        assert.eq(0.5, dc:getWoundDirtyness("Hand_L"))
        assert.is_true(dc:getIsCicatrized("Hand_L"))
    end)

    it("UpdateDataControllerFromClient handles the ignored-part path (no limbName)", function()
        reset("MPTest")
        local pl = stubPlayer("MPTest")

        -- Must not throw even though limbName is absent.
        ServerRelayCommands.UpdateDataControllerFromClient(pl, {
            isIgnoredPartInfected = true,
        })

        assert.is_true(DataController.GetInstance("MPTest"):getIsIgnoredPartInfected())
    end)

    it("UpdateDataControllerFromClient applies isInfected / isCauterized", function()
        reset("MPTest")
        local pl = stubPlayer("MPTest")

        ServerRelayCommands.UpdateDataControllerFromClient(pl, {
            limbName = "ForeArm_R",
            isInfected = true,
            isCauterized = true,
        })

        local dc = DataController.GetInstance("MPTest")
        assert.is_true(dc:getIsInfected("ForeArm_R"))
        assert.is_true(dc:getIsCauterized("ForeArm_R"))
    end)

    it("RelayRequestDataController creates a ready instance", function()
        reset("MPTest")
        -- Pass nil player so Initialize skips apply() (which needs a real IsoPlayer).
        ServerRelayCommands.RelayRequestDataController(nil, { username = "MPTest", isForced = true })

        local dc = DataController.GetInstance("MPTest")
        assert.is_not_nil(dc)
        assert.is_true(dc:getIsDataReady())
    end)

    it("cache recalculates from server-side cut state", function()
        reset("MPTest")
        -- Drive the server DC directly (no player push needed) and verify cache.
        DataController.GetInstance("MPTest"):setCutLimb("Hand_L", false, false, false, 0)
        CachedDataHandler.CalculateCacheableValues("MPTest")

        assert.is_false(CachedDataHandler.GetHandFeasibility("L", "MPTest"))
        assert.is_true(CachedDataHandler.GetHandFeasibility("R", "MPTest"))
    end)

    -- The following need a real connected IsoPlayer because they call
    -- dcInst:apply() / sendServerCommand(). Run them only when one exists.
    it("RelayProsthesisState toggles the prosthesis flag (requires a client)", function()
        reset("MPTest")
        local players = getOnlinePlayers()
        if players == nil or players:size() == 0 then
            return
        end
        local realPlayer = players:get(0)
        ServerDataController.Initialize(realPlayer:getUsername(), true)

        ServerRelayCommands.RelayProsthesisState(realPlayer, { group = "Top_L", isEquipped = true })
        local dc = DataController.GetInstance(realPlayer:getUsername())
        assert.is_true(dc:getIsProstEquipped("Hand_L"))
    end)
end)

return ZBSpec.run()
