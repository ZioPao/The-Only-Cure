#!/usr/bin/env bash
#
# Builds a locally-patched ZombieBuddy.jar for the ZBSpec test harness.
#
# Why: ZombieBuddy v2.3.4's `experimental` agent aborts on Linux because
# `JavaStateDumper.init()` calls `sun.misc.Signal.handle(new Signal("INFO"), ...)`
# and "INFO" is not a valid signal on Linux, throwing IllegalArgumentException.
# ZB swallows the resulting InvocationTargetException, so `experimental.PreMain`
# never starts the Lua HTTP API server and never writes `zbLuaAPI.txt`, which is
# what ZBSpec needs. Upstream fixed this in master (unreleased); this script
# applies the same guard to the released jar.
#
# The jar is signed, so replacing a class invalidates its per-entry digest. We
# therefore also rebuild the jar without the signature block.
#
# Usage: dev_stuff/tests/build_zb_jar.sh [path-to-zulu-jdk]
#        (downloads a JDK automatically if not provided/found)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORK="${WORK:-/tmp/opencode/zbpatch}"
ZB_VERSION="2.3.4"
ZB_SHA256="eb79b9876332010733a8e0d7ce4fe0377846059a9e28859029e2a0fb449f6cf2"
JDK_URL="https://cdn.azul.com/zulu/bin/zulu25.30.17-ca-jdk25.0.1-linux_x64.tar.gz"

GAME_PATH="${1:-}"
if [[ -z "$GAME_PATH" ]]; then
    echo "usage: $0 <game-install-dir>" >&2
    echo "  e.g. ~/.local/share/Steam/steamapps/common/ProjectZomboid" >&2
    exit 2
fi
GAME_PATH="${GAME_PATH/#\~/$HOME}"
JAR="$GAME_PATH/ZombieBuddy.jar"

if [[ ! -f "$JAR" ]]; then
    echo "error: $JAR not found" >&2
    exit 1
fi

mkdir -p "$WORK"
cd "$WORK"

# Locate a JDK 25 (needed to compile against the game's class files, version 69).
JDK_BIN="${JDK_BIN:-}"
if [[ -z "$JDK_BIN" ]]; then
    for candidate in "$WORK"/zulu25*/bin /usr/lib/jvm/*/bin; do
        if [[ -x "$candidate/javac" ]]; then JDK_BIN="$candidate"; break; fi
    done
fi
if [[ -z "$JDK_BIN" ]]; then
    echo "==> Downloading Zulu JDK 25"
    curl -sSL -o zulu25.tar.gz "$JDK_URL"
    tar xzf zulu25.tar.gz
    JDK_BIN="$WORK/$(ls -d zulu25*/ | head -1)bin"
fi
echo "==> Using JDK: $($JDK_BIN/javac -version 2>&1)"

if [[ ! -f ZombieBuddy.jar ]]; then
    echo "==> Downloading ZombieBuddy $ZB_VERSION"
    curl -sSL -o ZombieBuddy.jar "https://github.com/zed-0xff/ZombieBuddy/releases/download/v${ZB_VERSION}/ZombieBuddy.jar"
    echo "$ZB_SHA256  ZombieBuddy.jar" | sha256sum -c --status - || {
        echo "error: checksum mismatch" >&2; exit 1; }
fi

echo "==> Preparing source"
rm -rf src out jarbuild
mkdir -p src/me/zed_0xff/zombie_buddy/patches/experimental
cat > src/me/zed_0xff/zombie_buddy/patches/experimental/JavaStateDumper.java <<'JAVA'
package me.zed_0xff.zombie_buddy.patches.experimental;

import org.lwjgl.glfw.GLFW;
import org.lwjgl.glfw.GLFWKeyCallbackI;

import sun.misc.Signal;

import me.zed_0xff.zombie_buddy.*;

public class JavaStateDumper {
    private static GLFWKeyCallbackI _originalKeyCallback = null;
    private static boolean _initialized = false;
    private static long _window = 0;

    static void init() {
        if (!_initialized) {
            _initialized = true;
            Callbacks.onDisplayCreate.register(JavaStateDumper::installKeyCallback);
            try {
                Signal.handle(new Signal("INFO"), JavaStateDumper::handleSignal);
            } catch (IllegalArgumentException e) {
                Logger.info("SIGINFO is unavailable; keyboard state dump remains enabled.");
            }
        }
    }

    public static void handleSignal(Signal signal) {
        if ("INFO".equals(signal.getName())) {
            dumpThreadStacks();
        } else {
            Logger.warn("Received unexpected signal: " + signal);
        }
    }

    public static void installKeyCallback() {
        try {
            if (!org.lwjglx.opengl.Display.isCreated()) return;
            long window = org.lwjglx.opengl.Display.getWindow();
            if (window == _window) return;
            _window = window;
            _originalKeyCallback = GLFW.glfwSetKeyCallback(window, JavaStateDumper::handleKey);
            Logger.info("Installed GLFW key callback for Ctrl+T thread dump");
        } catch (Throwable t) {
            Logger.warn("Failed to install GLFW key callback: " + t);
        }
    }

    private static void handleKey(long window, int key, int scancode, int action, int mods) {
        if (key == GLFW.GLFW_KEY_T && action == GLFW.GLFW_PRESS && (mods & GLFW.GLFW_MOD_CONTROL) != 0) {
            dumpThreadStacks();
        }
        if (_originalKeyCallback != null) {
            _originalKeyCallback.invoke(window, key, scancode, action, mods);
        }
    }

    public static void dumpThreadStacks() {
        Logger.info("=== Thread Dump ===");
        for (var entry : Thread.getAllStackTraces().entrySet()) {
            Thread t = entry.getKey();
            StackTraceElement[] stack = entry.getValue();
            Logger.info(String.format("Thread: %s (id=%d, state=%s)", t.getName(), t.getId(), t.getState()));
            for (StackTraceElement el : stack) {
                Logger.info("    at " + el);
            }
        }
        Logger.info("=== End Thread Dump ===");
    }
}
JAVA

echo "==> Compiling"
"$JDK_BIN/javac" -nowarn -cp "$JAR:$GAME_PATH/projectzomboid/projectzomboid.jar" -d out \
    src/me/zed_0xff/zombie_buddy/patches/experimental/JavaStateDumper.java

echo "==> Repackaging without signature"
mkdir jarbuild && cd jarbuild
unzip -q "$JAR" -x 'META-INF/*.SF' 'META-INF/*.RSA' 'META-INF/*.DSA' || true
cp "$WORK/out/me/zed_0xff/zombie_buddy/patches/experimental/JavaStateDumper.class" \
   me/zed_0xff/zombie_buddy/patches/experimental/JavaStateDumper.class
printf 'Manifest-Version: 1.0\r\nPremain-Class: me.zed_0xff.zombie_buddy.Agent\r\nCan-Redefine-Classes: true\r\nCan-Retransform-Classes: true\r\nImplementation-Version: %s\r\nMulti-Release: true\r\n\r\n' "$ZB_VERSION" > META-INF/MANIFEST.MF
"$JDK_BIN/jar" --create --file "$WORK/ZombieBuddy-patched.jar" --manifest META-INF/MANIFEST.MF -C . .

echo "==> Backing up original and installing patched jar"
[[ -f "$JAR.orig" ]] || cp "$JAR" "$JAR.orig"
cp "$WORK/ZombieBuddy-patched.jar" "$JAR"

echo "==> Done: $JAR patched (original at $JAR.orig)"
