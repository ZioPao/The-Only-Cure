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

# The game install path is machine-dependent, so it lives in
# .vscode/settings.json (`zbspec_game_path`) instead of being hardcoded in
# tests/spec/zbspec.yml. Prints the value, or nothing when the setting is absent.
read_vscode_setting() {
    local key="$1" settings="$ROOT/.vscode/settings.json"
    [[ -f "$settings" ]] || return 0
    # VSCode settings are JSONC; drop // line comments before matching.
    sed -E 's@^[[:space:]]*//.*$@@' "$settings" \
        | grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
        | head -n1 \
        | sed -E "s@^\"$key\"[[:space:]]*:[[:space:]]*\"@@; s@\"\$@@" || true
}

# Materialize the config ZBSpec should use: the committed zbspec.yml with a
# `game_path` appended from the VSCode setting. Falls back to zbspec.yml
# unchanged (ZBSpec then auto-detects) when no setting is found. Prints the path.
materialize_zbspec_config() {
    local base="$ROOT/tests/spec/zbspec.yml"
    local game_path
    game_path="$(read_vscode_setting zbspec_game_path)"
    if [[ -z "$game_path" ]]; then
        echo "    (no zbspec_game_path in .vscode/settings.json; ZBSpec will auto-detect the game)" >&2
        printf '%s' "$base"
        return
    fi
    # Undo JSON backslash escaping and use forward slashes so the YAML scalar
    # needs no escaping; double single quotes for YAML.
    game_path="$(printf '%s' "$game_path" | sed -e 's/\\\\/\//g' -e 's/\\/\//g')"
    game_path="${game_path//\'/\'\'}"
    local out="$ROOT/tests/.zbspec.local.yml"
    { cat "$base"; printf "\ngame_path: '%s'\n" "$game_path"; } > "$out"
    printf '%s' "$out"
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

    local config
    config="$(materialize_zbspec_config)"

    # Run the vendored copy directly; it only needs stdlib + amazing_print + sugar_png.
    # -v lists every executed spec (name + pass/fail); without it ZBSpec only prints
    # per-section counts, which hides which specs actually ran.
    exec ruby -I"$vendor/lib" "$vendor/bin/zbspec" \
        --mod-dir "$ROOT" --config "$config" -v "$mode"
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
