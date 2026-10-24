-- Two-client MP relay spec (runs on client 1; drives client 2 via client_eval).
--
-- Requires `mp_clients: 2` in spec/zbspec.yml (a second client logs in as
-- "zbspec2"). Verifies a surgeon(client1) -> patient(client2) amputation relay
-- end to end: the server applies it and BOTH the server DC and the patient's
-- client DC reflect the cut.

if not isClient() then
    -- MP-only: registers no tests in SP; the runner reports it as skipped.
    return ZBSpec.run()
end

local CommandsData = require("TOC/CommandsData")

local function self()
    return getPlayer():getUsername()
end

---The other connected player (the patient), or nil if only one client.
local function otherPlayer()
    local players = getOnlinePlayers()
    if not players then return nil end
    for i = 1, players:size() do
        local pl = players:get(i - 1)
        if pl and pl:getUsername() ~= self() then return pl end
    end
    return nil
end

local function serverIsCut(user, limb)
    return ZBSpec.server_eval("local DC=require('TOC/Controllers/DataController'); "
        .. "local dc=DC.GetInstance('" .. user .. "'); "
        .. "return dc ~= nil and dc:getIsCut('" .. limb .. "') == true")
end

local function clientIsCut(user, limb)
    return ZBSpec.client_eval(user, "local DC=require('TOC/Controllers/DataController'); "
        .. "local dc=DC.GetInstance(getPlayer():getUsername()); "
        .. "return dc ~= nil and dc:getIsCut('" .. limb .. "') == true")
end

describe("TOC MP relay (two clients)", function()
    it("surgeon amputates the patient: server and patient client both update", function()
        -- The player list can lag behind the spawn; wait for the second client.
        local patient = nil
        ZBSpec.timeout(30, function()
            wait_for(function()
                patient = otherPlayer()
                return patient ~= nil
            end)
        end)
        assert.is_not_nil(patient, "second client required (set mp_clients: 2)")
        local patientName = patient:getUsername()

        -- Surgeon (this client) amputates the patient's hand via the relay.
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayExecuteAmputationAction,
            { patientNum = patient:getOnlineID(), limbName = "Hand_L" })

        -- The relay may be processed a tick after the eval we send, so poll.
        ZBSpec.timeout(30, function()
            wait_for(function() return serverIsCut(patientName, "Hand_L") == true end)
        end)
        assert.is_true(serverIsCut(patientName, "Hand_L"), "server should have cut the patient's Hand_L")

        -- ...and the patient's own client is updated via FinalizeAmputationAction.
        ZBSpec.timeout(30, function()
            wait_for(function() return clientIsCut(patientName, "Hand_L") == true end)
        end)
        assert.is_true(clientIsCut(patientName, "Hand_L"), "patient client should see Hand_L cut")
    end)

    it("patient's stump clothing survives a clothing change (#257)", function()
        local patient = nil
        ZBSpec.timeout(30, function()
            wait_for(function()
                patient = otherPlayer()
                return patient ~= nil
            end)
        end)
        assert.is_not_nil(patient, "second client required (set mp_clients: 2)")
        local patientName = patient:getUsername()
        local STUMP = "TOC.Amputation_ForeArm_L"

        -- Dump the worn full types of the patient on its own client and on the server.
        local function clientWorn()
            return ZBSpec.client_eval(patientName,
                "local p=getPlayer(); local w=p:getWornItems(); local t={}; "
                .. "for i=1,w:size() do local e=w:get(i-1); local it=e and e:getItem(); "
                .. "if it then t[#t+1]=it:getFullType() end end; return table.concat(t,',')")
        end
        local function serverWorn()
            return ZBSpec.server_eval(
                "local players=getOnlinePlayers(); "
                .. "for i=1,players:size() do local p=players:get(i-1); "
                .. "if p and p:getUsername()=='" .. patientName .. "' then "
                .. "local w=p:getWornItems(); local t={}; "
                .. "for j=1,w:size() do local e=w:get(j-1); local it=e and e:getItem(); "
                .. "if it then t[#t+1]=it:getFullType() end end; return table.concat(t,',') end end; return 'NO PLAYER'")
        end
        local function hasStump(s) return s and s:find(STUMP, 1, true) ~= nil end

        -- Amputate the patient's forearm through the relay.
        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayExecuteAmputationAction,
            { patientNum = patient:getOnlineID(), limbName = "ForeArm_L" })

        ZBSpec.timeout(30, function()
            wait_for(function() return serverIsCut(patientName, "ForeArm_L") == true end)
        end)
        assert.is_true(serverIsCut(patientName, "ForeArm_L"), "server should have cut the patient's ForeArm_L")

        -- The stump must actually be worn on the patient's client right after the amputation.
        ZBSpec.timeout(30, function()
            wait_for(function() return hasStump(clientWorn()) end)
        end)
        local cBefore = clientWorn()
        local sBefore = serverWorn()
        assert.is_true(hasStump(cBefore), "client should wear the stump after amputation; worn=" .. tostring(cBefore))
        assert.is_true(hasStump(sBefore), "server should wear the stump after amputation; worn=" .. tostring(sBefore))

        -- Change clothes on the patient (toggle a non-stump worn item), then let
        -- the SyncClothing round-trip complete.
        local changed = ZBSpec.client_eval(patientName,
            "local p=getPlayer(); local w=p:getWornItems(); local target=nil; "
            .. "for i=1,w:size() do local e=w:get(i-1); local it=e and e:getItem(); "
            .. "if it and it:getFullType()~='" .. STUMP .. "' and it:getBodyLocation() then target=it break end end; "
            .. "if target then local loc=target:getBodyLocation(); p:removeWornItem(target); p:setWornItem(loc, target); return true end; "
            .. "return false")
        assert.is_true(changed, "patient should have a non-stump worn item to change")
        ZBSpec.sleep(3)

        -- #257: the stump must survive the clothing sync, on client and server.
        local cAfter = clientWorn()
        local sAfter = serverWorn()
        assert.is_true(hasStump(cAfter), "client lost the stump after a clothing change (#257); worn=" .. tostring(cAfter))
        assert.is_true(hasStump(sAfter), "server lost the stump after a clothing change (#257); worn=" .. tostring(sAfter))
    end)
end)

-- client_eval/wait_for yield, so this file must run async.
return ZBSpec.runAsync()
