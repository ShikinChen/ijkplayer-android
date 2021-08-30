cmake_minimum_required(VERSION 3.4.1)
project("ijkj4a")

set(IJKJ4A_PATH ${IJKMEDIA_PATH}/ijkj4a)

file(GLOB CPP_FILE_PATH
        #ijkj4a
        ${IJKJ4A_PATH}/j4a/*.c
        ${IJKJ4A_PATH}/j4a/class/android/media/*.c
        ${IJKJ4A_PATH}/j4a/class/android/os/*.c
        ${IJKJ4A_PATH}/j4a/class/java/nio/*.c
        ${IJKJ4A_PATH}/j4a/class/java/util/*.c
        ${IJKJ4A_PATH}/j4a/class/tv/danmaku/ijk/media/player/misc/*.c
        ${IJKJ4A_PATH}/j4a/class/tv/danmaku/ijk/media/player/*.c
        ${IJKJ4A_PATH}/j4au/class/android/media/*.c
        ${IJKJ4A_PATH}/j4au/class/java/nio/*.c
        )

find_library(log-lib log)

add_library(
        ijkj4a
        SHARED
        ${CPP_FILE_PATH})

target_link_libraries(
        ijkj4a
        ${log-lib})

target_include_directories(ijkj4a
        PUBLIC
        ${IJKJ4A_PATH}
        )