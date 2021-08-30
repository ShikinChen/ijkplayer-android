cmake_minimum_required(VERSION 3.4.1)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/ijkj4a)
#add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/ijkplayer)
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/ijksdl)


file(GLOB IJKYUV_CPP_FILE_PATH
        #ijkyuv
        ${IJKYUV_PATH}/source/*.cc
        )

add_library(
        ijkyuv
        SHARED
        ${IJKYUV_CPP_FILE_PATH})

target_include_directories(ijkyuv
        PUBLIC
        ${IJKYUV_PATH}/include
        )


file(GLOB IJKSOUNDTOUCH_CPP_FILE_PATH
        #ijksoundtouch
        ${IJKSOUNDTOUCH_PATH}/source/SoundTouch/*.cpp
        ${IJKSOUNDTOUCH_PATH}/*.cpp
        )

add_library(
        ijksoundtouch
        SHARED
        ${IJKSOUNDTOUCH_CPP_FILE_PATH})

target_include_directories(ijksoundtouch
        PUBLIC
        ${IJKSOUNDTOUCH_PATH}
        ${IJKSOUNDTOUCH_PATH}/include
        )