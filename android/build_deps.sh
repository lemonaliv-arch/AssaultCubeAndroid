#!/bin/bash
# build_deps.sh - Cross-compile AssaultCube dependencies for Android
# Requires: Android NDK installed and ANDROID_NDK_HOME set
#
# Dependencies built:
#   - OpenAL Soft (audio)
#   - libogg (container format)
#   - libvorbis (audio codec)
#
# Usage: ./build_deps.sh [ABI]
#   ABI defaults to arm64-v8a

set -e

ABI="${1:-arm64-v8a}"
API_LEVEL=21
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPS_DIR="$PROJECT_ROOT/source/android-deps"
BUILD_DIR="$DEPS_DIR/build"
INSTALL_DIR="$PROJECT_ROOT/android/app/src/main/jni/prebuilt/$ABI"

# Find NDK
if [ -z "$ANDROID_NDK_HOME" ]; then
    # Try common locations
    for dir in "$HOME/Android/Sdk/ndk" "$HOME/Library/Android/sdk/ndk" "/opt/android-ndk"; do
        if [ -d "$dir" ]; then
            ANDROID_NDK_HOME="$(ls -d "$dir"/*/ 2>/dev/null | sort -V | tail -1)"
            break
        fi
    done
fi

if [ -z "$ANDROID_NDK_HOME" ] || [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "Error: Android NDK not found. Set ANDROID_NDK_HOME."
    exit 1
fi

echo "Using NDK: $ANDROID_NDK_HOME"
echo "Target ABI: $ABI"
echo "Install dir: $INSTALL_DIR"

mkdir -p "$BUILD_DIR" "$INSTALL_DIR"

# Set up toolchain
TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
if [ ! -d "$TOOLCHAIN" ]; then
    TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
fi
if [ ! -d "$TOOLCHAIN" ]; then
    echo "Error: Cannot find NDK toolchain"
    exit 1
fi

case "$ABI" in
    arm64-v8a) TARGET="aarch64-linux-android"; CC_TARGET="aarch64-linux-android${API_LEVEL}" ;;
    armeabi-v7a) TARGET="armv7a-linux-androideabi"; CC_TARGET="armv7a-linux-androideabi${API_LEVEL}" ;;
    x86) TARGET="i686-linux-android"; CC_TARGET="i686-linux-android${API_LEVEL}" ;;
    x86_64) TARGET="x86_64-linux-android"; CC_TARGET="x86_64-linux-android${API_LEVEL}" ;;
    *) echo "Unsupported ABI: $ABI"; exit 1 ;;
esac

export CC="$TOOLCHAIN/bin/${CC_TARGET}-clang"
export CXX="$TOOLCHAIN/bin/${CC_TARGET}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"
export CFLAGS="-O3 -fPIC"
export CXXFLAGS="-O3 -fPIC"

# ============================================================
# Build libogg
# ============================================================
echo "=== Building libogg ==="
OGG_DIR="$DEPS_DIR/libogg"
if [ ! -d "$OGG_DIR" ]; then
    cd "$DEPS_DIR"
    git clone --depth 1 https://github.com/xiph/ogg.git libogg
fi

cd "$OGG_DIR"
mkdir -p build && cd build
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$API_LEVEL" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install

# ============================================================
# Build libvorbis
# ============================================================
echo "=== Building libvorbis ==="
VORBIS_DIR="$DEPS_DIR/libvorbis"
if [ ! -d "$VORBIS_DIR" ]; then
    cd "$DEPS_DIR"
    git clone --depth 1 https://github.com/xiph/vorbis.git libvorbis
fi

cd "$VORBIS_DIR"
mkdir -p build && cd build
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$API_LEVEL" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DOGG_INCLUDE_DIRS="$INSTALL_DIR/include" \
    -DOGG_LIBRARIES="$INSTALL_DIR/lib/libogg.a"
make -j$(nproc)
make install

# ============================================================
# Build OpenAL Soft
# ============================================================
echo "=== Building OpenAL Soft ==="
OPENAL_DIR="$DEPS_DIR/openal-soft"
if [ ! -d "$OPENAL_DIR" ]; then
    cd "$DEPS_DIR"
    git clone --depth 1 https://github.com/kcat/openal-soft.git
fi

cd "$OPENAL_DIR"
mkdir -p build && cd build
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$API_LEVEL" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DALSOFT_REQUIRE_OPENSL=ON \
    -DALSOFT_BACKEND_OPENSL=ON \
    -DALSOFT_BACKEND_ANDROID=ON \
    -DALSOFT_EXAMPLES=OFF \
    -DALSOFT_UTILS=OFF \
    -DALSOFT_NO_CONFIG_UTIL=ON \
    -DLIBTYPE=STATIC
make -j$(nproc)
make install

echo ""
echo "=== Dependencies built successfully ==="
echo "Libraries installed to: $INSTALL_DIR"
echo ""
echo "Contents:"
ls -la "$INSTALL_DIR/lib/" 2>/dev/null || echo "(check $INSTALL_DIR)"
ls -la "$INSTALL_DIR/include/" 2>/dev/null || echo "(check $INSTALL_DIR/include)"
