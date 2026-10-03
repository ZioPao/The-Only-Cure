# TOC test suite

Automated tests for **The Only Cure**, split by how much of the game they need.

```
dev_stuff/tests/
├── run.sh                 # single entry point: lint | unit | sp | mp | all
├── lint.lua               # syntax + unresolved-require checks (no game)
├── run_unit.lua           # unit-test entry point (no game)
├── harness/
│   ├── init.lua           # TOC require paths + state reset helpers
│   ├── mocks.lua          # fake PZ engine (Events, ModData, BodyPartType, ...)
│   └── testkit.lua        # tiny describe/it runner
├── spec/                  # mocked unit specs
└── legacy/Tests.lua       # old in-game TEST_FRAMEWORK suite (reference only)
```

In-game specs live in `../../spec/` and run through [ZBSpec](../spec/README.md).

## Running

```bash
./dev_stuff/tests/run.sh lint   # fast, no game, catches syntax/broken requires
./dev_stuff/tests/run.sh unit   # fast, no game, mocked logic
./dev_stuff/tests/run.sh sp     # in-game singleplayer (needs Ruby + the game)
./dev_stuff/tests/run.sh mp     # in-game multiplayer (needs Ruby + the game)
./dev_stuff/tests/run.sh all    # lint + unit + sp
```

```powershell
dev_stuff\tests\run.ps1 lint|unit|sp|mp|all
```

The `lint` and `unit` runners need `luajit` or `lua5.1` only. Override with
`LUA_BIN=...`. The `sp`/`mp` runners use the vendored ZBSpec; run
`dev_stuff/tests/setup_ingame.sh` (or `setup_ingame.ps1`) once first.

On Linux, also run `dev_stuff/tests/build_zb_jar.sh "<game folder>"` to build
ZombieBuddy from master (required for the in-game suite; see `spec/README.md`).

## Adding a unit spec

1. Create `spec/<area>_spec.lua`.
2. Require `harness.testkit` and `harness.init` (in that order).
3. Write `t.describe` / `t.it` blocks using `t.assert*`.
4. Register the file in `run_unit.lua`.

```lua
local t = require("harness.testkit")
local H = require("harness.init")
local CommonMethods = require("TOC/CommonMethods")

t.describe("CommonMethods", function()
    t.it("returns L for left limbs", function()
        t.assertEquals("L", CommonMethods.GetSide("Hand_L"))
    end)
end)
```

Use `H.initPlayer("Tester")` to get a clean `DataController`, and
`H.Mocks.makePlayer{...}` / `H.Mocks.wornItem(...)` to build engine objects.

## Scope

- `lint` + `unit` run in hosted CI on every push/PR (no game, no runner).
- `sp` / `mp` run in-game, locally, on Windows or Linux.
- `mp` is currently `pending` in ZBSpec (async relay); see `spec/README.md`.
