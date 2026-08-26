cmake_minimum_required(VERSION 3.22.1)
project(assaultcube CXX C)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_C_STANDARD 99)

# Paths
set(AC_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../../../../..)
set(AC_SRC ${AC_ROOT}/source/src)
set(AC_ENET ${AC_ROOT}/source/enet)
set(AC_INCLUDE ${AC_ROOT}/source/include)
set(SDL2_DIR ${AC_ROOT}/source/SDL2)
set(GL4ES_DIR ${AC_ROOT}/source/gl4es)
set(SDL2_IMAGE_DIR ${AC_ROOT}/source/SDL2_image)

# ============================================================
# SDL2 (built from source as shared library for Android JNI)
# ============================================================
set(SDL2_STATIC OFF CACHE BOOL "" FORCE)
set(SDL2_SHARED ON CACHE BOOL "" FORCE)
set(SDL2_DISABLE_INSTALL ON CACHE BOOL "" FORCE)
add_subdirectory(${SDL2_DIR} ${CMAKE_BINARY_DIR}/SDL2)

# ============================================================
# SDL2_image (built from source, loads PNG/JPG textures)
# ============================================================
set(SDL2IMAGE_SAMPLES OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_TESTS OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_JPG ON CACHE BOOL "" FORCE)
set(SDL2IMAGE_PNG ON CACHE BOOL "" FORCE)
set(SDL2IMAGE_WEBP OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_TIF OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_JXL OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_AVIF OFF CACHE BOOL "" FORCE)
set(SDL2IMAGE_INSTALL OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
add_subdirectory(${SDL2_IMAGE_DIR} ${CMAKE_BINARY_DIR}/SDL2_image)

# ============================================================
# gl4es (built from source, translates GL -> GLES)
# ============================================================
# gl4es has its own CMakeLists.txt - configure it for Android
set(NO_X11 ON CACHE BOOL "" FORCE)
set(NOX11 ON CACHE BOOL "" FORCE)
set(NO_GBM ON CACHE BOOL "" FORCE)
set(GLX_STUBS ON CACHE BOOL "" FORCE)
set(DEFAULT_GLES "libGLESv2.so" CACHE STRING "" FORCE)
set(DEFAULT_EGL "libEGL.so" CACHE STRING "" FORCE)
set(USE_ANDROID_LOG ON CACHE BOOL "" FORCE)
set(NO_INIT_CONSTRUCTOR ON CACHE BOOL "" FORCE)
add_subdirectory(${GL4ES_DIR} ${CMAKE_BINARY_DIR}/gl4es)

# ============================================================
# ENet (built from source)
# ============================================================
set(ENET_SOURCES
    ${AC_ENET}/callbacks.c
    ${AC_ENET}/compress.c
    ${AC_ENET}/host.c
    ${AC_ENET}/list.c
    ${AC_ENET}/packet.c
    ${AC_ENET}/peer.c
    ${AC_ENET}/protocol.c
    ${AC_ENET}/unix.c
)

add_library(enet STATIC ${ENET_SOURCES})
target_include_directories(enet PUBLIC ${AC_ENET}/include)
target_compile_definitions(enet PUBLIC HAS_SOCKLEN_T)

# ============================================================
# AssaultCube Client
# ============================================================
set(AC_CLIENT_SOURCES
    ${AC_SRC}/crypto.cpp
    ${AC_SRC}/audiomanager.cpp
    ${AC_SRC}/autodownload.cpp
    ${AC_SRC}/client.cpp
    ${AC_SRC}/clientgame.cpp
    ${AC_SRC}/clients2c.cpp
    ${AC_SRC}/command.cpp
    ${AC_SRC}/console.cpp
    ${AC_SRC}/docs.cpp
    ${AC_SRC}/editing.cpp
    ${AC_SRC}/entities.cpp
    ${AC_SRC}/http.cpp
    ${AC_SRC}/log.cpp
    ${AC_SRC}/main.cpp
    ${AC_SRC}/menus.cpp
    ${AC_SRC}/oggstream.cpp
    ${AC_SRC}/openal.cpp
    ${AC_SRC}/packetqueue.cpp
    ${AC_SRC}/physics.cpp
    ${AC_SRC}/protocol.cpp
    ${AC_SRC}/rendercubes.cpp
    ${AC_SRC}/rendergl.cpp
    ${AC_SRC}/renderhud.cpp
    ${AC_SRC}/rendermodel.cpp
    ${AC_SRC}/renderparticles.cpp
    ${AC_SRC}/rendertext.cpp
    ${AC_SRC}/rndmap.cpp
    ${AC_SRC}/scoreboard.cpp
    ${AC_SRC}/serverms.cpp
    ${AC_SRC}/server.cpp
    ${AC_SRC}/serverbrowser.cpp
    ${AC_SRC}/shadow.cpp
    ${AC_SRC}/soundlocation.cpp
    ${AC_SRC}/soundscheduler.cpp
    ${AC_SRC}/stream.cpp
    ${AC_SRC}/texture.cpp
    ${AC_SRC}/tools.cpp
    ${AC_SRC}/water.cpp
    ${AC_SRC}/weapon.cpp
    ${AC_SRC}/wizard.cpp
    ${AC_SRC}/world.cpp
    ${AC_SRC}/worldio.cpp
    ${AC_SRC}/worldlight.cpp
    ${AC_SRC}/worldocull.cpp
    ${AC_SRC}/worldrender.cpp
    ${AC_SRC}/zip.cpp
    ${AC_SRC}/bot/bot.cpp
    ${AC_SRC}/bot/botmanager.cpp
    ${AC_SRC}/bot/bot_ai.cpp
    ${AC_SRC}/bot/bot_util.cpp
    ${AC_SRC}/bot/bot_waypoint.cpp
    ${AC_SRC}/bot/ac_bot.cpp
    ${AC_SRC}/bot/ac_bot_ai.cpp
)

add_library(main SHARED ${AC_CLIENT_SOURCES})

target_include_directories(main PRIVATE
    ${AC_SRC}
    ${AC_SRC}/bot
    ${AC_ENET}/include
    ${AC_INCLUDE}
    ${GL4ES_DIR}/include
)

target_compile_definitions(main PRIVATE
    __ANDROID__
    USE_GLES2
    GL_GLES_PROTOTYPES=0
    HAVE_STDINT_H
    HAVE_STDBOOL_H
)

# rendermodel.cpp needs -fno-strict-aliasing
set_source_files_properties(${AC_SRC}/rendermodel.cpp PROPERTIES
    COMPILE_FLAGS "-fno-strict-aliasing"
)

target_link_libraries(main
    SDL2
    SDL2_image
    GL
    enet
    # Android system libraries
    OpenSLES
    android
    log
    z
    dl
    GLESv2
    EGL
)

# Link prebuilt audio libraries if available
set(PREBUILT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/prebuilt/${ANDROID_ABI})

if(EXISTS ${PREBUILT_DIR}/lib/libopenal.a)
    add_library(openal STATIC IMPORTED)
    set_target_properties(openal PROPERTIES IMPORTED_LOCATION ${PREBUILT_DIR}/lib/libopenal.a)
    target_include_directories(main PRIVATE ${PREBUILT_DIR}/include)
    target_link_libraries(main openal)
elseif(EXISTS ${PREBUILT_DIR}/libopenal.so)
    add_library(openal SHARED IMPORTED)
    set_target_properties(openal PROPERTIES IMPORTED_LOCATION ${PREBUILT_DIR}/libopenal.so)
    target_include_directories(main PRIVATE ${PREBUILT_DIR}/include)
    target_link_libraries(main openal)
else()
    message(WARNING "OpenAL not found at ${PREBUILT_DIR}. Run build_deps.sh first.")
endif()

if(EXISTS ${PREBUILT_DIR}/lib/libvorbisfile.a)
    add_library(vorbisfile STATIC IMPORTED)
    set_target_properties(vorbisfile PROPERTIES IMPORTED_LOCATION ${PREBUILT_DIR}/lib/libvorbisfile.a)
    target_link_libraries(main vorbisfile)
elseif(EXISTS ${PREBUILT_DIR}/libvorbisfile.so)
    add_library(vorbisfile SHARED IMPORTED)
    set_target_properties(vorbisfile PROPERTIES IMPORTED_LOCATION ${PREBUILT_DIR}/libvorbisfile.so)
    target_link_libraries(main vorbisfile)
else()
    message(WARNING "libvorbisfile not found at ${PREBUILT_DIR}. Run build_deps.sh first.")
endif()

if(EXISTS ${PREBUILT_DIR}/lib/libvorbis.a)
    add_library(vorbis STATIC IMPORTED)
    set_target_properties(vorbis PROPERTIES IMPORTED_LOCATION ${PREBUILT_DIR}/lib/libvorbis.a)
    target_link_libraries(main vorbis)
endif()

if(EXISTS ${PREBUILT_DIR}/lib/libogg.a)
    add_library(ogg STATIC IMPORTED)
    set_target_properties(ogg PROPERTIES IMPORTED_LOCATION ${PREBUILT_DIR}/lib/libogg.a)
    target_link_libraries(main ogg)
endif()
