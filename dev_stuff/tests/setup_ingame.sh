# Setup for local in-game ZBSpec tests (Linux/macOS/CI bash hosts).
#
# - initializes the vendored ZBSpec submodule and applies our patch
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

echo "==> Applying Windows/Linux compatibility patch"
if git -C "$VENDOR" apply --check "$ROOT/dev_stuff/vendor/zbspec-windows.patch" 2>/dev/null; then
    git -C "$VENDOR" apply "$ROOT/dev_stuff/vendor/zbspec-windows.patch"
    echo "    applied"
else
    echo "    already applied (or conflicts); skipping"
fi

echo "==> Ensuring game config dir"
VERSION="$(grep -oE 'game_version:[[:space:]]*"?[0-9.]+' "$ROOT/spec/zbspec.yml" | grep -oE '[0-9]+\.[0-9]+' | head -1)"
VERSION="${VERSION:-42.21}"
if [[ ! -d "$VENDOR/configs/$VERSION" ]]; then
    echo "    creating configs/$VERSION from configs/42.13"
    cp -r "$VENDOR/configs/42.13" "$VENDOR/configs/$VERSION"
else
    echo "    configs/$VERSION already exists"
fi

ZB_VERSION="2.3.4"
ZB_SHA256="eb79b9876332010733a8e0d7ce4fe0377846059a9e28859029e2a0fb449f6cf2"

echo "==> Installing ZombieBuddy $ZB_VERSION"
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
if [[ -f "$ZB_JAR" ]] && echo "$ZB_SHA256  $ZB_JAR" | sha256sum -c --status - 2>/dev/null; then
    echo "    ZombieBuddy.jar already present and verified"
else
    tmp_jar="$(mktemp)"
    curl -sSL -o "$tmp_jar" "https://github.com/zed-0xff/ZombieBuddy/releases/download/v${ZB_VERSION}/ZombieBuddy.jar"
    if ! echo "$ZB_SHA256  $tmp_jar" | sha256sum -c --status -; then
        echo "!! ZombieBuddy.jar checksum mismatch; aborting." >&2
        rm -f "$tmp_jar"
        exit 1
    fi
    cp "$tmp_jar" "$ZB_JAR"
    rm -f "$tmp_jar"
    echo "    installed ZombieBuddy.jar (verified)"
fi

# Linux/macOS use -javaagent:ZombieBuddy.jar (the jar itself). The native
# -agentlib:zbNative form (with zbNative.dll) is Windows-only and is handled by
# setup_ingame.ps1.
#
# NOTE: If ZBSpec fails with "Could not discover API port" or ZombieBuddy logs
# an experimental.PreMain InvocationTargetException, build the patched jar:
#   dev_stuff/tests/build_zb_jar.sh "<game folder>"
# (Linux-only SIGINFO guard; see that script's header.)
if [[ ! -f "$ZB_JAR.orig" ]]; then
    echo "    hint: run dev_stuff/tests/build_zb_jar.sh \"$GAME_PATH\" if the API server never starts"
fi

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
