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
| `spec/server/`       | dedicated server only (MP relay + shared)|

## ZBSpec patch

`dev_stuff/vendor/zbspec-windows.patch` adds the non-macOS launch path:
launcher discovery, ZombieBuddy agent injection (`-agentlib:zbNative` on
Windows, `-javaagent` elsewhere), cachedir mod linking (junction/symlink/copy),
Steam workshop paths, and Windows-safe process termination. Re-apply it after
updating the submodule; if it conflicts, rebase it against the new upstream.

## Known limitations (current status)

### Multiplayer
`run.sh mp` starts the dedicated server and the connecting client. The client
completes the connection (`isClient()=true`) and the client + server specs run
against the live server. This works on the Linux `-nosteam` setup.

The original blocker was ZBSpec's **singleplayer** debug scenario
(`ZBSpec_client_SP.lua`) auto-launching the local `TestMap` world on the MP
client: it called `forceChangeState(LoadingQueueState.new())` while the server
handshake was in flight, which then cancelled the connect
(`loading-queue-canceled`) and dropped the client back to singleplayer. Two
things are required to avoid it:

- The MP client must not pass `-debug` (`MPHarness#client_config` forces
  `debug=false`). Otherwise PZ's own debug-mode scenario auto-launch fires at
  startup, before the connect begins. (It also avoids PZ's `TestTCP` guard,
  which rejects `-debug` clients whose role lacks `ConnectWithDebug` — though
  the ZBSpec client logs in as `admin`, which has that capability.)
- The SP auto-launch hook is guarded with `not isClient() and not isServer()`
  (in `zbspec-windows.patch`), so it only runs for real singleplayer.

Both changes are in `dev_stuff/vendor/zbspec-windows.patch`.

### Synchronous runner
ZBSpec's documented runner is synchronous. TOC's MP relay
(`sendClientCommand` → server → `sendServerCommand` → client) is asynchronous,
so `spec/mp/relay_spec.lua` remains `pending`. Server-side relay coverage runs
on the dedicated server via `spec/server/relay_spec.lua`.

### AmputationHandler:execute()
The full handler path spawns and equips clothing items whose `getVisual()` is
nil in the headless test instance, so that one spec is `pending`. The cascade
and cache logic it covers are exercised by the data-layer specs and the unit
suite.

