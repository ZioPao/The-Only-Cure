-- Issue #285: fluid/fuel handling is one-handed and must not receive the
-- amputation time multiplier. SharedIgnoredActions marks these actions with
-- skipTOC in their `new`.
--
-- Issue #292: B42 sends timed actions to the server as NetTimedAction and
-- rebuilds them from the *declared parameter names* of the action's `new`
-- (NetTimedAction.set/parse read the constructor prototype's locvars). A
-- wrapper declared as `new(...)` has no named params, so every argument was
-- serialised as nil and the server crashed rebuilding the action. These tests
-- pin the wrapper signatures to the vanilla ones and emulate the round trip.

local t = require("harness.testkit")
require("harness.init")

-- Vanilla PZ 42.21 constructor signatures. These names are the wire contract:
-- they must match the fields the vanilla `new` stores on the action.
local SIGNATURES = {
    -- Pre-existing exemptions
    ISAttachItemHotbar = { "character", "item", "slot", "slotIndex", "slotDef" },
    ISEquipWeaponAction = { "character", "item", "maxTimeInit", "primary", "twoHands", "alwaysTurnOn" },
    ISTakeWaterAction = { "character", "item", "waterObject", "waterTaintedCL" },
    ISEatFoodAction = { "character", "item", "percentage" },
    ISReadABook = { "character", "item" },
    ISTakePillAction = { "character", "item" },
    ISDrinkFromBottle = { "character", "item", "uses" },
    -- Issue #285 additions (shared side)
    ISDrinkFluidAction = { "character", "item", "percentage" },
    ISFluidEmptyAction = { "character", "containerObject" },
    ISFluidTransferAction = { "character", "sourceContainer", "sourceFluidObject", "targetContainer", "targetFluidObject", "amount" },
    ISAddFluidFromItemAction = { "character", "itemFrom", "objectTo" },
    ISTakeFuel = { "character", "fuelStation", "petrolCan" },
    ISRefuelFromGasPump = { "character", "part", "fuelStation" },
    ISTakeGasolineFromVehicle = { "character", "part", "item", "otherItems" },
    ISDumpWaterAction = { "character", "item" },
    ISTransferWaterAction = { "character", "itemFrom", "itemTo", "itemFromEndingDelta", "itemToEndingDelta" },
    ISAddFuelAction = { "character", "campfire", "item", "fuelAmt" },
    ISInsertLightSourceFuelAction = { "character", "lightSource", "fuel" },
    ISRemoveLightSourceFuelAction = { "character", "lightSource" },
    ISLightFromPetrol = { "character", "campfire", "lighter", "petrol", "maxTimeInit" },
}

-- Client-only file
local CLIENT_SIGNATURES = {
    ISDetachItemHotbar = { "character", "item" },
    ISCampingInfoAction = { "character", "campfireObject", "campfire" },
    ISFluidPanelAction = { "character", "_container", "_panelClass", "isSource" },
}

-- ISEquipWeaponAction needs a live DataController, so it is only signature-checked.
local FUNCTIONAL_CLASSES = {
    "ISAttachItemHotbar",
    "ISTakeWaterAction",
    "ISEatFoodAction",
    "ISReadABook",
    "ISTakePillAction",
    "ISDrinkFromBottle",
}

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

---Parameter names a Lua constructor declares, in order (as NetTimedAction reads
---them). Index 1 is the implicit `self`, which the engine skips.
local function paramsOf(fn)
    local names = {}
    local info = debug.getinfo(fn, "u")
    for i = 2, info.nparams do
        names[#names + 1] = debug.getlocal(fn, i)
    end
    return names
end

local function fakeAction(name, params)
    local cls = { Type = name }
    cls.new = function(_, ...)
        local o = { name = name }
        local args = { ... }
        for i, paramName in ipairs(params) do
            o[paramName] = args[i]
        end
        return o
    end
    return cls
end

for name, params in pairs(SIGNATURES) do
    _G[name] = fakeAction(name, params)
end
for name, params in pairs(CLIENT_SIGNATURES) do
    _G[name] = fakeAction(name, params)
end

-- Load the real override files exactly as the game does.
assert(loadfile("42/media/lua/shared/TOC/SharedIgnoredActions.lua"))()
assert(loadfile("42/media/lua/client/TOC/TimedActions/ClientIgnoredActions.lua"))()

-- Other specs overwrite some of these globals later; keep the wrapped versions.
local Classes = {}
for name in pairs(SIGNATURES) do Classes[name] = _G[name] end
for name in pairs(CLIENT_SIGNATURES) do Classes[name] = _G[name] end

local function assertSignatureMismatch(className, expected, actual)
    t.assertEquals(#expected, #actual, className .. " parameter count")
    for i, name in ipairs(expected) do
        t.assertEquals(name, actual[i], className .. " parameter " .. i)
    end
end

---Emulates NetTimedAction.set (client) + NetTimedAction.parse (server).
---Returns the server-rebuilt action.
local function netRoundTrip(className, expected)
    local cls = Classes[className]
    local values = {}
    for i = 1, #expected do
        values[i] = "value" .. i
    end

    -- client-side construction, like the UI code does
    local clientAction = cls.new(cls, unpack(values))

    -- NetTimedAction.set: build the arg table from the constructor's param names
    local names = paramsOf(cls.new)
    local wire = {}
    for i, paramName in ipairs(names) do
        wire[i] = clientAction[paramName]
    end

    -- NetTimedAction.parse: server rebuilds from those values
    local serverAction = cls.new(cls, unpack(wire))
    return names, values, serverAction
end

t.describe("SharedIgnoredActions: constructor signatures (#292)", function()
    t.it("fluid/fuel wrappers keep vanilla parameter names", function()
        for name, expected in pairs(SIGNATURES) do
            if name ~= "ISEquipWeaponAction" then
                assertSignatureMismatch(name, expected, paramsOf(Classes[name].new))
            end
        end
    end)

    t.it("ISEquipWeaponAction keeps vanilla parameter names", function()
        assertSignatureMismatch("ISEquipWeaponAction", SIGNATURES.ISEquipWeaponAction,
            paramsOf(Classes.ISEquipWeaponAction.new))
    end)

    t.it("server-side rebuild preserves every constructor argument", function()
        for _, name in ipairs(FLUID_CLASSES) do
            local expected = SIGNATURES[name]
            local names, values, serverAction = netRoundTrip(name, expected)

            t.assertEquals(#expected, #names, name .. " wire arg count")
            for i, paramName in ipairs(names) do
                t.assertEquals(values[i], serverAction[paramName],
                    name .. " lost argument '" .. paramName .. "' in the net round trip")
            end
        end
    end)
end)

t.describe("SharedIgnoredActions: fluid/fuel exemptions (#285)", function()
    t.it("every fluid/fuel action sets skipTOC", function()
        for _, name in ipairs(FLUID_CLASSES) do
            local params = SIGNATURES[name]
            local values = {}
            for i = 1, #params do values[i] = "value" .. i end

            local o = Classes[name].new(Classes[name], unpack(values))
            t.assertTrue(o.skipTOC, name .. " should set skipTOC")
        end
    end)

    t.it("keeps the pre-existing functional exemptions", function()
        for _, name in ipairs(FUNCTIONAL_CLASSES) do
            local params = SIGNATURES[name]
            local values = {}
            for i = 1, #params do values[i] = "value" .. i end

            local o = Classes[name].new(Classes[name], unpack(values))
            t.assertTrue(o.skipTOC, name .. " should set skipTOC")
        end
    end)

    t.it("forwards all constructor arguments unchanged", function()
        local o = Classes.ISDrinkFluidAction:new("char", "item", 0.5)
        t.assertEquals("char", o.character)
        t.assertEquals("item", o.item)
        t.assertEquals(0.5, o.percentage)
    end)
end)

t.describe("ClientIgnoredActions: fluid panel exemptions (#285/#292)", function()
    t.it("ISFluidPanelAction keeps vanilla parameter names", function()
        assertSignatureMismatch("ISFluidPanelAction", CLIENT_SIGNATURES.ISFluidPanelAction,
            paramsOf(Classes.ISFluidPanelAction.new))
    end)

    t.it("ISFluidPanelAction sets skipTOC and forwards args", function()
        local o = Classes.ISFluidPanelAction:new("char", "container", "panelClass", true)
        t.assertTrue(o.skipTOC)
        t.assertEquals("container", o._container)
        t.assertEquals("panelClass", o._panelClass)
        t.assertEquals(true, o.isSource)
    end)
end)
