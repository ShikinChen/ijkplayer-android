cmake_minimum_required(VERSION 3.4.1)

project(ijkplayer)
set(THREADS_PREFER_PTHREAD_FLAG ON)
add_definitions(-DNDEBUG)

set(IJKMEDIA_PATH ${CMAKE_SOURCE_DIR}/ijkmedia)

set(ABI ${ANDROID_ABI})
if(${ANDROID_ABI} STREQUAL armeabi-v7a)
    set(ABI "armv7a")
elseif(${ANDROID_ABI} STREQUAL arm64-v8a)
    set(ABI "arm64")
endif()

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
foreach(FFMPEG_LIB_FILE ${FFMPEG_LIB_FILES})
    get_filename_component(LIB_NAME ${FFMPEG_LIB_FILE} NAME_WLE)
    string(REPLACE "lib" "" LIB_NAME ${LIB_NAME})
    list(FIND FFMPEG_LIBS ${LIB_NAME} index)
    if(index EQUAL -1)
        list(APPEND FFMPEG_LIBS ${LIB_NAME})

        string(REGEX REPLACE ".*\\.(.*)" "\\1" EXT ${FFMPEG_LIB_FILE})
        if(EXT STREQUAL "a")
            add_library(${LIB_NAME} STATIC IMPORTED)
        elseif(EXT STREQUAL "so")
            add_library(${LIB_NAME} SHARED IMPORTED)
        endif()

        set_target_properties(${LIB_NAME}
            PROPERTIES
            IMPORTED_LOCATION ${FFMPEG_LIB_FILE})

    endif()
endforeach()
include_directories(${FFMPEG_ABI_PATH}/include)
target_link_libraries(swscale INTERFACE avutil)
#配置openssl
set(OPENSSL_ABI_PATH ${CMAKE_SOURCE_DIR}/android/contrib/build/openssl-${ABI}/output)
set(OPENSSL_LIB_PATH ${OPENSSL_ABI_PATH}/lib)
if(EXISTS "${OPENSSL_LIB_PATH}/libssl.a")
    set(OPENSSL_SSL_NAME openssl_ssl)
    set(OPENSSL_CRYPTO_NAME openssl_crypto)
    set(OPENSSL_LIB_NAME ijkopenssl)

    add_library(${OPENSSL_SSL_NAME} STATIC IMPORTED)
    add_library(${OPENSSL_CRYPTO_NAME} STATIC IMPORTED)

    set_target_properties(${OPENSSL_SSL_NAME}
        PROPERTIES
        IMPORTED_LOCATION ${OPENSSL_LIB_PATH}/libssl.a
    )

    set_target_properties(${OPENSSL_CRYPTO_NAME}
        PROPERTIES
        IMPORTED_LOCATION ${OPENSSL_LIB_PATH}/libcrypto.a
    )
    target_include_directories(${OPENSSL_CRYPTO_NAME} INTERFACE ${OPENSSL_ABI_PATH}/include)
    add_library(${OPENSSL_LIB_NAME} INTERFACE)
    target_link_libraries(${OPENSSL_LIB_NAME} INTERFACE
        ${OPENSSL_SSL_NAME}
        ${OPENSSL_CRYPTO_NAME}
    )

    list(APPEND FFMPEG_LIBS ${OPENSSL_LIB_NAME})

endif()

add_subdirectory(cmake/ijkmedia)
