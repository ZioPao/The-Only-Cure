# In-game integration specs (ZBSpec)

These specs run **inside Project Zomboid** and exercise the parts of TOC that
depend on the real Java engine (body damage, timed actions, relays). The fast
mock-based tests live in `dev_stuff/tests/` instead.

The in-game suite runs **locally**, on Windows or Linux. There is no CI runner
for it.

## Prerequisites

- Ruby 2.7+ (ZBSpec is a Ruby driver).
- The gems `amazing_print` and `sugar_png`.
- ZombieBuddy installed and active (provides the Lua test API). It is
  compatible with B42.21.
- A Project Zomboid install for the targeted version.

ZBSpec itself is vendored under `dev_stuff/vendor/ZBSpec` as a git submodule
and patched for Windows/Linux by `dev_stuff/vendor/zbspec-windows.patch`.

## Setup

```bash
# Linux/macOS
dev_stuff/tests/setup_ingame.sh
```

```powershell
# Windows
dev_stuff\tests\setup_ingame.ps1
```

The setup script initializes the submodule, applies the patch, creates
`dev_stuff/vendor/ZBSpec/configs/42.21`, and checks Ruby + gems.

## Running

```bash
dev_stuff/tests/run.sh sp     # singleplayer  (zbspec --sp)
dev_stuff/tests/run.sh mp     # multiplayer   (zbspec --mp, starts a server)
```

```powershell
dev_stuff\tests\run.ps1 sp
dev_stuff\tests\run.ps1 mp
```

Configure paths and version in `spec/zbspec.yml` (`game_path`, `game_version`).

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

### ZombieBuddy 2.3.4 vs Build 42.21 / JDK 25
ZBSpec depends on ZombieBuddy's `experimental` Lua HTTP API. With the latest
released ZombieBuddy (**v2.3.4**) this is not fully working on Linux:

1. `experimental.PreMain` aborts because `JavaStateDumper` registers the `INFO`
   signal, which does not exist on Linux. Fixed by `dev_stuff/tests/build_zb_jar.sh`,
   which applies the same guard as ZombieBuddy master and repackages the jar.
2. After that fix the API server starts and ZBSpec reaches *"SP ready"*, but
   then ZombieBuddy's `LuaHandler` throws a `NullPointerException`
   (`LuaReturn.createReturn`), so no spec can execute.

The released ZombieBuddy also advertises `ZBVersionMin=2.4.0`; we lower it to
`2.3.4` in the vendored `mod.info` (in the patch) since 2.4.0 is unreleased.

**Bottom line:** the harness is wired correctly and launches the game, but a
ZombieBuddy bug currently blocks the final spec-execution step. This needs a
ZombieBuddy fix (master / a future release) or a deeper ZombieBuddy patch.

### Synchronous runner
ZBSpec's documented runner is synchronous. TOC's MP relay
(`sendClientCommand` → server → `sendServerCommand` → client) is asynchronous,
so `spec/mp/relay_spec.lua` is currently `pending`.

