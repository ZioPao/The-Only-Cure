-- Issue #282: equipping from the hotbar/belt into an amputated hand.
--
-- The engine calls perform() before complete() in SP (IsoGameCharacter.update),
-- and vanilla complete() re-equips to self.primary. LimitActionsController must
-- therefore re-apply the amputation-aware assignment in complete() too, or a
-- hotbar equip lands in the missing hand.

local t = require("harness.testkit")
local H = require("harness.init")

local Mocks = H.Mocks

-- Globals LimitActionsController.lua touches at load time. Merge instead of
-- replace so we don't clobber fakes installed by other specs (e.g. ISReadABook.new).
local function provide(name, fallback)
    local g = _G[name]
    if type(g) ~= "table" then
        g = {}
        _G[name] = g
    end
    for k, v in pairs(fallback) do
        if g[k] == nil then g[k] = v end
    end
    return g
end

provide("MainOptions", { apply = function() end })
provide("ISWorldObjectContextMenu", { createMenu = function() end })
provide("ISWearClothing", { isValid = function() return true end })
provide("ISClothingExtraAction", { isValid = function() return true end })
provide("ISReadABook", { perform = function() end })
provide("ISInventoryPaneContextMenu", {})

-- Minimal ISEquipWeaponAction: complete() mimics vanilla's hand assignment so the
-- ordering bug is observable.
local EquipClass = { Type = "ISEquipWeaponAction" }
function EquipClass:isValid() return true end
function EquipClass:perform() end
function EquipClass:complete()
    if self.twoHands then
        self.character:setPrimaryHandItem(self.item)
        self.character:setSecondaryHandItem(self.item)
    elseif self.primary then
        self.character:setPrimaryHandItem(self.item)
    else
        self.character:setSecondaryHandItem(self.item)
    end
    return true
end
_G.ISEquipWeaponAction = EquipClass

assert(loadfile("42/media/lua/client/TOC/Controllers/LimitActionsController.lua"))()

---Player with the four hand accessors performWithAmputation() calls.
local function makePlayer(username)
    local pl = Mocks.makePlayer({ username = username })
    local primary, secondary = nil, nil
    function pl:getPrimaryHandItem() return primary end
    function pl:setPrimaryHandItem(item) primary = item end
    function pl:getSecondaryHandItem() return secondary end
    function pl:setSecondaryHandItem(item) secondary = item end
    return pl
end

---Build a one-handed primary equip action, as ISHotbar:equipItem does.
local function makeAction(pl, item)
    local action = { character = pl, item = item, primary = true, twoHands = false }
    setmetatable(action, { __index = _G.ISEquipWeaponAction })
    return action
end

local function makeWeapon()
    return {
        getSwingAnim = function() return nil end,
        isRequiresEquippedBothHands = function() return false end,
    }
end

---Run the engine order for a finished action: perform() then complete().
local function finish(action)
    action:perform()
    action:complete()
end

local function setup(username, cutLimbs)
    local dc = H.initPlayer(username)
    for _, limb in ipairs(cutLimbs or {}) do
        dc:setCutLimb(limb, false, false, false, 0)
    end
    local pl = makePlayer(username)
    Mocks.state.player = pl
    return pl
end

t.describe("ISEquipWeaponAction amputation ordering (#282)", function()
    t.it("right hand cut: hotbar primary equip lands in the left hand", function()
        local pl = setup("AmpR", { "Hand_R" })
        local item = makeWeapon()
        finish(makeAction(pl, item))
        t.assertNil(pl:getPrimaryHandItem(), "must not equip into the amputated right hand")
        t.assertEquals(item, pl:getSecondaryHandItem())
    end)

    t.it("left hand cut: hotbar primary equip still uses the right hand", function()
        local pl = setup("AmpL", { "Hand_L" })
        local item = makeWeapon()
        finish(makeAction(pl, item))
        t.assertEquals(item, pl:getPrimaryHandItem())
        t.assertNil(pl:getSecondaryHandItem())
    end)

    t.it("both hands cut: item is not equipped at all", function()
        local pl = setup("AmpB", { "Hand_L", "Hand_R" })
        local item = makeWeapon()
        finish(makeAction(pl, item))
        t.assertNil(pl:getPrimaryHandItem())
        t.assertNil(pl:getSecondaryHandItem())
    end)

    t.it("no amputation: vanilla behaviour is preserved", function()
        local pl = setup("AmpNone", {})
        local item = makeWeapon()
        finish(makeAction(pl, item))
        t.assertEquals(item, pl:getPrimaryHandItem())
        t.assertNil(pl:getSecondaryHandItem())
    end)
end)
