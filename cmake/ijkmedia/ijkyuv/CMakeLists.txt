cmake_minimum_required(VERSION 3.4.1)
project("ijkyuv")

set(IJKYUV_PATH ${IJKMEDIA_PATH}/ijkyuv)

file(GLOB CPP_FILE_PATH
        #ijkyuv
        ${IJKYUV_PATH}/source/*.cc
        )

add_library(
        ijkyuv
        SHARED
        ${CPP_FILE_PATH})

target_include_directories(ijkyuv
        PUBLIC
        ${IJKYUV_PATH}/include
        )