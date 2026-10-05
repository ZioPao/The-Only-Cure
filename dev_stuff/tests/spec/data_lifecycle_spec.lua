local t = require("harness.testkit")
local H = require("harness.init")

local DataController = require("TOC/Controllers/DataController")
local ServerDataController = require("TOC/Controllers/ServerDataController")
local ClientDataController = require("TOC/Controllers/ClientDataController")
local CommandsData = require("TOC/CommandsData")
local StaticData = require("TOC/StaticData")

local Mocks = H.Mocks

t.describe("ServerDataController: Initialize", function()
    t.it("creates a ready DataController with default data", function()
        H.reset()
        local dc = ServerDataController.Initialize("Srv", true)
        t.assertNotNil(dc)
        t.assertTrue(dc:getIsDataReady())
        t.assertFalse(dc:getIsAnyLimbCut())

        for _, limb in ipairs(StaticData.LIMBS_STR) do
            t.assertFalse(dc:getIsCut(limb))
        end
    end)

    t.it("persists data to ModData under the correct key", function()
        H.reset()
        ServerDataController.Initialize("Srv", true)
        local key = CommandsData.GetKey("Srv")
        t.assertTable(Mocks.state.modData[key])
        t.assertTable(Mocks.state.modData[key].limbs)
    end)

    t.it("GetOrCreate returns the existing ready instance", function()
        H.reset()
        local first = ServerDataController.Initialize("Srv", true)
        local second = ServerDataController.GetOrCreate("Srv")
        t.assertEquals(first, second)
    end)

    t.it("reuses state across Initialize calls when not forced", function()
        H.reset()
        local dc = ServerDataController.Initialize("Srv", true)
        dc:setCutLimb("Hand_L", false, false, false, 0)

        local again = ServerDataController.Initialize("Srv", false)
        t.assertTrue(again:getIsCut("Hand_L"))
    end)

    t.it("a forced reset clears existing state", function()
        H.reset()
        local dc = ServerDataController.Initialize("Srv", true)
        dc:setCutLimb("Hand_L", false, false, false, 0)

        local reset = ServerDataController.Initialize("Srv", true)
        t.assertFalse(reset:getIsCut("Hand_L"))
        t.assertFalse(reset:getIsAnyLimbCut())
    end)
end)

t.describe("ClientDataController: OnDataReceived", function()
    local function dataWithCut(username, limb)
        local toc = { limbs = {}, prostheses = {}, isAnyLimbCut = false, isIgnoredPartInfected = false }
        for _, l in ipairs(StaticData.LIMBS_STR) do
            toc.limbs[l] = { isCut = false, isVisible = false, isCicatrized = false, isCauterized = false, isInfected = false, woundDirtyness = 0, cicatrizationTime = 0 }
        end
        for _, g in ipairs(StaticData.AMP_GROUPS_STR) do
            toc.prostheses[g] = { isProstEquipped = false, prostFactor = 0 }
        end
        if limb then
            toc.limbs[limb].isCut = true
            toc.isAnyLimbCut = true
        end
        toc._username = username
        return toc
    end

    t.it("ignores the startup 'Bob' key", function()
        H.reset()
        ClientDataController.OnDataReceived("TOC_Bob", dataWithCut("Bob", "Hand_L"))
        t.assertNil(DataController.GetInstance("Bob"))
    end)

    t.it("ignores keys without the TOC prefix", function()
        H.reset()
        ClientDataController.OnDataReceived("Other_Player", dataWithCut("Player", "Hand_L"))
        t.assertNil(DataController.GetInstance("Player"))
    end)

    t.it("ignores when there is no DC instance for the user", function()
        H.reset()
        ClientDataController.OnDataReceived("TOC_Ghost", dataWithCut("Ghost", "Hand_L"))
        t.assertNil(DataController.GetInstance("Ghost"))
    end)

    t.it("populates an existing shell instance and marks it ready", function()
        H.reset()
        local dc = DataController:new("Recv", true)
        t.assertFalse(dc:getIsDataReady())

        ClientDataController.OnDataReceived("TOC_Recv", dataWithCut("Recv", "Hand_L"))

        t.assertTrue(dc:getIsDataReady())
        t.assertTrue(dc:getIsCut("Hand_L"))
    end)

    t.it("rejects malformed payloads (no limbs)", function()
        H.reset()
        local dc = DataController:new("Recv2", true)
        ClientDataController.OnDataReceived("TOC_Recv2", {})
        t.assertFalse(dc:getIsDataReady())
    end)
end)
