# In-game integration specs (ZBSpec)

These specs run **inside Project Zomboid** and exercise the parts of TOC that
depend on the real Java engine (body damage, timed actions, relays). The fast
mock-based tests live in `dev_stuff/tests/` instead.

The in-game suite runs **locally**, on Windows or Linux. There is no CI runner
for it.

## Prerequisites

- Ruby 2.7+ (ZBSpec is a Ruby driver).
- The gems `amazing_print` and `sugar_png`.
- **ZombieBuddy built from master (3.0.0-beta1)** — see below.
- A Project Zomboid install for the targeted version.

ZBSpec itself is vendored under `dev_stuff/vendor/ZBSpec` as a git submodule
and patched for Windows/Linux by `dev_stuff/vendor/zbspec-windows.patch`.

## Setup

```bash
# Linux/macOS: patch ZBSpec, install ZombieBuddy, check Ruby + gems
dev_stuff/tests/setup_ingame.sh

# Build + install ZombieBuddy from master (required)
dev_stuff/tests/build_zb_jar.sh "~/.local/share/Steam/steamapps/common/ProjectZomboid"
```

```powershell
# Windows
dev_stuff\tests\setup_ingame.ps1
```

## Running

```bash
dev_stuff/tests/run.sh sp     # singleplayer
dev_stuff/tests/run.sh mp     # multiplayer
```

```powershell
dev_stuff\tests\run.ps1 sp
```

On Linux, run ZBSpec from a TTY (it reads stdin). The unit/lint runners do not
need a TTY.

## Why ZombieBuddy must be built from master

The released **ZombieBuddy v2.3.4** does not work with ZBSpec on Build 42.21:

- ZBSpec's `mod.info` requires ZombieBuddy `>= 2.4.0` (unreleased).
- v2.3.4's `experimental` agent aborts on Linux because it registers the `INFO`
  signal, which does not exist there — so the Lua HTTP API server never starts
  and ZBSpec hangs on "Discovering API port".
- v2.3.4's `LuaHandler` throws a `NullPointerException` under JDK 25.

Master (`3.0.0-beta1`) fixes all of these. `build_zb_jar.sh` clones master,
builds the shadow jar with Gradle, and installs it next to the game.


## Layout

| Path                 | Runs in                                  |
| -------------------- | ---------------------------------------- |
| `spec/shared/`       | client, server and singleplayer          |
| `spec/client/`       | client-only (including singleplayer)     |
| `spec/server/`       | dedicated server only                    |
| `spec/mp/`           | multiplayer relay scenarios              |

## ZBSpec patch

`dev_stuff/vendor/zbspec-windows.patch` adds the non-macOS launch path:
launcher discovery, ZombieBuddy agent injection (`-agentlib:zbNative` on
Windows, `-javaagent` elsewhere), cachedir mod linking (junction/symlink/copy),
Steam workshop paths, and Windows-safe process termination. Re-apply it after
updating the submodule; if it conflicts, rebase it against the new upstream.

## Known limitations (current status)

### Multiplayer
`run.sh mp` launches the dedicated server and client; the server and both Lua
API servers come up, but on this Linux box the client's raknet connection to
the server drops (`GameClient.connection is null`) under `-nosteam`, so MP
specs do not run yet. The MP relay specs are `pending`. Singleplayer is fully
green.

### Synchronous runner
ZBSpec's documented runner is synchronous. TOC's MP relay
(`sendClientCommand` → server → `sendServerCommand` → client) is asynchronous,
so `spec/mp/relay_spec.lua` is currently `pending`.

### AmputationHandler:execute()
The full handler path spawns and equips clothing items whose `getVisual()` is
nil in the headless test instance, so that one spec is `pending`. The cascade
and cache logic it covers are exercised by the data-layer specs and the unit
suite.

