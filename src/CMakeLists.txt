cmake_minimum_required(VERSION 3.28)
project(hello)

set(CMAKE_CXX_STANDARD 20)

find_package(OpenCV REQUIRED COMPONENTS core highgui imgproc imgcodecs videoio)

add_executable(hello main.cpp)

target_link_libraries(hello ${OpenCV_LIBS})
target_include_directories(hello PRIVATE ${OpenCV_INCLUDE_DIRS})

install(TARGETS hello DESTINATION bin)