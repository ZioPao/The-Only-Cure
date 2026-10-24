-- Issue #285: fluid/fuel handling is one-handed and must not receive the
-- amputation time multiplier. SharedIgnoredActions marks these actions with
-- skipTOC in their `new`.

local t = require("harness.testkit")
local H = require("harness.init")

-- Classes referenced by the override files that the mock harness does not
-- already provide. Each fake `new` records the arguments it received.
local function fakeAction(name)
    local cls = { Type = name }
    cls.new = function(_, ...)
        return { name = name, args = { ... } }
    end
    return cls
end

-- ISEquipWeaponAction is exempted conditionally (needs a live DataController),
-- so it is not part of this unconditional-skipTOC list.
local FUNCTIONAL_CLASSES = {
    "ISAttachItemHotbar",
    "ISTakeWaterAction",
    "ISEatFoodAction",
    "ISReadABook",
    "ISTakePillAction",
    "ISDrinkFromBottle",
}

-- Issue #285 additions (shared-side).
local FLUID_CLASSES = {
    "ISDrinkFluidAction",
    "ISFluidEmptyAction",
    "ISFluidTransferAction",
    "ISAddFluidFromItemAction",
    "ISTakeFuel",
    "ISRefuelFromGasPump",
    "ISTakeGasolineFromVehicle",
    "ISDumpWaterAction",
    "ISTransferWaterAction",
    "ISAddFuelAction",
    "ISInsertLightSourceFuelAction",
    "ISRemoveLightSourceFuelAction",
    "ISLightFromPetrol",
}

local all = { "ISEquipWeaponAction" }
for _, name in ipairs(FUNCTIONAL_CLASSES) do all[#all + 1] = name end
for _, name in ipairs(FLUID_CLASSES) do all[#all + 1] = name end
for _, name in ipairs(all) do _G[name] = fakeAction(name) end

-- Load the real override file exactly as the game does.
assert(loadfile("42/media/lua/shared/TOC/SharedIgnoredActions.lua"))()

t.describe("SharedIgnoredActions: fluid/fuel exemptions (#285)", function()
    t.it("every fluid/fuel action sets skipTOC", function()
        for _, name in ipairs(FLUID_CLASSES) do
            local o = _G[name]:new("char")
            t.assertTrue(o.skipTOC, name .. " should set skipTOC")
        end
    end)

    t.it("keeps the pre-existing functional exemptions", function()
        for _, name in ipairs(FUNCTIONAL_CLASSES) do
            local o = _G[name]:new("char")
            t.assertTrue(o.skipTOC, name .. " should set skipTOC")
        end
    end)

    t.it("forwards all constructor arguments unchanged", function()
        local o = _G.ISDrinkFluidAction:new("char", "item", 0.5)
        t.assertEquals("char", o.args[1])
        t.assertEquals("item", o.args[2])
        t.assertEquals(0.5, o.args[3])
    end)
end)

-- Client-only side (ISFluidPanelAction) lives in ClientIgnoredActions.lua.
for _, name in ipairs({ "ISDetachItemHotbar", "ISCampingInfoAction", "ISFluidPanelAction" }) do
    _G[name] = fakeAction(name)
end

assert(loadfile("42/media/lua/client/TOC/TimedActions/ClientIgnoredActions.lua"))()

t.describe("ClientIgnoredActions: fluid panel exemptions (#285)", function()
    t.it("ISFluidPanelAction sets skipTOC and forwards args", function()
        local o = _G.ISFluidPanelAction:new("char", "container", "panelClass", true)
        t.assertTrue(o.skipTOC)
        t.assertEquals("container", o.args[2])
        t.assertEquals("panelClass", o.args[3])
        t.assertEquals(true, o.args[4])
    end)
end)
