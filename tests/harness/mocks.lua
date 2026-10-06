-- Project Zomboid engine mocks for running TOC's Lua modules outside the game.
--
-- Installing this module defines the globals the mod expects (Events, ModData,
-- BodyPartType, luautils, isServer/isClient, ...). It intentionally stays dumb:
-- mocks return the queried key for enum tables and record calls for inspection.
--
-- `require("harness.mocks").install()` is idempotent.

local Mocks = {}

local installed = false

-- Mutable state exposed to specs.
Mocks.state = {
    player = nil,
    clientCommands = {},
    serverCommands = {},
    modData = {},
    rand = 0,
}

local function noop() end

--* Events *--
local function installEvents()
    local function newEvent()
        local ev = { handlers = {} }
        function ev.Add(fn) table.insert(ev.handlers, fn) end
        function ev.Remove(fn)
            for i = #ev.handlers, 1, -1 do
                if ev.handlers[i] == fn then table.remove(ev.handlers, i) end
            end
        end
        function ev.Clear() ev.handlers = {} end
        return ev
    end

    local Events = setmetatable({}, {
        __index = function(t, name)
            local ev = newEvent()
            rawset(t, name, ev)
            return ev
        end,
    })
    _G.Events = Events

    _G.LuaEventManager = { AddEvent = noop }

    _G.triggerEvent = function(name, ...)
        local ev = rawget(Events, name)
        if not ev then return end
        for _, fn in ipairs(ev.handlers) do
            fn(...)
        end
    end
end

--* Persistence *--
local function installModData()
    _G.ModData = {
        get = function(key) return Mocks.state.modData[key] end,
        add = function(key, value) Mocks.state.modData[key] = value end,
        remove = function(key) Mocks.state.modData[key] = nil end,
        transmit = noop,
    }
end

--* Engine flags / commands *--
--* Timed-action classes (vanilla ISBaseTimedAction et al.) *--
-- These exist so engine-coupled modules can be required and their pure helpers
-- tested. Each is a table with the methods the modules call or override.
local function timedActionClass(extra)
    local cls = { Type = extra and extra.Type or nil }
    cls.update = function() end
    cls.perform = function() end
    cls.stop = function() end
    cls.isValid = function() return true end
    cls.complete = function() return true end
    return cls
end

local function installTimedActions()
    _G.ISBaseTimedAction = timedActionClass()
    for _, name in ipairs({
        "ISWearClothing", "ISClothingExtraAction", "ISUnequipAction",
        "ISReloadWeaponAction", "ISInsertMagazine", "ISLoadBulletsInMagazine",
        "ISUnloadBulletsFromFirearm", "ISUnloadBulletsFromMagazine", "ISRackFirearm",
        "ISUpgradeWeapon", "ISRemoveWeaponUpgrade", "ISBarricadeAction",
        "ISUnbarricadeAction", "ISChopTreeAction", "ISDismantleAction",
        "ISDestroyStuffAction", "ISCraftAction", "ISApplyBandage", "ISCleanBandage",
        "ISDisinfect", "ISRemoveBullet", "ISSplint", "ISStitch", "ISCleanBurn",
        "ISRemovePatch", "ISPickUpGroundCoverItem", "ISPickAxeGroundCoverItem",
    }) do
        _G[name] = timedActionClass({ Type = name })
    end
end

local function installEngine()
    _G.isDebugEnabled = function() return false end
    _G.isClient = function() return false end
    _G.isServer = function() return false end

    _G.getActivatedMods = function()
        return { contains = function() return false end }
    end

    _G.getGameVersion = function() return "42.20" end

    _G.sendClientCommand = function(module, command, args)
        table.insert(Mocks.state.clientCommands, { module = module, command = command, args = args })
    end
    _G.sendServerCommand = function(_, module, command, args)
        table.insert(Mocks.state.serverCommands, { module = module, command = command, args = args })
    end

    _G.getPlayer = function() return Mocks.state.player end
    _G.getPlayerByOnlineID = function() return Mocks.state.player end
    _G.getOnlinePlayers = function()
        local p = Mocks.state.player
        if not p then return { size = function() return 0 end } end
        return {
            size = function() return 1 end,
            get = function(_, i) if i == 0 then return p end return nil end,
        }
    end

    _G.getCore = function()
        return { getKey = function() return 0 end, addKeyBinding = noop }
    end
    _G.Keyboard = { KEY_NONE = 0 }

    _G.instanceof = function() return true end
    _G.syncBodyPart = noop
    _G.SyncXp = noop
    _G.getTexture = function(path) return { path = path } end
    _G.addXp = noop
    _G.getText = function(key) return key end
    _G.sendRemoveItemFromContainer = noop
    _G.sendAddItemToContainer = noop
    _G.sendEquip = noop
    _G.instanceItem = function(name)
        return {
            getFullType = function() return name end,
            getBodyLocation = function() return nil end,
        }
    end

    _G.ZombRand = function(a) return a or Mocks.state.rand end
    _G.ZombRandFloat = function(a) return a or Mocks.state.rand end

    installTimedActions()
end

--* Enum-like tables: any key resolves to itself *--
local function selfKeyTable(extra)
    local t = extra or {}
    return setmetatable(t, {
        __index = function(_, k) return k end,
    })
end

local function installEnums()
    _G.BodyPartType = selfKeyTable({
        ToString = function(v) return v end,
    })
    _G.BloodBodyPartType = selfKeyTable()
    _G.Perks = selfKeyTable()
    _G.CharacterStat = selfKeyTable()
    _G.ItemBodyLocation = selfKeyTable({
        register = function(id) return id end,
    })
    _G.CharacterTrait = { register = function(id) return id end }
end

--* Sandbox *--
local function installSandbox()
    _G.SandboxVars = {
        TOC = {
            SurgeonAbilityImportance = 0.1,
            WoundDirtynessMultiplier = 1,
            CicatrizationSpeed = 1,
        },
    }
end

--* Debug *--
local function installDebug()
    _G.TOC_DEBUG = {
        print = noop,
        printTable = noop,
        getRunningFile = function() return "" end,
    }
    _G.getCurrentCoroutine = function() return nil end
    _G.getCoroutineObjStack = function() return nil end
    _G.KahluaUtil = { rawTostring2 = tostring }
end

--* String helpers (PZ extensions) *--
local function installStrings()
    _G.string.contains = function(s, needle) return string.find(s, needle, 1, true) ~= nil end
    _G.luautils = {
        stringStarts = function(s, prefix) return string.sub(s, 1, #prefix) == prefix end,
        stringEnds = function(s, suffix)
            return suffix == "" or string.sub(s, -#suffix) == suffix
        end,
    }
end

--* TOC registries (normally created by 42/media/registries.lua) *--
local function installRegistries()
    if rawget(_G, "_TOCRegistries") == nil then
        _G._TOCRegistries = {
            traits = {
                Amputee_Hand = "toc:amputee_hand",
                Amputee_ForeArm = "toc:amputee_forearm",
                Amputee_UpperArm = "toc:amputee_upperarm",
            },
            bodylocations = {},
        }
    end
end

function Mocks.install()
    if installed then return Mocks end
    installed = true

    installEvents()
    installModData()
    installEngine()
    installEnums()
    installSandbox()
    installDebug()
    installStrings()
    installRegistries()

    return Mocks
end

--* Player factory *--

---Build a mock IsoPlayer good enough for the modules exercised by unit specs.
---@param opts table?
function Mocks.makePlayer(opts)
    opts = opts or {}
    local wornItems = opts.wornItems or {}
    local player = {
        username = opts.username or "Tester",
        onlineID = opts.onlineID or 0,
        perkLevels = opts.perkLevels or {},
        bodyDamage = opts.bodyDamage,
    }
    function player:getUsername() return self.username end
    function player:getOnlineID() return self.onlineID end
    function player:getPerkLevel(perk) return (self.perkLevels[perk] or 0) end
    function player:getBodyDamage() return self.bodyDamage end
    function player:getWornItems()
        return {
            size = function() return #wornItems end,
            get = function(_, i) return wornItems[i + 1] end,
        }
    end
    function player:getWornItem(loc)
        for _, w in ipairs(wornItems) do
            if w.bodyLoc == loc then return w end
        end
        return nil
    end
    return player
end

function Mocks.wornItem(fullType, bodyLoc)
    return {
        bodyLoc = bodyLoc,
        getItem = function() return { getFullType = function() return fullType end } end,
    }
end

--* Body damage factories *--

---Build a mock BodyPart. Only the wound state LocalPlayerController.HealArea /
---SanitizePlayer touch is modelled; every mutator is a no-op setter.
---@param opts table? { bitten : boolean?, infected : boolean? }
function Mocks.makeBodyPart(opts)
    opts = opts or {}
    local bp = {
        _bitten = opts.bitten or false,
        _infected = opts.infected or false,
    }
    function bp:bitten() return self._bitten end
    function bp:IsInfected() return self._infected end
    function bp:SetBitten(v) self._bitten = v end
    function bp:SetInfected(v) self._infected = v end
    function bp:setInfected(v) self._infected = v end
    function bp:setBiteTime(_) end
    function bp:setInfectionTime(_) end
    function bp:setFractureTime(_) end
    function bp:setSplint(_, _) end
    function bp:setSplintItem(_) end
    function bp:setScratched(_, _) end
    function bp:setScratchTime(_) end
    function bp:setBleeding(_) end
    function bp:setBleedingTime(_) end
    function bp:setCut(_) end
    function bp:setCutTime(_) end
    function bp:setDeepWounded(_) end
    function bp:setDeepWoundTime(_) end
    function bp:setHaveBullet(_, _) end
    function bp:setHaveGlass(_) end
    return bp
end

---Build a mock BodyDamage from a { [bodyPartKey] = BodyPart } map.
---@param parts table<string, table>
function Mocks.makeBodyDamage(parts)
    local bd = { parts = parts or {} }
    function bd:getBodyPart(bpt) return self.parts[bpt] end
    return bd
end

Mocks.install()

return Mocks
