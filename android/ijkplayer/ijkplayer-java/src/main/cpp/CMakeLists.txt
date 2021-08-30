cmake_minimum_required(VERSION 3.4.1)

find_library(log-lib log)
find_library(m-lib m)
find_library(z-lib z)
find_library(android-lib android)
find_library(EGL-lib EGL)
find_library(jnigraphics-lib jnigraphics)
find_library(GLES-lib GLESv2)
find_library(OpenSLES-lib OpenSLES)

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

#引入头文件
include_directories(
        ${IJKMEDIA_PATH}
        ${IJKPLAYER_PATH}
)

add_library(
        ijkplayer
        SHARED
        ${CPP_FILE_PATH})

target_link_libraries(
        ijkplayer
        ijkffmpeg ijkj4a ijksdl ijksoundtouch  ${m-lib} ${z-lib} ${jnigraphics-lib})