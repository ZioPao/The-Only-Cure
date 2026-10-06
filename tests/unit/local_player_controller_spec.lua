local t = require("harness.testkit")
require("harness.init")

local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")

local function item(bodyLoc)
    return { getBodyLocation = function() return bodyLoc end }
end

t.describe("LocalPlayerController: CanItemBeEquipped", function()
    t.it("blocks wrist items when the forearm is cut", function()
        t.assertFalse(LocalPlayerController.CanItemBeEquipped(item("LeftWrist"), "ForeArm_L"))
        t.assertFalse(LocalPlayerController.CanItemBeEquipped(item("RightWrist"), "ForeArm_R"))
    end)

    t.it("blocks ring and middle finger items when the hand is cut", function()
        t.assertFalse(LocalPlayerController.CanItemBeEquipped(item("Left_RingFinger"), "Hand_L"))
        t.assertFalse(LocalPlayerController.CanItemBeEquipped(item("Left_MiddleFinger"), "Hand_L"))
    end)

    t.it("allows unrelated body locations", function()
        t.assertTrue(LocalPlayerController.CanItemBeEquipped(item("Hat"), "Hand_L"))
    end)
end)
