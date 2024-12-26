cmake_minimum_required(VERSION 3.4.1)
project("ijkffmpeg")

find_library(mediandk-lib mediandk)

add_library(${FFMPEG_LIB_NAME} INTERFACE)
target_include_directories(${FFMPEG_LIB_NAME}
        INTERFACE
        ${FFMPEG_ABI_PATH}/include
)
target_link_libraries(${FFMPEG_LIB_NAME} INTERFACE
        ${FFMPEG_LIBS} ${mediandk-lib})

#TODO 打算配置将静态库打包成动态库ffmpeg,出现-fPIC问题暂时注释后面看能否解决       
# set(FFMPEG_NAME ffmpeg)
# set(FFMPEG_C ${CMAKE_BINARY_DIR}/ffmpeg.c)
# file(WRITE ${FFMPEG_C} "// This is a ffmpeg file to satisfy CMake requirements.\n")
# add_library(${FFMPEG_NAME} SHARED ${FFMPEG_C})
# target_include_directories(${FFMPEG_NAME}
#         PUBLIC
#         ${FFMPEG_ABI_PATH}/include
# )
# target_link_libraries(${FFMPEG_NAME}
#         "-Wl,--whole-archive"
#         ${FFMPEG_LIB_NAME}
#         "-Wl,--no-whole-archive"
# )
# set_target_properties(${FFMPEG_NAME} PROPERTIES COMPILE_OPTIONS "-fPIC")

# set_target_properties(${FFMPEG_NAME}
#         PROPERTIES
#         OUTPUT_NAME ${FFMPEG_NAME}
#         LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
# )
