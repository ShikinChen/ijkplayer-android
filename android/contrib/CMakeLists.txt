cmake_minimum_required(VERSION 3.4.1)

#message(WARNING "CMAKE_BINARY_DIR:${CMAKE_BINARY_DIR}")
#configure_file(${FFMPEG_ABI_PATH}/libijkffmpeg.so ${CMAKE_BINARY_DIR}/android/ijkplayer/ijkplayer-java/libijkffmpeg.so COPYONLY)

#ffmpeg
add_library(ijkffmpeg
        SHARED
        IMPORTED)

set_target_properties(ijkffmpeg
        PROPERTIES IMPORTED_LOCATION
        ${FFMPEG_ABI_PATH}/libijkffmpeg.so)

set_target_properties(ijkffmpeg
        PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
        ${FFMPEG_ABI_PATH}/include
        )
