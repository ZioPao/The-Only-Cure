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
end)

-- client_eval/wait_for yield, so this file must run async.
return ZBSpec.runAsync()
