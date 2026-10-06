# Testing The Only Cure

Everything about the automated test suite: how it is layered, how to set it up,
how to add tests, how to run them, and how to keep the ZBSpec fork in sync.

The suite is intentionally split by **how much of the game a test needs**, so
most logic is covered by fast tests that never launch Project Zomboid.

---

## 1. The four layers

| Layer  | What it covers | Needs game? | Entry point | Speed |
| ------ | -------------- | ----------- | ----------- | ----- |
| `lint` | Syntax + unresolved `require("TOC/...")`, plus [selene] static analysis | No | `dev_stuff/tests/lint.lua` | instant |
| `unit` | Pure Lua logic against a mocked PZ engine | No | `dev_stuff/tests/run_unit.lua` + `dev_stuff/tests/harness/` | fast (<1s) |
| `sp`   | Real Java engine in singleplayer (modData, `BodyPartType`, events, timed actions) | Yes | ZBSpec, `spec/**` | ~1–2 min |
| `mp`   | Dedicated server + a connecting client | Yes | ZBSpec, `spec/{server,shared}` + MP client specs | ~2 min |

Rule of thumb: **write the lowest layer that can express the behaviour.** Pure
logic → `unit`; anything that touches real engine objects, events, `IsoPlayer`,
`BodyPartType`, or the client↔server relay → in-game (`spec/`).

---

## 2. Repository layout

```
dev_stuff/tests/
├── run.sh / run.ps1        # single entry point: lint | unit | sp | mp | all
├── lint.lua                # syntax + unresolved-require checks (zero deps)
├── run_unit.lua            # unit entry point: requires every unit spec, then runs
├── harness/
│   ├── testkit.lua         # tiny describe/it runner + assertions
│   ├── init.lua            # TOC require paths + state reset helpers
│   └── mocks.lua           # fake PZ engine (Events, ModData, BodyPartType, ...)
├── spec/                   # mocked UNIT specs (must be registered in run_unit.lua)
├── setup_ingame.sh/.ps1    # one-time in-game setup (submodule, ZombieBuddy, Ruby)
└── build_zb_jar.sh/.ps1    # build ZombieBuddy from master (required for in-game)

spec/                       # in-game ZBSpec specs, discovered by convention
├── client/                 # client + SP only
├── server/                 # dedicated server only
├── shared/                 # server AND client AND SP
├── zbspec.yml              # ZBSpec config (game_path, game_version, mods, helpers)
└── README.md               # shorter, ZBSpec-focused notes
```

`dev_stuff/vendor/ZBSpec/` is a git **submodule** pointing at the project fork
(`ZioPao/ZBSpec`) — see §10.

---

## 3. One-time setup

### Lint + unit (no game)

Install a Lua interpreter: `luajit` (preferred) or `lua5.1` / `lua5.3` / `lua5.4`.
Optional, for deeper static analysis: [selene] on `PATH` or `SELENE_BIN` set.

```bash
./dev_stuff/tests/run.sh lint
./dev_stuff/tests/run.sh unit
```

### In-game (ZBSpec)

Prerequisites:

- **Ruby 2.7+** with the gems `amazing_print` and `sugar_png`.
- **ZombieBuddy built from master (3.0.0-beta1)** installed next to the game.
  The released v2.3.4 does not work on Linux/B42.21 (SIGINFO abort, JDK-25
  NPE, and it is below ZBSpec's minimum version).
- A Project Zomboid install for the targeted version (`42.21`), with
  `game_path` set in `spec/zbspec.yml`.

```bash
# Linux / macOS — inits the ZBSpec submodule, creates configs/42.21, checks
# Ruby + gems, and ensures ZombieBuddy >= 3.x (builds it if missing)
dev_stuff/tests/setup_ingame.sh

# Build + install ZombieBuddy from master (required)
dev_stuff/tests/build_zb_jar.sh "~/.local/share/Steam/steamapps/common/ProjectZomboid"
```

```powershell
# Windows
dev_stuff\tests\setup_ingame.ps1
```

**On Linux, `sp` and `mp` must be run from a TTY** — ZBSpec reads stdin.

---

## 4. Running

```bash
./dev_stuff/tests/run.sh lint    # syntax + requires (+ selene if present), no game
./dev_stuff/tests/run.sh unit    # mocked logic, no game
./dev_stuff/tests/run.sh sp      # in-game singleplayer
./dev_stuff/tests/run.sh mp      # in-game multiplayer (dedicated server + client)
./dev_stuff/tests/run.sh all     # lint + unit + sp
```

```powershell
dev_stuff\tests\run.ps1 lint|unit|sp|mp|all
```

Environment overrides:

- `LUA_BIN` — Lua interpreter for `lint`/`unit`.
- `SELENE_BIN` — selene binary for `lint`.

Every runner exits non-zero on failure, so they are CI-friendly.

### Where the in-game output goes

Each launched instance gets a cache dir under `tmp/`:

```
tmp/cache_sp_42.21/        # singleplayer
tmp/cache_server_42.21/    # dedicated server
tmp/cache_client_42.21/    # MP client
├── std.log
└── Logs/
    ├── *_DebugLog.txt
    └── *_connections.txt   # RakNet + connect-state log; gold for MP debugging
```

The ZBSpec harness asserts the instance is really a server/client
(`isServer()` / `isClient()`) and waits for the player before running specs, so
`isClient()=false` failures surface immediately.

### Running a single in-game spec

```bash
ruby -I dev_stuff/vendor/ZBSpec/lib dev_stuff/vendor/ZBSpec/bin/zbspec \
  --mod-dir . spec/shared/static_data_spec.lua
```

The spec's folder must match the mode you want (see §6).

---

## 5. Writing a **unit** spec (no game)

1. Create `dev_stuff/tests/spec/<area>_spec.lua`.
2. Require the harness (order matters) and the module under test:

   ```lua
   local t = require("harness.testkit")   -- describe/it + assertions
   local H = require("harness.init")      -- TOC require paths + state reset
   local TourniquetController = require("TOC/Controllers/TourniquetController")
   local Mocks = H.Mocks
   ```

3. Write suites with `t.describe` / `t.it`:

   ```lua
   t.describe("TourniquetController: item detection", function()
       t.it("recognises left and right tourniquets", function()
           t.assertTrue(TourniquetController.IsItemTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_L"))
           t.assertTrue(TourniquetController.IsItemTourniquet("The_Only_Cure.Surg_Arm_Tourniquet_R"))
       end)

       t.it("rejects unrelated items", function()
           t.assertFalse(TourniquetController.IsItemTourniquet("Base.Saw"))
       end)
   end)
   ```

4. **Register the file** in `dev_stuff/tests/run_unit.lua` — unit specs are not
   glob-discovered:

   ```lua
   require("spec.tourniquet_spec")
   ```

### `testkit` assertions

`t.assertTrue(v)`, `t.assertFalse(v)`, `t.assertEquals(expected, actual)`,
`t.assertNil(v)`, `t.assertNotNil(v)`, `t.assertTable/Number/String/Boolean(v)`,
`t.fail(msg)`, `t.pending(name)`.

### Harness helpers

From `harness/init.lua`:

- `H.initPlayer("Tester")` — clears global state, creates a ready
  `DataController` for that username, and sets up `CachedDataHandler`. Returns
  the `DataController`.
- `H.reset()` — clears `ModData`, recorded commands, and the controller/cache
  state. Call it between tests that mutate global state.

From `harness/mocks.lua` (`H.Mocks`):

- `Mocks.makePlayer{ username=, onlineID=, wornItems= }` — mock `IsoPlayer`.
- `Mocks.wornItem(fullType, bodyLoc)` — mock a worn item.
- `Mocks.state.player` — the current mock player (`getPlayer()` returns it).
- `Mocks.state.clientCommands` / `.serverCommands` — recorded
  `sendClientCommand` / `sendServerCommand` calls, for asserting the mod sent
  the right thing.
- `Mocks.state.modData` — the `ModData` backing store.

The mock installs `Events`, `ModData`, `BodyPartType`, timed-action classes,
`getPlayer`, `sendClientCommand`, string helpers, sandbox vars, etc. If a
module reaches for an engine global that is not mocked yet, add it in
`harness/mocks.lua` (and to `zomboid.yml` for selene).

Canonical example: `dev_stuff/tests/spec/tourniquet_spec.lua`.

---

## 6. Writing an **in-game** (ZBSpec) spec

### Folder = execution context

| Folder | Runs on |
| ------ | ------- |
| `spec/shared/` | dedicated server **and** MP client **and** SP |
| `spec/server/` | dedicated server (and SP) |
| `spec/client/` | SP (and MP client, unless gated) |
| `spec/*_spec.lua` (root) | treated as `shared` |

`run.sh sp` runs all three folders on one SP instance. `run.sh mp` runs
`server` + `shared` on the dedicated server and `client` + `shared` on the MP
client. With no flag, ZBSpec auto-detects:

- server + client specs present → `both` (SP first, then MP)
- only server specs → `server`
- otherwise → `sp`

### Required shape

The file must end with a `run` call, otherwise the runner warns and may count
the whole file as a single pass:

```lua
local StaticData = require("TOC/StaticData")

describe("TOC StaticData (in-game)", function()
    it("defines six limbs", function()
        assert.eq(6, #StaticData.LIMBS_STR)
    end)

    it("wires every limb to a real BodyPartType", function()
        for _, limb in ipairs(StaticData.LIMBS_STR) do
            assert.is_not_nil(BodyPartType[limb])
        end
    end)
end)

return ZBSpec.run()
```

For tests that need to wait on the async client↔server relay, end with:

```lua
return ZBSpec.runAsync()
```

### Context gating

Put a guard at the top so the file is a no-op in the wrong context. This is how
`spec/client/amputation_spec.lua` avoids running on the MP client (it relies on
SP-synchronous `ClientDataController.Request`):

```lua
-- server-only spec: do nothing on an MP client
if isClient() then return ZBSpec.run() end
```

The inverse (`if not isClient() then return ZBSpec.run() end`) makes a spec run
only on a real MP client.

### Assertions

`assert(cond)`, `assert.eq(expected, actual)`, `assert.same(a, b)`,
`assert.is_true/is_false/is_nil/is_not_nil`, `assert.is_string/is_number/is_table/is_function/is_boolean`,
`assert.gt(actual, min)`, `assert.lt(actual, max)`, `assert.matches(pattern, str)`,
`assert.contains(needle, haystack)`, `assert.has_key(key, tbl)`, `assert.throws(fn, msg)`.

### Hooks and control

`before_each(fn)`, `before_all(fn)`, `after_each(fn)`, `after_all(fn)`,
`pending("name", fn)`, `skip("reason")`.

### Async

Inside a `ZBSpec.runAsync()` file you can yield on the game loop:

- `wait_for(condition, ...)`, `wait_for_not(...)`, `wait_for_this(obj, method, ...)`
- `sleep(seconds)`, `timeout(seconds, fn)`

### Calling the server from the client

- `server_exec(code)` — fire-and-forget on the server.
- `server_eval(code)` — returns a value from the server (requires async).
- `all_exec(code)` — run everywhere.

Helpers listed under `helpers:` in `spec/zbspec.yml` (currently
`common_helpers`) are preloaded before each spec file.

Canonical examples:

- `spec/shared/static_data_spec.lua` — shared.
- `spec/server/relay_spec.lua` — server, with a `stubPlayer` and a
  "requires a real connected client" guard.
- `spec/client/amputation_spec.lua` — SP, with a `pending` visual-path test.

---

## 7. CI vs local

`.github/workflows/ci.yml` runs **only `lint` + `unit`** on GitHub-hosted
Ubuntu (it installs LuaJIT and selene). In-game `sp` / `mp` are **local only**
because they need the game, ZombieBuddy, and a TTY. CI triggers on pushes to
`dev`, `main`, `test/**`, and on PRs into `dev`/`main`.

---

## 8. Gotchas

- **Every in-game spec must end with `return ZBSpec.run()` (or
  `ZBSpec.runAsync()`).** A spec that returns early still reports as a pass
  (0 tests), so a silently-skipped spec looks green.
- **Unit specs must be registered in `run_unit.lua`.**
- **Reset shared state** (`H.reset()` / the spec's own `reset()`) between tests;
  `DataController.instances` and `CachedDataHandler` caches persist otherwise.
- **The MP client launches without `-debug`** (the harness forces
  `debug=false`), and PZ's SP TestMap scenario auto-launches only in SP. Do not
  write specs that assume debug mode or a locally-started world on the MP
  client.
- **Headless/visual limits:** `item:getVisual()` is nil in the test instance, so
  `AmputationHandler:execute()` is `pending`; keep in-game specs on the data
  layer.
- **Async relay specs are `pending`** (`sendClientCommand → server →
  sendServerCommand → client`). Server-side handlers are covered directly on
  the dedicated server in `spec/server/relay_spec.lua`.
- **selene runs with `--allow-warnings`** (only errors fail the build). New PZ
  globals belong in `zomboid.yml`.
- **Fixed spawn/world:** TOC's in-game tests run on `TestMap` at `128,128,0`
  (the SP debug scenario and `servertest.ini`).

---

## 9. Quick reference

```
add pure logic test    -> dev_stuff/tests/spec/<x>_spec.lua + require in run_unit.lua ; run.sh unit
add shared/engine test -> spec/shared/<x>_spec.lua ; end with return ZBSpec.run() ; run.sh sp / run.sh mp
add server-only test   -> spec/server/<x>_spec.lua ; guard `if isClient() then return ZBSpec.run() end` ; run.sh mp
add client/SP-only     -> spec/client/<x>_spec.lua ; gate on context ; run.sh sp
lint / static analysis -> run.sh lint
everything fast        -> run.sh all     (lint + unit + sp)
```

---

## 10. The ZBSpec fork (git)

The in-game suite runs a vendored ZBSpec whose Windows/Linux launch support and
MP fixes live in a **fork**, not a patch file.

- Submodule: `dev_stuff/vendor/ZBSpec`.
- Fork: `https://github.com/ZioPao/ZBSpec.git` (local clone: `~/Repos/ZBSpec`),
  branch `master`.
- `.gitmodules` points at the fork. There is **no patch file** and the setup
  scripts do not apply one.

What the fork adds (relative to upstream):

- Non-macOS launch path: direct bundled-JVM invocation, correct cwd/env,
  ZombieBuddy agent injection (`-agentlib:zbNative` on Windows, `-javaagent`
  elsewhere), cachedir mod linking (junction/symlink/copy), platform Steam
  workshop paths, and safe process termination.
- Dedicated server launched with the `zombie.network.GameServer` main class and
  `-nosteam`.
- MP port sequencing (server starts first; the client dials the server's
  persisted port).
- **MP client runs with `debug=false`** to avoid PZ's debug-scenario
  auto-launch and the `ConnectToServerState.TestTCP` debug guard.
- **SP debug-scenario auto-launch is gated** with `not isClient() and not
  isServer()` so it never fires on an MP client.
- A `42/media/java -> common/media/java` symlink so B42 finds the Java patch jar.

### Updating the submodule

```bash
# after pulling superproject changes
git submodule update --init --recursive dev_stuff/vendor/ZBSpec
```

To move the fork forward: make/commit the change in `~/Repos/ZBSpec`, push it,
then in the superproject check out the new commit and commit the updated
gitlink + `.gitmodules`. Do **not** reintroduce a patch file.

---

## 11. Troubleshooting

- **"Could not discover API port" / `experimental.PreMain` exception** —
  ZombieBuddy is missing or too old. Run
  `dev_stuff/tests/build_zb_jar.sh "<game folder>"`. ZBSpec requires `>= 3.0.0`.
- **ZBSpec hangs on startup** — on Linux you are probably not on a TTY; rerun
  from a terminal.
- **MP client falls back to singleplayer (`isClient()=false`)** — inspect
  `tmp/cache_client_42.21/Logs/*_connections.txt`. A `loading-queue-canceled`
  after `connect-state start` means something forced the SP scenario during the
  connect; the fix (MP `debug=false` + SP hook gate) lives in the fork — make
  sure the submodule is at the fork commit, not upstream.
- **`configs/42.21` not found warning** — `setup_ingame.sh` creates it by
  copying `configs/42.13`; a missing dir is harmless (it falls back to
  `configs/default`) but run setup if you want the exact version config.
- **selene not found** — it is optional; install it or set `SELENE_BIN`.

[selene]: https://github.com/Kampfkarren/selene
