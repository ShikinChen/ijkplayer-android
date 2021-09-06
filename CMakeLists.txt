cmake_minimum_required(VERSION 3.4.1)

project(ijkplayer)

add_definitions(-DNDEBUG)

set(IJKMEDIA_PATH ${CMAKE_SOURCE_DIR}/ijkmedia)

set(ABI "arm64")
if (${ANDROID_ABI} STREQUAL armeabi-v7a)
    set(ABI "armv7a")
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

add_subdirectory(cmake/ijkmedia)