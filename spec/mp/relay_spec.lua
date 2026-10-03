-- Multiplayer relay round-trips.
--
-- The relay is asynchronous: sendClientCommand -> server -> sendServerCommand
-- -> client, and the client DC only updates on a later tick. ZBSpec's
-- documented runner is synchronous, so these specs are tracked as pending
-- until an async/tick hook is available. The equivalent coverage lives in the
-- mocked unit specs (cache + cascade) and in the SP integration specs.
describe("TOC relay (MP)", function()
    pending("amputation relay round-trip updates the client DataController", function() end)
    pending("cache relay round-trip updates the client cache", function() end)
end)

return ZBSpec.run()
