cmake_minimum_required(VERSION 3.4.1)

project(ijkplayer)

add_definitions(-DNDEBUG)

set(IJKMEDIA_PATH ${CMAKE_SOURCE_DIR}/ijkmedia)

set(ABI ${ANDROID_ABI})
if (${ANDROID_ABI} STREQUAL armeabi-v7a)
    set(ABI "armv7a")
elseif (${ANDROID_ABI} STREQUAL arm64-v8a)
    set(ABI "arm64")
endif ()

set(FFMPEG_ABI_PATH ${CMAKE_SOURCE_DIR}/android/contrib/build/ffmpeg-${ABI}/output)
set(FFMPEG_LIB_PATH ${FFMPEG_ABI_PATH}/lib)
set(FFMPEG_LIB_NAME ijkffmpeg)

#ffmpeg
file(GLOB FFMPEG_LIB_FILES
        ${FFMPEG_LIB_PATH}/*.a
        )
add_library(${FFMPEG_LIB_NAME}
        SHARED
        ${FFMPEG_ABI_PATH}/config.h)
set_target_properties(${FFMPEG_LIB_NAME} PROPERTIES LINKER_LANGUAGE C POSITION_INDEPENDENT_CODE ON)
foreach (FFMPEG_LIB_FILE ${FFMPEG_LIB_FILES})
    get_filename_component(LIB_NAME ${FFMPEG_LIB_FILE} NAME_WE)
    string(REPLACE "lib" "" LIB_NAME "${LIB_NAME}")
    list(APPEND FFMPEG_LIBS ${LIB_NAME})
    add_library(${LIB_NAME}
            SHARED
            IMPORTED)
    set_target_properties(${LIB_NAME}
            PROPERTIES
            IMPORTED_LOCATION ${FFMPEG_LIB_FILE})
endforeach ()

set_target_properties(${FFMPEG_LIB_NAME}
        PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
        ${FFMPEG_ABI_PATH}/include
        )
message(WARNING "FFMPEG_LIBS:${FFMPEG_LIBS}")
target_link_libraries(${FFMPEG_LIB_NAME} INTERFACE
        ${FFMPEG_LIBS})
add_subdirectory(cmake/ijkmedia)