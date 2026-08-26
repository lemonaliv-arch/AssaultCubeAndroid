@echo off
REM build_deps.bat - Cross-compile AssaultCube dependencies for Android (Windows)
REM Requires: Android NDK, CMake, Git, Make/NMake
REM
REM Usage: build_deps.bat [ABI]
REM   ABI defaults to arm64-v8a

setlocal enabledelayedexpansion

set ABI=%1
if "%ABI%"=="" set ABI=arm64-v8a
set API_LEVEL=21

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set DEPS_DIR=%PROJECT_ROOT%\source\android-deps
set INSTALL_DIR=%PROJECT_ROOT%\android\app\src\main\jni\prebuilt\%ABI%

REM Find NDK
if defined ANDROID_NDK_HOME (
    set NDK=%ANDROID_NDK_HOME%
) else (
    REM Try common locations
    if exist "%USERPROFILE%\Android\Sdk\ndk" (
        for /f "delims=" %%d in ('dir /b /ad /o-n "%USERPROFILE%\Android\Sdk\ndk"') do (
            set NDK=%USERPROFILE%\Android\Sdk\ndk\%%d
            goto :found_ndk
        )
    )
    echo Error: Android NDK not found. Set ANDROID_NDK_HOME.
    exit /b 1
)

:found_ndk
echo Using NDK: %NDK%
echo Target ABI: %ABI%
echo Install dir: %INSTALL_DIR%

if not exist "%DEPS_DIR%" mkdir "%DEPS_DIR%"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM ============================================================
REM Build libogg
REM ============================================================
echo === Building libogg ===
if not exist "%DEPS_DIR%\libogg" (
    cd /d "%DEPS_DIR%"
    git clone --depth 1 https://github.com/xiph/ogg.git libogg
)

cd /d "%DEPS_DIR%\libogg"
if not exist build mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE="%NDK%\build\cmake\android.toolchain.cmake" -DANDROID_ABI="%ABI%" -DANDROID_PLATFORM="android-%API_LEVEL%" -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -G "NMake Makefiles"
nmake
nmake install

REM ============================================================
REM Build libvorbis
REM ============================================================
echo === Building libvorbis ===
if not exist "%DEPS_DIR%\libvorbis" (
    cd /d "%DEPS_DIR%"
    git clone --depth 1 https://github.com/xiph/vorbis.git libvorbis
)

cd /d "%DEPS_DIR%\libvorbis"
if not exist build mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE="%NDK%\build\cmake\android.toolchain.cmake" -DANDROID_ABI="%ABI%" -DANDROID_PLATFORM="android-%API_LEVEL%" -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DOGG_INCLUDE_DIRS="%INSTALL_DIR%\include" -DOGG_LIBRARIES="%INSTALL_DIR%\lib\ogg.lib" -G "NMake Makefiles"
nmake
nmake install

REM ============================================================
REM Build OpenAL Soft
REM ============================================================
echo === Building OpenAL Soft ===
if not exist "%DEPS_DIR%\openal-soft" (
    cd /d "%DEPS_DIR%"
    git clone --depth 1 https://github.com/kcat/openal-soft.git
)

cd /d "%DEPS_DIR%\openal-soft"
if not exist build mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE="%NDK%\build\cmake\android.toolchain.cmake" -DANDROID_ABI="%ABI%" -DANDROID_PLATFORM="android-%API_LEVEL%" -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DALSOFT_REQUIRE_OPENSL=ON -DALSOFT_BACKEND_OPENSL=ON -DALSOFT_BACKEND_ANDROID=ON -DALSOFT_EXAMPLES=OFF -DALSOFT_UTILS=OFF -DALSOFT_NO_CONFIG_UTIL=ON -DLIBTYPE=STATIC -G "NMake Makefiles"
nmake
nmake install

echo.
echo === Dependencies built successfully ===
echo Libraries installed to: %INSTALL_DIR%
dir "%INSTALL_DIR%\lib\" 2>nul
dir "%INSTALL_DIR%\include\" 2>nul

endlocal
