cmake_minimum_required(VERSION 3.15)
project(myapp VERSION 1.0.0 LANGUAGES CXX)

# Настройки компилятора
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Настройка генератора (предпочтительно Ninja)
if(CMAKE_GENERATOR STREQUAL "Ninja")
    message(STATUS "Using Ninja generator")
    set(USE_NINJA TRUE)
endif()

# Опции сборки
option(BUILD_TESTS "Build tests" ON)
option(BUILD_DOCS "Build documentation" ON)
option(USE_DOCTEST "Use doctest for testing" ON)
option(BUILD_EXAMPLES "Build examples" ON)

# Путь к doctest
if(USE_DOCTEST)
    # Сначала ищем в локальной директории third_party
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/third_party/doctest/doctest.h)
        set(DOCTEST_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/doctest)
        message(STATUS "Found doctest in third_party: ${DOCTEST_INCLUDE_DIR}")
    else()
        # Если не нашли локально, ищем в системных путях
        find_path(DOCTEST_INCLUDE_DIR doctest/doctest.h
            PATHS /usr/local/include /usr/include
        )
        if(DOCTEST_INCLUDE_DIR)
            message(STATUS "Found doctest in system: ${DOCTEST_INCLUDE_DIR}")
        else()
            message(WARNING "doctest not found, tests will be disabled")
            set(BUILD_TESTS OFF)
        endif()
    endif()
endif()

# Поддиректории

add_subdirectory(src/libtmenu)

#if(BUILD_EXAMPLES)
#    add_subdirectory(src/example)
#endif()

add_subdirectory(src)

if(BUILD_TESTS AND USE_DOCTEST AND DOCTEST_INCLUDE_DIR)
    add_subdirectory(tests)
endif()

if(BUILD_DOCS)
    # Цель для генерации документации
    find_package(Doxygen REQUIRED)
    if(DOXYGEN_FOUND)
        set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/docs/Doxyfile)
        set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/docs)
        
        add_custom_target(docs
            COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_IN}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            COMMENT "Generating API documentation with Doxygen"
            VERBATIM
        )
    endif()
endif()