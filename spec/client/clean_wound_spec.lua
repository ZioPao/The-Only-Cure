-- Clean-wound bandage consumption. issue #259: in MP the dirty replacement was
-- created client-side only, leaving a ghost item the server never knew about.
local DC = require("TOC/Controllers/DataController")
local CleanWoundAction = require("TOC/TimedActions/CleanWoundAction")

local function count(pl, fullType)
    local items = pl:getInventory():getItems()
    local n = 0
    for i = 0, items:size() - 1 do
        if items:get(i):getFullType() == fullType then
            n = n + 1
        end
    end
    return n
end

describe("TOC clean wound bandage", function()
    it("consumes the bandage and replaces it with a dirty one", function()
        local pl = getPlayer()
        local user = pl:getUsername()

        init_player(pl)
        wait_for(function() return not ISTimedActionQueue.isPlayerDoingAction(pl) end)

        if isClient() then
            -- Seed on the server so the swap has to come back from it.
            server_eval(
                "local players = getOnlinePlayers() local target = nil "
                    .. "for i=1,players:size() do if players:get(i-1):getUsername() == '" .. user
                    .. "' then target = players:get(i-1) end end "
                    .. "if not target then return false end "
                    .. "local inv = target:getInventory() local it = inv:AddItem('Base.AlcoholBandage') "
                    .. "if it then sendAddItemToContainer(inv, it) end return it ~= nil"
            )
            ZBSpec.timeout(30, function()
                wait_for(function() return count(pl, "Base.AlcoholBandage") > 0 end)
            end)
        else
            add_item(pl, "Base.AlcoholBandage")
        end

        local dc = DC.GetInstance(user)
        dc:setCutLimb("Hand_L", false, false, false, 0)
        dc:setIsCicatrized("Hand_L", false)
        dc:setWoundDirtyness("Hand_L", 1)
        ZBSpec.sleep(1)

        local bandage = pl:getInventory():getItemFromType("Base.AlcoholBandage", false, false)
        assert.is_not_nil(bandage, "bandage missing from inventory")
        local part = pl:getBodyDamage():getBodyPart(BodyPartType.Hand_L)

        local action = CleanWoundAction:new(pl, pl, bandage, part)
        ISTimedActionQueue.add(action)
        ZBSpec.timeout(30, function()
            wait_for_not(ISTimedActionQueue.isPlayerDoingAction, pl)
        end)
        ZBSpec.sleep(2)

        -- MP client consumes nothing locally, so a clean swap here means the
        -- server ran complete() and broadcast it.
        assert.eq(0, count(pl, "Base.AlcoholBandage"), "used bandage still in inventory")
        assert.eq(1, count(pl, "Base.BandageDirty"), "dirty bandage not in inventory")
    end)
end)

return ZBSpec.runAsync()
