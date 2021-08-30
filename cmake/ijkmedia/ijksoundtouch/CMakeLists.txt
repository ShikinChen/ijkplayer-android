cmake_minimum_required(VERSION 3.4.1)
project("ijksoundtouch")

set(IJKSOUNDTOUCH_PATH ${IJKMEDIA_PATH}/ijksoundtouch)

file(GLOB CPP_FILE_PATH
        #ijksoundtouch
        ${IJKSOUNDTOUCH_PATH}/source/SoundTouch/*.cpp
        ${IJKSOUNDTOUCH_PATH}/*.cpp
        )

add_library(
        ijksoundtouch
        SHARED
        ${CPP_FILE_PATH})

target_include_directories(ijksoundtouch
        PUBLIC
        ${IJKSOUNDTOUCH_PATH}
        ${IJKSOUNDTOUCH_PATH}/include
        )