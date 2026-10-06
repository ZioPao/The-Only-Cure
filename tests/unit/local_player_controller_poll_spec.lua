local t = require("harness.testkit")
local H = require("harness.init")

local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local CommandsData = require("TOC/CommandsData")

local Mocks = H.Mocks

local ALL_LIMBS = { "Hand_L", "Hand_R", "ForeArm_L", "ForeArm_R", "UpperArm_L", "UpperArm_R" }

---Install a local player whose given limbs are bitten/infected.
---@param bitten string?
---@param infected string?
local function installPlayer(bitten, infected)
    local parts = {}
    for _, limb in ipairs(ALL_LIMBS) do
        parts[limb] = Mocks.makeBodyPart({
            bitten = limb == bitten,
            infected = limb == infected,
        })
    end
    local player = Mocks.makePlayer({
        username = "Biter",
        bodyDamage = Mocks.makeBodyDamage(parts),
    })
    Mocks.state.player = player
    return player, parts
end

local function forceScanTick()
    LocalPlayerController.sanitizePollTick = LocalPlayerController.sanitizePollInterval - 1
    LocalPlayerController.sanitizeLastRequestTick = {}
end

t.describe("LocalPlayerController.PollCutLimbsForBites (#279/#290)", function()
    t.it("requests a server sanitize for a bite on a cut limb", function()
        local dc = H.initPlayer("Biter")
        dc:setCutLimb("Hand_L", false, false, false, 0)
        installPlayer("Hand_L")
        forceScanTick()

        LocalPlayerController.PollCutLimbsForBites(Mocks.state.player)

        t.assertEquals(1, #Mocks.state.clientCommands)
        local cmd = Mocks.state.clientCommands[1]
        t.assertEquals(CommandsData.modules.TOC_RELAY, cmd.module)
        t.assertEquals(CommandsData.server.Relay.RequestSanitizeCutLimb, cmd.command)
        t.assertEquals("Hand_L", cmd.args.limbName)
    end)

    t.it("requests a sanitize for an infected (not just bitten) cut limb", function()
        local dc = H.initPlayer("Biter")
        dc:setCutLimb("ForeArm_R", false, false, false, 0)
        installPlayer(nil, "ForeArm_R")
        forceScanTick()

        LocalPlayerController.PollCutLimbsForBites(Mocks.state.player)

        t.assertEquals(1, #Mocks.state.clientCommands)
        t.assertEquals("ForeArm_R", Mocks.state.clientCommands[1].args.limbName)
    end)

    t.it("ignores a bite on a limb that is not cut", function()
        local dc = H.initPlayer("Biter")
        dc:setCutLimb("Hand_L", false, false, false, 0)
        installPlayer("Hand_R")
        forceScanTick()

        LocalPlayerController.PollCutLimbsForBites(Mocks.state.player)

        t.assertEquals(0, #Mocks.state.clientCommands)
    end)

    t.it("does nothing when no limb is cut", function()
        H.initPlayer("Biter")
        installPlayer("Hand_L")
        forceScanTick()

        LocalPlayerController.PollCutLimbsForBites(Mocks.state.player)

        t.assertEquals(0, #Mocks.state.clientCommands)
    end)
end)
