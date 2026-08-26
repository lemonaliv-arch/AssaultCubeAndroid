# AssaultCube Android Build Instructions

## Prerequisites

1. **Android Studio** (2023.1+) with Android SDK
2. **Android NDK** (r25+ recommended) - install via Android Studio SDK Manager
3. **CMake** 3.22.1+ - install via Android Studio SDK Manager
4. **Git** - for submodules and dependencies
5. **Java JDK** 8+ (Android Studio includes this)

## Setup

### 1. Clone with submodules

```bash
git clone --recursive <repo-url>
cd AC
```

Or if already cloned:
```bash
git submodule update --init --recursive
```

### 2. Set environment variables

```bash
# Linux/macOS
export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/25.2.9519653
export ANDROID_SDK_HOME=$HOME/Android/Sdk

# Windows
set ANDROID_NDK_HOME=%USERPROFILE%\Android\Sdk\ndk\25.2.9519653
set ANDROID_SDK_HOME=%USERPROFILE%\Android\Sdk
```

### 3. Build dependencies

```bash
# Linux/macOS
cd android
chmod +x build_deps.sh
./build_deps.sh arm64-v8a

# Windows
cd android
build_deps.bat arm64-v8a
```

This cross-compiles for arm64-v8a:
- **OpenAL Soft** (audio backend using OpenSL ES)
- **libogg** (audio container format)
- **libvorbis** (audio codec)

Libraries are installed to `android/app/src/main/jni/prebuilt/arm64-v8a/`.

### 4. Copy game assets

Copy the `packages/` directory to the Android assets folder:

```bash
# Linux/macOS
cp -r packages android/app/src/main/assets/packages

# Windows
xcopy /E /I packages android\app\src\main\assets\packages
```

### 5. Build the APK

#### Using Android Studio:
1. Open the `android/` directory in Android Studio
2. Wait for Gradle sync to complete
3. Build > Build Bundle(s) / APK(s) > Build APK(s)

#### Using command line:
```bash
cd android
./gradlew assembleDebug
```

The APK will be at `android/app/build/outputs/apk/debug/app-debug.apk`.

### 6. Install and run

```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

## Controller Support

The Android build supports PS4/DualShock 4 controllers via Bluetooth:

| Controller Button | Game Action |
|------------------|-------------|
| X (Cross) | Jump |
| O (Circle) | Crouch |
| Square | Reload |
| Triangle | Weapon switch |
| L1 | Previous weapon |
| R1 | Next weapon |
| L2 | Secondary fire (aim) |
| R2 | Primary fire (shoot) |
| L3 | Sprint |
| R3 | Zoom |
| D-Pad | Movement (alternative) |
| Left Stick | Movement |
| Right Stick | Camera look |
| Start | Menu |
| Select/Back | Scoreboard |

## Architecture

- **arm64-v8a**: Modern 64-bit ARM devices (2016+)
- **gl4es**: Translates desktop OpenGL 1.x/2.x calls to OpenGL ES 2.0 at runtime
- **SDL2**: Handles windowing, input, timing, and GL context creation
- **OpenAL Soft**: 3D positional audio via OpenSL ES backend

## Troubleshooting

### Build fails with "NDK not found"
Set `ANDROID_NDK_HOME` to your NDK installation path.

### Build fails with "CMake not found"
Install CMake via Android Studio > SDK Manager > SDK Tools.

### Game crashes on startup
Check logcat for errors:
```bash
adb logcat -s SDL:V AssaultCube:V
```

### Controller not working
Make sure the controller is paired via Bluetooth before launching the game.
SDL2 handles controller mapping automatically for most common controllers.

### Performance issues
- The game targets modern devices (arm64-v8a)
- gl4es adds some overhead for GL translation
- Disable water reflections and stencil shadows in game settings for better performance
