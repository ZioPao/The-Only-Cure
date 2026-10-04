# Setup for local in-game ZBSpec tests (Linux/macOS/CI bash hosts).
#
# - initializes the vendored ZBSpec submodule (fork: ZioPao/ZBSpec)
# - creates the game config dir for the configured version
# - verifies Ruby + the gems ZBSpec needs
#
# Windows users: use setup_ingame.ps1 instead.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VENDOR="$ROOT/dev_stuff/vendor/ZBSpec"

echo "==> Initializing ZBSpec submodule"
git -C "$ROOT" submodule update --init --recursive dev_stuff/vendor/ZBSpec

echo "==> Ensuring game config dir"
VERSION="$(grep -oE 'game_version:[[:space:]]*"?[0-9.]+' "$ROOT/spec/zbspec.yml" | grep -oE '[0-9]+\.[0-9]+' | head -1)"
VERSION="${VERSION:-42.21}"
if [[ ! -d "$VENDOR/configs/$VERSION" ]]; then
    echo "    creating configs/$VERSION from configs/42.13"
    cp -r "$VENDOR/configs/42.13" "$VENDOR/configs/$VERSION"
else
    echo "    configs/$VERSION already exists"
fi

echo "==> Ensuring ZombieBuddy >= 3.0.0"
GAME_PATH="$(grep -E '^[[:space:]]*game_path:' "$ROOT/spec/zbspec.yml" | head -1 | sed -E 's/^[[:space:]]*game_path:[[:space:]]*//; s/^"//; s/"[[:space:]]*$//; s/[[:space:]]*#.*$//')"
GAME_PATH="${GAME_PATH/#\~/$HOME}"
if [[ -z "$GAME_PATH" ]]; then
    for candidate in \
        "$HOME/.steam/steam/steamapps/common/ProjectZomboid/projectzomboid" \
        "$HOME/.local/share/Steam/steamapps/common/ProjectZomboid/projectzomboid"; do
        [[ -d "$candidate" ]] && GAME_PATH="$candidate" && break
    done
fi

if [[ -z "$GAME_PATH" || ! -d "$GAME_PATH" ]]; then
    echo "!! Could not locate the Project Zomboid install. Set game_path in spec/zbspec.yml." >&2
    exit 1
fi
echo "    game folder: $GAME_PATH"

ZB_JAR="$GAME_PATH/ZombieBuddy.jar"
if [[ -f "$ZB_JAR" ]] && unzip -p "$ZB_JAR" META-INF/MANIFEST.MF 2>/dev/null | grep -q 'Implementation-Version: 3\.'; then
    echo "    ZombieBuddy.jar present (>= 3.x)"
else
    echo "    ZombieBuddy.jar missing or older than 3.0.0; building from master"
    "$SCRIPT_DIR/build_zb_jar.sh" "$GAME_PATH"
fi

# Linux/macOS use -javaagent:ZombieBuddy.jar (the jar itself). The native
# -agentlib:zbNative form (with zbNative.dll) is Windows-only and is handled by
# setup_ingame.ps1. The fork's ZBSpec requires ZombieBuddy >= 3.0.0, whose
# Linux fixes are only in master (see build_zb_jar.sh).

echo "==> Checking Ruby"
if ! command -v ruby >/dev/null 2>&1; then
    echo "!! Ruby not found. Install Ruby 2.7+ then re-run." >&2
    exit 1
fi
ruby --version

echo "==> Checking gems (amazing_print, sugar_png)"
if command -v gem >/dev/null 2>&1; then
    gem list -i amazing_print >/dev/null 2>&1 || gem install amazing_print || echo "!! failed to install amazing_print"
    gem list -i sugar_png >/dev/null 2>&1 || gem install sugar_png || echo "!! failed to install sugar_png"
fi

echo
echo "Setup complete."
echo "Then run: dev_stuff/tests/run.sh sp"
