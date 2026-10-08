#!/usr/bin/env bash
#
# The Only Cure — test entry point.
#
#   ./tests/run.sh lint    # syntax + unresolved-require checks (no game)
#   ./tests/run.sh unit    # mocked pure-Lua unit tests (no game)
#   ./tests/run.sh sp      # in-game singleplayer specs (ZBSpec)
#   ./tests/run.sh mp      # in-game multiplayer specs (ZBSpec)
#   ./tests/run.sh all     # lint + unit + sp
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

LUA_BIN="${LUA_BIN:-}"
if [[ -z "$LUA_BIN" ]]; then
    for candidate in luajit lua5.1 lua; do
        if command -v "$candidate" >/dev/null 2>&1; then LUA_BIN="$candidate"; break; fi
    done
fi

require_lua() {
    if [[ -z "$LUA_BIN" ]]; then
        echo "error: no Lua interpreter found (need luajit or lua5.1)" >&2
        exit 1
    fi
}

run_lint() {
    require_lua
    echo "==> lint (syntax + requires)"
    find 42/media/lua common/media/lua -name '*.lua' -print \
        | "$LUA_BIN" "$SCRIPT_DIR/lint.lua"

    # Optional deeper static analysis via selene (undefined globals, unused vars).
    local selene="${SELENE_BIN:-}"
    if [[ -z "$selene" ]] && command -v selene >/dev/null 2>&1; then
        selene="selene"
    fi
    if [[ -n "$selene" ]]; then
        echo "==> selene (static analysis)"
        "$selene" --allow-warnings --config "$SCRIPT_DIR/selene.toml" \
            $(find 42/media/lua common/media/lua -name '*.lua')
    else
        echo "    (selene not found; skipping deeper static analysis)"
    fi
}

run_unit() {
    require_lua
    echo "==> unit tests (mock harness)"
    "$LUA_BIN" "$SCRIPT_DIR/run_unit.lua"
}

run_zbspec() {
    local mode="$1"
    local vendor="$ROOT/tests/vendor/ZBSpec"

    if [[ ! -d "$vendor/lib" ]]; then
        echo "error: vendored ZBSpec not found. Run tests/setup_ingame.sh first." >&2
        exit 1
    fi
    if ! command -v ruby >/dev/null 2>&1; then
        echo "error: ruby not found (need Ruby 2.7+ for ZBSpec)." >&2
        exit 1
    fi

    # Run the vendored copy directly; it only needs stdlib + amazing_print + sugar_png.
    # -v lists every executed spec (name + pass/fail); without it ZBSpec only prints
    # per-section counts, which hides which specs actually ran.
    exec ruby -I"$vendor/lib" "$vendor/bin/zbspec" \
        --mod-dir "$ROOT" --config "$ROOT/tests/spec/zbspec.yml" -v "$mode"
}

case "${1:-all}" in
    lint) run_lint ;;
    unit) run_unit ;;
    sp)   run_zbspec --sp ;;
    mp)   run_zbspec --mp ;;
    all)
        run_lint
        run_unit
        run_zbspec --sp
        ;;
    *)
        echo "usage: $0 [lint|unit|sp|mp|all]" >&2
        exit 2
        ;;
esac
