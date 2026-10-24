-- Issue #292: fluid timed actions must survive the client -> server net path.
--
-- B42 sends timed actions as NetTimedAction and rebuilds them on the server from
-- the declared parameter names of the action's `new` (NetTimedAction.set/parse
-- read the constructor prototype). A wrapper written as `new(...)` has no named
-- params, so every argument went on the wire as nil, the server-side action was
-- never created and drink/transfer/refuel broke in MP.
--
-- The probe records what the server actually passed to the constructor while
-- rebuilding the action. Do NOT assert on fluid amounts: the client consumes and
-- syncs the bottle itself, so that passes even when the server action is missing.
if not isClient() then
    -- MP-only: registers no tests in SP; the runner reports it as skipped.
    return ZBSpec.run()
end

-- Wraps the server-side constructor and records the arguments it receives.
local INSTALL_PROBE = [[
_G.TOC_FLUID_CALLS = {}
local og_new = ISDrinkFluidAction.new
ISDrinkFluidAction.new = function(self, character, item, percentage)
    _G.TOC_FLUID_CALLS[#_G.TOC_FLUID_CALLS + 1] = {
        hasCharacter = character ~= nil,
        hasItem = item ~= nil,
        percentage = percentage,
    }
    return og_new(self, character, item, percentage)
end
return true
]]

---Last constructor call the server made: { count, hasCharacter, hasItem, percentage }.
local function lastServerCall()
    return ZBSpec.server_eval([[
        local calls = _G.TOC_FLUID_CALLS or {}
        local last = calls[#calls]
        return {
            count = #calls,
            hasCharacter = last and last.hasCharacter or false,
            hasItem = last and last.hasItem or false,
            percentage = last and last.percentage or -1,
        }
    ]])
end

local function findItem(pl, fullType)
    local items = pl:getInventory():getItems()
    for i = 0, items:size() - 1 do
        if items:get(i):getFullType() == fullType then return items:get(i) end
    end
    return nil
end

describe("TOC MP fluid actions (#292)", function()
    it("server rebuilds ISDrinkFluidAction with the client's arguments", function()
        local pl = getPlayer()
        local user = pl:getUsername()

        -- No init_player(): its all_exec broadcast clears the other client's
        -- inventory (and worn clothing), which breaks the #257 spec below.
        wait_for(function() return not ISTimedActionQueue.isPlayerDoingAction(pl) end)

        assert.is_true(ZBSpec.server_eval(INSTALL_PROBE), "could not install the server probe")

        -- Seed the bottle on the server so both sides know the item exists.
        local seeded = ZBSpec.server_eval(
            "local players = getOnlinePlayers() local target = nil "
                .. "for i=1,players:size() do if players:get(i-1):getUsername() == '" .. user
                .. "' then target = players:get(i-1) end end "
                .. "if not target then return false end "
                .. "local inv = target:getInventory() local it = inv:AddItem('Base.WaterBottle') "
                .. "if it then sendAddItemToContainer(inv, it) end return it ~= nil"
        )
        assert.is_true(seeded, "could not seed Base.WaterBottle on the server")

        local item = nil
        ZBSpec.timeout(30, function()
            wait_for(function()
                item = findItem(getPlayer(), "Base.WaterBottle")
                return item ~= nil
            end)
        end)
        assert.is_not_nil(item, "water bottle did not replicate to the client")

        ISTimedActionQueue.add(ISDrinkFluidAction:new(getPlayer(), item, 0.5))

        local calls = nil
        ZBSpec.timeout(30, function()
            wait_for(function()
                calls = lastServerCall()
                return calls.count >= 1
            end)
        end)

        print(string.format("[ZBSpec #292] server constructor calls=%d hasCharacter=%s hasItem=%s",
            calls.count, tostring(calls.hasCharacter), tostring(calls.hasItem)))

        assert.is_true(calls.count >= 1, "server never rebuilt the action (#292)")
        assert.is_true(calls.hasItem, "server rebuilt the action with nil args (#292)")
        assert.is_true(calls.hasCharacter, "server rebuilt the action without a character (#292)")
        assert.is_true(calls.percentage == 0.5, "server lost the percentage argument (#292)")

        -- Let the drink finish so it cannot leak into the next spec.
        ZBSpec.timeout(30, function()
            wait_for(function() return not ISTimedActionQueue.isPlayerDoingAction(pl) end)
        end)
    end)
end)

-- server_eval/wait_for yield, so this file must run async.
return ZBSpec.runAsync()
