cmake_minimum_required(VERSION 2.8)
project( conv LANGUAGES CXX CUDA)
find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )
message (STATUS "opencv include"  ${OpenCV_INCLUDE_DIRS} )

add_library(errCheck 
    errCheck.hpp
    errCheck.cu)

add_executable( conv convolution.cu )
target_link_libraries( conv ${OpenCV_LIBS} errCheck)
