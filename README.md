## What is AssaultCube?
AssaultCube is a **FREE**, multiplayer, first-person shooter game, based on the
[CUBE engine](http://cubeengine.com/cube.php).

Taking place in realistic environments, with fast, arcade gameplay,
it's addictive and fun!

With efficient bandwidth usage, it's low-latency and can even run over a 56 Kbps
connection. It's tiny too, weighing in at a lightweight about 50 MB package
available for [Windows, Linux, Mac](https://assault.cubers.net/download.html).
On the correct settings, it can even run on old hardware (Pentium III and above).

![screenshot](https://user-images.githubusercontent.com/7680684/69888836-9a931d80-12b3-11ea-8123-bbf06908a96f.jpg)

## Features in a nutshell:

 * It's **FREE**.
 * Source code is available under a zlib-like open source license.
 * Low latency, it can even run across a 56 Kbps connection!
 * Lightweight size, only about 50 MB to download, plus additional maps
 average 20 KB each!
 * With the correct settings, it can run on old hardware
 (Pentium III and above).
 * Officially runs on most major systems (Windows: 2000/XP/Vista/7/8/10/11, Linux,
 macOS: 10.6+ 64-bit, **Android 5.0+**), and maybe even some
 [non-major ones](https://assault.cubers.net/docs/getstarted.html)?
 * Has a built in, in-game map editor to help players create their own maps and
 allows for co-operative editmode in realtime with others!
 * Features a single-player bot system.
 * Supports recording of your game by the "demo" system.
 * Contains many multiplayer game modes, including: Deathmatch, Survivor,
 Capture the Flag, Hunt the Flag, Keep the Flag, Pistol Frenzy, Last Swiss
 Standing & One-Shot One-Kill (plus team versions of these modes).
 * Comes pre-packaged with several dozen different maps!

## Android Port

This fork includes an Android port using **gl4es** (OpenGL to OpenGL ES translation)
and **SDL2** for windowing/input. PS4 controller via Bluetooth is supported.

### Prerequisites

- **Android Studio** (2023.1+) with Android SDK
- **Android NDK** r25+ (install via SDK Manager)
- **CMake** 3.22.1+ (install via SDK Manager)
- **Java JDK** 8+ (Android Studio includes this)

### Build Steps

```bash
# 1. Clone with submodules
git clone --recursive <repo-url>
cd AC

# 2. Build dependencies (OpenAL, vorbis, ogg)
cd android
chmod +x build_deps.sh
./build_deps.sh arm64-v8a    # or build_deps.bat on Windows

# 3. Copy game assets
cp -r packages android/app/src/main/assets/packages
cp -r config android/app/src/main/assets/config

# 4. Build APK
cd android
./gradlew assembleDebug
```

The APK will be at `android/app/build/outputs/apk/debug/app-debug.apk`.

### Install

```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

### Controller Mapping (PS4 via Bluetooth)

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
| Left Stick | Movement |
| Right Stick | Camera look |
| Start | Menu |
| Select/Back | Scoreboard |

### Architecture

- **arm64-v8a** only (modern 64-bit ARM devices)
- **gl4es** translates desktop OpenGL 1.x/2.x to OpenGL ES 2.0 at runtime
- **SDL2** handles windowing, input, timing, and GL context creation
- **OpenAL Soft** for 3D positional audio via OpenSL ES backend
- Game assets are extracted from APK to internal storage on first launch

## More info:

Most of this README was directly copied from the
[AssaultCube Homepage](https://assault.cubers.net), which should have everything
you need in relation to AssaultCube.

## Contributing:

Learn [how to become a contributor and submit your own code](CONTRIBUTING.md)

## Redistribution:

You may redistribute AssaultCube in any way the license permits, such as the
free unmodified distribution of AssaultCube's source and binaries. If you have
any doubts, you can look at the
[license](https://assault.cubers.net/docs/license.html).

