local t = require("harness.testkit")
local H = require("harness.init")

local ItemsController = require("TOC/Controllers/ItemsController")

local Mocks = H.Mocks

---Build a mock player that records worn/held item changes.
local function makePlayer(opts)
    opts = opts or {}
    local p = Mocks.makePlayer(opts)
    p.removedWorn = {}
    p.primary = opts.primary
    p.secondary = opts.secondary
    p.equipSent = 0

    function p:removeWornItem(item) table.insert(self.removedWorn, item) end
    function p:getPrimaryHandItem() return self.primary end
    function p:getSecondaryHandItem() return self.secondary end
    function p:setPrimaryHandItem(item) self.primary = item end
    function p:setSecondaryHandItem(item) self.secondary = item end
    return p
end

local function worn(fullType, bodyLoc)
    return { getItem = function() return { getFullType = function() return fullType end, getBodyLocation = function() return bodyLoc end } end }
end

t.describe("ItemsController: GetAmputationTexturesIndex", function()
    local function playerWithTexture(tex)
        return {
            getHumanVisual = function()
                return { getSkinTexture = function() return tex end }
            end,
        }
    end

    t.it("maps a plain skin texture to index-1", function()
        -- skin01 -> 1, minus 1 => 0 (texture name does not end in 'a' => not hairy)
        t.assertEquals(0, ItemsController.Player.GetAmputationTexturesIndex(playerWithTexture("skin01_b"), false))
    end)

    t.it("offsets hairy textures by +5", function()
        -- skin01_hairy... ends in 'a' => hairy: 1 + 5 = 6, minus 1 => 5
        t.assertEquals(5, ItemsController.Player.GetAmputationTexturesIndex(playerWithTexture("skin01_hairy_a"), false))
    end)

    t.it("offsets cicatrized plain textures by +10", function()
        -- skin01 -> 1 + 10 = 11, minus 1 => 10
        t.assertEquals(10, ItemsController.Player.GetAmputationTexturesIndex(playerWithTexture("skin01_b"), true))
    end)

    t.it("offsets cicatrized hairy textures by +5 (total)", function()
        -- skin01_hairy -> 1 + 5 + 5 = 11, minus 1 => 10
        t.assertEquals(10, ItemsController.Player.GetAmputationTexturesIndex(playerWithTexture("skin01_hairy_a"), true))
    end)
end)

t.describe("ItemsController: DropItemsAfterAmputation", function()
    t.it("removes ring/middle-finger items when a hand is cut", function()
        local pl = makePlayer({ wornItems = {
            worn("Base.Ring", "Left_RingFinger"),
            worn("Base.Glove", "Left_MiddleFinger"),
            worn("Base.Hat", "Hat"),
        } })
        ItemsController.Player.DropItemsAfterAmputation(pl, "Hand_L")
        t.assertEquals(2, #pl.removedWorn)
    end)

    t.it("removes wrist items when a forearm is cut", function()
        local pl = makePlayer({ wornItems = { worn("Base.Watch", "LeftWrist") } })
        ItemsController.Player.DropItemsAfterAmputation(pl, "ForeArm_L")
        t.assertEquals(1, #pl.removedWorn)
    end)

    t.it("does not touch the other side", function()
        local pl = makePlayer({ wornItems = { worn("Base.Ring", "Right_RingFinger") } })
        ItemsController.Player.DropItemsAfterAmputation(pl, "Hand_L")
        t.assertEquals(0, #pl.removedWorn)
    end)

    t.it("clears the right-hand primary and secondary slots (two-handed)", function()
        local item = {}
        local pl = makePlayer({ primary = item, secondary = item })
        ItemsController.Player.DropItemsAfterAmputation(pl, "Hand_R")
        t.assertNil(pl.primary)
        t.assertNil(pl.secondary)
    end)

    t.it("clears only the secondary slot for a left cut with a one-handed item", function()
        local pl = makePlayer({ primary = {}, secondary = {} })
        ItemsController.Player.DropItemsAfterAmputation(pl, "Hand_L")
        t.assertNotNil(pl.primary)
        t.assertNil(pl.secondary)
    end)
end)
