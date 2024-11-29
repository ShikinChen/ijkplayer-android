cmake_minimum_required(VERSION 3.4.1)

project(ijkplayer)
set(THREADS_PREFER_PTHREAD_FLAG ON)
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
#add_library(${FFMPEG_LIB_NAME}
#        SHARED
#        ${FFMPEG_ABI_PATH}/config.h)
#set_target_properties(${FFMPEG_LIB_NAME} PROPERTIES LINKER_LANGUAGE C POSITION_INDEPENDENT_CODE ON)
foreach (FFMPEG_LIB_FILE ${FFMPEG_LIB_FILES})
    get_filename_component(LIB_NAME ${FFMPEG_LIB_FILE} NAME_WLE)
    string(REPLACE "lib" "" LIB_NAME ${LIB_NAME})
    list(FIND FFMPEG_LIBS ${LIB_NAME} index)
    if (index EQUAL -1)
        list(APPEND FFMPEG_LIBS ${LIB_NAME})

        string(REGEX REPLACE ".*\\.(.*)" "\\1" EXT ${FFMPEG_LIB_FILE})
        if (EXT STREQUAL "a")
            add_library(${LIB_NAME} STATIC IMPORTED)
        elseif (EXT STREQUAL "so")
            add_library(${LIB_NAME} SHARED IMPORTED)
        endif ()

        set_target_properties(${LIB_NAME}
                PROPERTIES
                IMPORTED_LOCATION ${FFMPEG_LIB_FILE})
    endif ()
endforeach ()
include_directories(${FFMPEG_ABI_PATH}/include)
target_link_libraries(swscale INTERFACE avutil)

find_library(media-lib mediandk REQUIRED)
target_link_libraries(avcodec INTERFACE ${media-lib})

#set_target_properties(${FFMPEG_LIB_NAME}
#        PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
#        ${FFMPEG_ABI_PATH}/include
#)
#target_link_libraries(${FFMPEG_LIB_NAME} INTERFACE
#        ${FFMPEG_LIBS})
add_subdirectory(cmake/ijkmedia)