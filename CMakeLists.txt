if(NOT CMAKE_GENERATOR STREQUAL "Xcode")
    return()
endif()

cmake_minimum_required(VERSION 3.28.1 FATAL_ERROR)
project(Turf LANGUAGES Swift)

set(FRAMEWORK_VERSION "3.0.0")
enable_language(Swift)
set(CMAKE_Swift_LANGUAGE_VERSION 5.0)
enable_testing()

set(FRAMEWORK_NAME "Turf")
set(FRAMEWORK_TEST_TARGET "TurfTests")

add_subdirectory(Sources)
add_subdirectory(Tests)


install(TARGETS ${FRAMEWORK_NAME}
    FRAMEWORK DESTINATION Frameworks
)
