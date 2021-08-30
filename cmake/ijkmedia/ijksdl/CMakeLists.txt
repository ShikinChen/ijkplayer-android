cmake_minimum_required(VERSION 3.4.1)
project("ijksdl")

set(IJKSDL_PATH ${IJKMEDIA_PATH}/ijksdl)

file(GLOB CPP_FILE_PATH
        #ijksdl
        ${IJKSDL_PATH}/*.c
        ${IJKSDL_PATH}/android/*.c
        ${IJKSDL_PATH}/dummy/*.c
        ${IJKSDL_PATH}/ffmpeg/*.c
        ${IJKSDL_PATH}/ffmpeg/abi_all/*.c
        ${IJKSDL_PATH}/gles2/*.c
        ${IJKSDL_PATH}/gles2/fsh/*.c
        ${IJKSDL_PATH}/gles2/vsh/*.c
        )


add_library(
        ijksdl
        SHARED
        ${CPP_FILE_PATH})

find_library(EGL-lib EGL)
find_library(GLES-lib GLESv2)
find_library(OpenSLES-lib OpenSLES)
find_library(android-lib android)

target_link_libraries(
        ijksdl
        ijkj4a ijkffmpeg ijkyuv ${EGL-lib} ${GLES-lib} ${OpenSLES-lib} ${android-lib})

target_include_directories(ijksdl
        PUBLIC
        ${IJKSDL_PATH}
        ${IJKMEDIA_PATH}
        )