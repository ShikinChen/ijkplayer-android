cmake_minimum_required(VERSION 3.4.1)

project(ijkplayer)

add_definitions(-DNDEBUG)

set(IJKMEDIA_PATH ${CMAKE_SOURCE_DIR}/ijkmedia)
set(IJKJ4A_PATH ${IJKMEDIA_PATH}/ijkj4a)
set(IJKSDL_PATH ${IJKMEDIA_PATH}/ijksdl)
set(IJKMEDIA_PATH ${CMAKE_SOURCE_DIR}/ijkmedia)
set(IJKJ4A_PATH ${IJKMEDIA_PATH}/ijkj4a)
set(IJKPLAYER_PATH ${IJKMEDIA_PATH}/ijkplayer)
set(IJKYUV_PATH ${IJKMEDIA_PATH}/ijkyuv)
set(IJKSOUNDTOUCH_PATH ${IJKMEDIA_PATH}/ijksoundtouch)

set(ABI "arm64")
if (${ANDROID_ABI} STREQUAL armeabi-v7a)
    set(ABI "armv7a")
elseif (${ANDROID_ABI} STREQUAL x86)
    set(ABI "x86")
elseif (${ANDROID_ABI} STREQUAL x86_64)
    set(ABI "x86_64")
endif ()

set(FFMPEG_ABI_PATH ${CMAKE_SOURCE_DIR}/android/contrib/build/ffmpeg-${ABI}/output)

#ffmpeg
add_library(ijkffmpeg
        SHARED
        IMPORTED)

set_target_properties(ijkffmpeg
        PROPERTIES IMPORTED_LOCATION
        ${FFMPEG_ABI_PATH}/libijkffmpeg.so)

set_target_properties(ijkffmpeg
        PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
        ${FFMPEG_ABI_PATH}/include
        )

add_subdirectory(ijkmedia)

add_subdirectory(android/ijkplayer/ijkplayer-java/src/main/cpp)

