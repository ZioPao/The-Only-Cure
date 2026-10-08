-- Shared harness bootstrap. Sets the TOC require paths and exposes helpers that
-- reset global state between specs.
--
-- Must be required after package.path contains `tests/?.lua`
-- (run_unit.lua does this), and it must be run with the repo root as cwd.

local LUA_ROOTS = {
    "42/media/lua/shared/",
    "42/media/lua/client/",
    "42/media/lua/server/",
    "common/media/lua/shared/",
    "common/media/lua/client/",
    "common/media/lua/server/",
}

local paths = {}
for _, root in ipairs(LUA_ROOTS) do
    table.insert(paths, root .. "?.lua")
    table.insert(paths, root .. "?/init.lua")
end
package.path = table.concat(paths, ";") .. ";" .. package.path

local Mocks = require("harness.mocks")

local H = { Mocks = Mocks }

---Clear global mutable state so specs do not leak into each other.
function H.reset()
    Mocks.state.modData = {}
    Mocks.state.clientCommands = {}
    Mocks.state.serverCommands = {}

    local DataController = require("TOC/Controllers/DataController")
    DataController.instances = {}
    DataController._readyCallbacks = {}

    local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
    CachedDataHandler.amputatedLimbs = {}
    CachedDataHandler.highestAmputatedLimbs = {}
    CachedDataHandler.handFeasibility = {}
end

---Reset state and initialize a clean DataController for `username`.
---@param username string?
---@return table DataController instance
function H.initPlayer(username)
    username = username or "Tester"
    H.reset()

    local ServerDataController = require("TOC/Controllers/ServerDataController")
    local dc = ServerDataController.Initialize(username, true)

    local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
    CachedDataHandler.Setup(username)

    return dc
end

return H
