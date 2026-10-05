local t = require("harness.testkit")
require("harness.init")

local CommonMethods = require("TOC/CommonMethods")

t.describe("CommonMethods", function()
    t.it("GetSide returns L for left limbs", function()
        t.assertEquals("L", CommonMethods.GetSide("Hand_L"))
        t.assertEquals("L", CommonMethods.GetSide("ForeArm_L"))
        t.assertEquals("L", CommonMethods.GetSide("UpperArm_L"))
    end)

    t.it("GetSide returns R for right limbs", function()
        t.assertEquals("R", CommonMethods.GetSide("Hand_R"))
        t.assertEquals("R", CommonMethods.GetSide("ForeArm_R"))
        t.assertEquals("R", CommonMethods.GetSide("UpperArm_R"))
    end)

    t.it("GetSideFull maps valid sides", function()
        t.assertEquals("Left", CommonMethods.GetSideFull("L"))
        t.assertEquals("Right", CommonMethods.GetSideFull("R"))
    end)

    t.it("GetSideFull returns nil for invalid side", function()
        t.assertNil(CommonMethods.GetSideFull("X"))
    end)

    t.it("Normalize scales into 0..1", function()
        t.assertEquals(0.5, CommonMethods.Normalize(50, 0, 100))
        t.assertEquals(0, CommonMethods.Normalize(0, 0, 100))
        t.assertEquals(1, CommonMethods.Normalize(100, 0, 100))
    end)

    t.it("Normalize returns 1 on zero range", function()
        t.assertEquals(1, CommonMethods.Normalize(5, 5, 5))
    end)
end)
