local t = require("harness.testkit")
local H = require("harness.init")

local CommandsData = require("TOC/CommandsData")
local StaticData = require("TOC/StaticData")
local Registries = require("TOC/Registries")

t.describe("CommandsData", function()
    t.it("exposes the three modules", function()
        t.assertString(CommandsData.modules.TOC_DEBUG)
        t.assertString(CommandsData.modules.TOC_RELAY)
        t.assertString(CommandsData.modules.TOC_ITEMS)
    end)

    t.it("client relay commands are all non-empty strings", function()
        for name, value in pairs(CommandsData.client.Relay) do
            t.assertString(value)
            t.assertNotNil(name)
        end
    end)

    t.it("server relay commands are all non-empty strings", function()
        for name, value in pairs(CommandsData.server.Relay) do
            t.assertString(value)
            t.assertNotNil(name)
        end
    end)

    t.it("relay command names are unique between client and server", function()
        local seen = {}
        for _, v in pairs(CommandsData.client.Relay) do seen[v] = true end
        for _, v in pairs(CommandsData.server.Relay) do
            if seen[v] then
                t.fail("relay command name collides between client and server: " .. tostring(v))
            end
        end
    end)

    t.it("GetKey prefixes with the mod name", function()
        t.assertEquals("TOC_Bob", CommandsData.GetKey("Bob"))
    end)

    t.it("GetUsername strips the mod name prefix", function()
        t.assertEquals("Bob", CommandsData.GetUsername("TOC_Bob"))
    end)

    t.it("GetKey/GetUsername round-trip", function()
        local name = "SomePlayer123"
        t.assertEquals(name, CommandsData.GetUsername(CommandsData.GetKey(name)))
    end)

    t.it("GetZombieKey is stable and distinct", function()
        t.assertString(CommandsData.GetZombieKey())
        t.assertFalse(CommandsData.GetZombieKey() == CommandsData.GetKey("Bob"))
    end)
end)

t.describe("Registries", function()
    t.it("exposes the traits registry", function()
        t.assertTable(Registries.traits)
        t.assertNotNil(Registries.traits.Amputee_Hand)
        t.assertNotNil(Registries.traits.Amputee_ForeArm)
        t.assertNotNil(Registries.traits.Amputee_UpperArm)
    end)

    t.it("exposes a bodylocations registry", function()
        t.assertTable(Registries.bodylocations)
    end)

    t.it("Traits_BP keys exist in the traits registry", function()
        for k, _ in pairs(StaticData.TRAITS_BP) do
            t.assertNotNil(Registries.traits[k])
        end
    end)
end)
