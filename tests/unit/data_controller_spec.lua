local t = require("harness.testkit")
local H = require("harness.init")

local StaticData = require("TOC/StaticData")
local DataController = require("TOC/Controllers/DataController")

t.describe("DataController: defaults and flags", function()
    t.it("all limbs start uncut and data is ready", function()
        local dc = H.initPlayer("Tester")
        for _, limbName in ipairs(StaticData.LIMBS_STR) do
            t.assertBoolean(dc:getIsCut(limbName))
            t.assertFalse(dc:getIsCut(limbName))
        end
    end)

    t.it("default flags are false", function()
        local dc = H.initPlayer("Tester")
        t.assertFalse(dc:getIsAnyLimbCut())
        t.assertFalse(dc:getIsIgnoredPartInfected())
        t.assertTrue(dc:getIsDataReady())
    end)

    t.it("round-trips generic flags", function()
        local dc = H.initPlayer("Tester")
        dc:setIsAnyLimbCut(true)
        t.assertTrue(dc:getIsAnyLimbCut())
        dc:setIsAnyLimbCut(false)
        t.assertFalse(dc:getIsAnyLimbCut())

        dc:setIsIgnoredPartInfected(true)
        t.assertTrue(dc:getIsIgnoredPartInfected())
        dc:setIsIgnoredPartInfected(false)
        t.assertFalse(dc:getIsIgnoredPartInfected())
    end)
end)

t.describe("DataController: limb setters/getters", function()
    t.it("round-trips isCut", function()
        local dc = H.initPlayer("Tester")
        dc:setIsCut("Hand_L", true)
        t.assertTrue(dc:getIsCut("Hand_L"))
        dc:setIsCut("Hand_L", false)
        t.assertFalse(dc:getIsCut("Hand_L"))
    end)

    t.it("round-trips isCauterized", function()
        local dc = H.initPlayer("Tester")
        dc:setIsCauterized("ForeArm_R", true)
        t.assertTrue(dc:getIsCauterized("ForeArm_R"))
    end)

    t.it("round-trips isCicatrized", function()
        local dc = H.initPlayer("Tester")
        dc:setIsCicatrized("UpperArm_L", true)
        t.assertTrue(dc:getIsCicatrized("UpperArm_L"))
    end)

    t.it("round-trips numeric fields", function()
        local dc = H.initPlayer("Tester")
        dc:setCicatrizationTime("Hand_R", 77)
        t.assertNumber(dc:getCicatrizationTime("Hand_R"))
        t.assertEquals(77, dc:getCicatrizationTime("Hand_R"))

        dc:setWoundDirtyness("ForeArm_L", 0.5)
        t.assertEquals(0.5, dc:getWoundDirtyness("ForeArm_L"))
    end)

    t.it("decreases cicatrization time", function()
        local dc = H.initPlayer("Tester")
        dc:setCicatrizationTime("Hand_L", 10)
        dc:decreaseCicatrizationTime("Hand_L")
        t.assertEquals(9, dc:getCicatrizationTime("Hand_L"))
    end)

    t.it("maps prosthesis group to limb", function()
        local dc = H.initPlayer("Tester")
        dc:setIsProstEquipped("Top_L", true)
        t.assertTrue(dc:getIsProstEquipped("Hand_L"))
        dc:setIsProstEquipped("Top_L", false)
        t.assertFalse(dc:getIsProstEquipped("Hand_L"))
    end)
end)

t.describe("DataController: setCutLimb cascade", function()
    t.it("hand has no dependencies", function()
        local dc = H.initPlayer("Tester")
        dc:setCutLimb("Hand_L", false, false, false, 0)
        t.assertTrue(dc:getIsCut("Hand_L"))
        t.assertTrue(dc:getIsVisible("Hand_L"))
        t.assertTrue(dc:getIsAnyLimbCut())
        t.assertFalse(dc:getIsCut("Hand_R"))
        t.assertFalse(dc:getIsCut("ForeArm_L"))
    end)

    t.it("forearm also cuts the hand", function()
        local dc = H.initPlayer("Tester")
        dc:setCutLimb("ForeArm_L", false, false, false, 0)
        t.assertTrue(dc:getIsCut("ForeArm_L"))
        t.assertTrue(dc:getIsCut("Hand_L"))
        t.assertTrue(dc:getIsVisible("ForeArm_L"))
        t.assertFalse(dc:getIsVisible("Hand_L"))
    end)

    t.it("upper arm cuts the whole chain", function()
        local dc = H.initPlayer("Tester")
        dc:setCutLimb("UpperArm_L", false, false, false, 0)
        t.assertTrue(dc:getIsCut("UpperArm_L"))
        t.assertTrue(dc:getIsCut("ForeArm_L"))
        t.assertTrue(dc:getIsCut("Hand_L"))
        t.assertTrue(dc:getIsVisible("UpperArm_L"))
        t.assertFalse(dc:getIsVisible("ForeArm_L"))
        t.assertFalse(dc:getIsVisible("Hand_L"))
    end)

    t.it("does not contaminate the other side", function()
        local dc = H.initPlayer("Tester")
        dc:setCutLimb("Hand_L", false, false, false, 0)
        t.assertFalse(dc:getIsCut("Hand_R"))
        t.assertFalse(dc:getIsCut("ForeArm_R"))
        t.assertFalse(dc:getIsCut("UpperArm_R"))
    end)
end)

t.describe("DataController: WhenReady", function()
    t.it("fires immediately when data is already ready", function()
        local dc = H.initPlayer("Tester")
        local seen = nil
        DataController.WhenReady("Tester", function(inst) seen = inst end)
        t.assertNotNil(seen)
        t.assertEquals(dc, seen)
    end)

    t.it("fires later for a fresh shell", function()
        H.reset()
        DataController:new("Pending", true)

        local seen = false
        DataController.WhenReady("Pending", function() seen = true end)
        t.assertFalse(seen)

        DataController.instances["Pending"].tocData = {
            limbs = {},
            prostheses = {},
            isAnyLimbCut = false,
            isIgnoredPartInfected = false,
        }
        DataController.instances["Pending"]:setIsDataReady(true)
        t.assertTrue(seen)
    end)
end)
