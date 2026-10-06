local t = require("harness.testkit")
local H = require("harness.init")

local ProsthesisHandler = require("TOC/Handlers/ProsthesisHandler")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local DataController = require("TOC/Controllers/DataController")

local Mocks = H.Mocks

local function prostItem(fullType, bodyLoc)
    return {
        getFullType = function() return fullType end,
        getBodyLocation = function()
            return { toString = function() return bodyLoc end }
        end,
    }
end

t.describe("ProsthesisHandler: CheckIfProst", function()
    t.it("returns false for nil item", function()
        t.assertFalse(ProsthesisHandler.CheckIfProst(nil))
    end)

    t.it("returns false when the item has no body location", function()
        t.assertFalse(ProsthesisHandler.CheckIfProst({
            getBodyLocation = function() return nil end,
        }))
    end)

    t.it("recognises arm prostheses", function()
        t.assertTrue(ProsthesisHandler.CheckIfProst(prostItem("TOC.Prost_NormalArm_L", "toc:armprost_l")))
        t.assertTrue(ProsthesisHandler.CheckIfProst(prostItem("TOC.Prost_HookArm_R", "toc:armprost_r")))
    end)

    t.it("rejects non-prosthesis body locations", function()
        t.assertFalse(ProsthesisHandler.CheckIfProst(prostItem("Base.Hat", "Hat")))
    end)
end)

t.describe("ProsthesisHandler: GetGroup", function()
    t.it("maps a left prosthesis to Top_L", function()
        t.assertEquals("Top_L", ProsthesisHandler.GetGroup(prostItem("TOC.Prost_NormalArm_L", "toc:armprost_l")))
    end)

    t.it("maps a right prosthesis to Top_R", function()
        t.assertEquals("Top_R", ProsthesisHandler.GetGroup(prostItem("TOC.Prost_NormalArm_R", "toc:armprost_r")))
    end)
end)

t.describe("ProsthesisHandler: CheckIfEquippable", function()
    local function playerWith(username)
        local pl = Mocks.makePlayer({ username = username })
        Mocks.state.player = pl
        return pl
    end

    t.it("is not equippable with no amputations", function()
        H.initPlayer("Prost")
        playerWith("Prost")
        t.assertFalse(ProsthesisHandler.CheckIfEquippable("TOC.Prost_NormalArm_L"))
    end)

    t.it("is equippable when the hand is cut on that side", function()
        local dc = H.initPlayer("Prost")
        dc:setCutLimb("Hand_L", false, false, false, 0)
        playerWith("Prost")
        CachedDataHandler.CalculateHighestAmputatedLimbs("Prost")
        t.assertTrue(ProsthesisHandler.CheckIfEquippable("TOC.Prost_NormalArm_L"))
    end)

    t.it("is not equippable when the upper arm is cut", function()
        local dc = H.initPlayer("Prost")
        dc:setCutLimb("UpperArm_L", false, false, false, 0)
        playerWith("Prost")
        CachedDataHandler.CalculateHighestAmputatedLimbs("Prost")
        t.assertFalse(ProsthesisHandler.CheckIfEquippable("TOC.Prost_NormalArm_L"))
    end)

    t.it("does not leak across sides", function()
        local dc = H.initPlayer("Prost")
        dc:setCutLimb("Hand_R", false, false, false, 0)
        playerWith("Prost")
        CachedDataHandler.CalculateHighestAmputatedLimbs("Prost")
        t.assertFalse(ProsthesisHandler.CheckIfEquippable("TOC.Prost_NormalArm_L"))
        t.assertTrue(ProsthesisHandler.CheckIfEquippable("TOC.Prost_NormalArm_R"))
    end)
end)

t.describe("ProsthesisHandler: SearchAndSetupProsthesis", function()
    t.it("returns false for a non-prosthesis item", function()
        local pl = Mocks.makePlayer({ username = "Prost" })
        H.initPlayer("Prost")
        t.assertFalse(ProsthesisHandler.SearchAndSetupProsthesis(pl, prostItem("Base.Hat", "Hat"), true))
    end)

    t.it("sets the prosthesis flag on the DataController", function()
        local dc = H.initPlayer("Prost")
        local pl = Mocks.makePlayer({ username = "Prost" })
        Mocks.state.player = pl

        t.assertTrue(ProsthesisHandler.SearchAndSetupProsthesis(pl, prostItem("TOC.Prost_NormalArm_L", "toc:armprost_l"), true))
        t.assertTrue(dc:getIsProstEquipped("Hand_L"))

        t.assertTrue(ProsthesisHandler.SearchAndSetupProsthesis(pl, prostItem("TOC.Prost_NormalArm_L", "toc:armprost_l"), false))
        t.assertFalse(dc:getIsProstEquipped("Hand_L"))
    end)
end)
