cmake_minimum_required(VERSION 3.4.1)
project("ijkplayer")

set(IJKPLAYER_PATH ${IJKMEDIA_PATH}/ijkplayer)

file(GLOB CPP_FILE_PATH
        #ijkplayer
        ${IJKPLAYER_PATH}/*.c
        ${IJKPLAYER_PATH}/android/*.c
        ${IJKPLAYER_PATH}/android/pipeline/*.c
        ${IJKPLAYER_PATH}/ijkavformat/*.c
        ${IJKPLAYER_PATH}/ijkavutil/*.c
        ${IJKPLAYER_PATH}/ijkavutil/*.cpp
        ${IJKPLAYER_PATH}/pipeline/*.c

        ${CMAKE_SOURCE_DIR}/ijkprof/android-ndk-profiler-dummy/jni/*.c
        )

add_library(
        ijkplayer
        SHARED
        ${CPP_FILE_PATH})

target_include_directories(ijkplayer
        PUBLIC
        ${IJKPLAYER_PATH}
        )

find_library(m-lib m)
find_library(z-lib z)
find_library(jnigraphics-lib jnigraphics)

target_link_libraries(
        ijkplayer
        ijkffmpeg ijkj4a ijksdl ijksoundtouch  ${m-lib} ${z-lib} ${jnigraphics-lib})