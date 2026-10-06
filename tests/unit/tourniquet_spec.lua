local t = require("harness.testkit")
local H = require("harness.init")

local TourniquetController = require("TOC/Controllers/TourniquetController")

local Mocks = H.Mocks

t.describe("TourniquetController: item detection", function()
    t.it("recognises left and right tourniquets", function()
        t.assertTrue(TourniquetController.IsItemTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_L"))
        t.assertTrue(TourniquetController.IsItemTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_R"))
    end)

    t.it("rejects unrelated items", function()
        t.assertFalse(TourniquetController.IsItemTourniquet("Base.BandageDirty"))
        t.assertFalse(TourniquetController.IsItemTourniquet("Base.Saw"))
    end)

    t.it("returns false when no items are worn", function()
        local pl = Mocks.makePlayer({ wornItems = {} })
        t.assertFalse(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_L"))
    end)

    t.it("accepts a matching side for all left limbs", function()
        local pl = Mocks.makePlayer({
            wornItems = { Mocks.wornItem("The_Only_Cure.Surg_Arm_Tourniquet_L", "TOC_ArmAccessory") },
        })
        t.assertTrue(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_L"))
        t.assertTrue(TourniquetController.CheckTourniquetOnLimb(pl, "ForeArm_L"))
        t.assertTrue(TourniquetController.CheckTourniquetOnLimb(pl, "UpperArm_L"))
    end)

    t.it("rejects a mismatched side", function()
        local pl = Mocks.makePlayer({
            wornItems = { Mocks.wornItem("The_Only_Cure.Surg_Arm_Tourniquet_R", "TOC_ArmAccessory") },
        })
        t.assertFalse(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_L"))
    end)

    t.it("accepts the right side for right limbs", function()
        local pl = Mocks.makePlayer({
            wornItems = { Mocks.wornItem("The_Only_Cure.Surg_Arm_Tourniquet_R", "TOC_ArmAccessory") },
        })
        t.assertTrue(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_R"))
        t.assertTrue(TourniquetController.CheckTourniquetOnLimb(pl, "UpperArm_R"))
    end)

    t.it("rejects a non-tourniquet worn item", function()
        local pl = Mocks.makePlayer({
            wornItems = { Mocks.wornItem("Base.BandageDirty", "TOC_ArmAccessory") },
        })
        t.assertFalse(TourniquetController.CheckTourniquetOnLimb(pl, "Hand_L"))
    end)
end)
