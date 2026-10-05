#!/usr/bin/env bash
#
# Builds ZombieBuddy from master (3.0.0-beta1) for the ZBSpec test harness,
# and installs it into the Project Zomboid folder.
#
# Why not the released v2.3.4 jar?
#   - ZBSpec requires ZombieBuddy >= 2.4.0 (mod.info), which is unreleased.
#   - v2.3.4's `experimental` agent aborts on Linux (it registers the INFO
#     signal, which does not exist there), so the Lua HTTP API server never
#     starts and ZBSpec hangs on "Discovering API port".
#   - v2.3.4's LuaHandler also throws a NullPointerException under JDK 25.
#   ZombieBuddy master (3.0.0-beta1) fixes all of the above.
#
# Requires network (GitHub + Gradle) on first run.
#
# Usage: dev_stuff/tests/build_zb_jar.sh "<game folder>"

set -euo pipefail

ZB_REPO="https://github.com/zed-0xff/ZombieBuddy.git"
GRADLE_VERSION="9.3.1"
JDK_VERSION="25.30.17-ca-jdk25.0.1"
GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
JDK_URL="https://cdn.azul.com/zulu/bin/zulu${JDK_VERSION}-linux_x64.tar.gz"

GAME_PATH="${1:-}"
if [[ -z "$GAME_PATH" ]]; then
    echo "usage: $0 <game-install-dir>" >&2
    echo "  e.g. ~/.local/share/Steam/steamapps/common/ProjectZomboid" >&2
    exit 2
fi
GAME_PATH="${GAME_PATH/#\~/$HOME}"
if [[ ! -d "$GAME_PATH" ]]; then
    echo "error: game folder not found: $GAME_PATH" >&2
    exit 1
fi

WORK="${WORK:-/tmp/opencode/zbbuild}"
mkdir -p "$WORK"
cd "$WORK"

# --- JDK ---
JDK_HOME="${JDK_HOME:-}"
if [[ -z "$JDK_HOME" ]]; then
    for candidate in "$WORK"/zulu25*/ /usr/lib/jvm/java-25-openjdk*; do
        [[ -x "$candidate/bin/javac" ]] && JDK_HOME="$candidate" && break
    done
fi
if [[ -z "$JDK_HOME" ]]; then
    echo "==> Downloading Zulu JDK 25"
    curl -sSL -o zulu25.tar.gz "$JDK_URL"
    tar xzf zulu25.tar.gz
    JDK_HOME="$WORK/$(ls -d zulu25*/ | head -1)"
fi
export JAVA_HOME="$JDK_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
echo "==> JDK: $("$JAVA_HOME/bin/javac" -version 2>&1)"

# --- Gradle ---
if [[ ! -d "$WORK/gradle-${GRADLE_VERSION}" ]]; then
    echo "==> Downloading Gradle ${GRADLE_VERSION}"
    curl -sSL -o gradle.zip "$GRADLE_URL"
    unzip -q -o gradle.zip
fi
GRADLE="$WORK/gradle-${GRADLE_VERSION}/bin/gradle"

# --- ZombieBuddy source ---
if [[ ! -d "$WORK/ZombieBuddy" ]]; then
    echo "==> Cloning ZombieBuddy master"
    git clone --depth 1 "$ZB_REPO" "$WORK/ZombieBuddy"
fi

# Resolve the game jar for the compile classpath.
GAME_JAR="$GAME_PATH/projectzomboid/projectzomboid.jar"
[[ -f "$GAME_JAR" ]] || GAME_JAR="$GAME_PATH/projectzomboid.jar"
if [[ ! -f "$GAME_JAR" ]]; then
    echo "error: projectzomboid.jar not found under $GAME_PATH" >&2
    exit 1
fi

echo "==> Building ZombieBuddy shadowJar"
cd "$WORK/ZombieBuddy/java"
"$GRADLE" shadowJar -PgameClasspath="$GAME_JAR" --no-daemon --console=plain

BUILT=$(find "$WORK/ZombieBuddy/java" -name 'ZombieBuddy.jar' -path '*libs*' | head -1)
if [[ -z "$BUILT" ]]; then
    echo "error: build produced no ZombieBuddy.jar" >&2
    exit 1
fi

echo "==> Installing into $GAME_PATH"
for target in "$GAME_PATH/ZombieBuddy.jar" "$GAME_PATH/projectzomboid/ZombieBuddy.jar"; do
    dir="$(dirname "$target")"
    [[ -d "$dir" ]] || continue
    [[ -f "$target.orig" ]] || cp "$target" "$target.orig" 2>/dev/null || true
    cp "$BUILT" "$target"
    echo "    $target"
done

VER=$(unzip -p "$BUILT" META-INF/MANIFEST.MF | grep -i Implementation-Version | tr -d '\r')
echo "==> Done ($VER)"
