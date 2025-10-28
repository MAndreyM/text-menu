# Конфигурация основного приложения
cmake_minimum_required(VERSION 3.15)

# Создаем исполняемый файл
add_executable(text-menu
    main.cpp
)

# Настройки компиляции для C++17
target_compile_features(text-menu PRIVATE cxx_std_17)

# Директории include
target_include_directories(text-menu 
    PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
)

# Настройки компилятора
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    # Предупреждения
    target_compile_options(text-menu PRIVATE
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wconversion
        -Wsign-conversion
    )
    
    # Оптимизация для Release
    target_compile_options(text-menu PRIVATE
        $<$<CONFIG:Release>:-O3>
        $<$<CONFIG:Debug>:-O0 -g3>
    )
endif()

# Настройки специфичные для Ninja
if(USE_NINJA)
    # Дополнительные опции для ускорения сборки
    target_compile_options(text-menu PRIVATE
        -fdiagnostics-color=always  # Цветные предупреждения
    )
endif()

# Определения для разных конфигураций
target_compile_definitions(text-menu
    PRIVATE
        $<$<CONFIG:Debug>:DEBUG=1>
        $<$<CONFIG:Release>:RELEASE=1 NDEBUG=1>
)

# Настройки линковки
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_link_options(text-menu PRIVATE
        $<$<CONFIG:Release>:-s>  # Удаление символов в Release
    )
endif()

# Установка для production развертывания
install(TARGETS text-menu
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Дополнительная цель для запуска приложения
add_custom_target(run
    COMMAND ./text-menu
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS text-menu
    COMMENT "Running the application"
)

# Генерация compile_commands.json для clangd и других инструментов
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Дополнительные цели для разработки

# Цель для форматирования кода
find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
    add_custom_target(format-src
        COMMAND ${CLANG_FORMAT} -i --style=file main.cpp utils.cpp utils.h
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Formatting source code"
    )
endif()

# Цель для анализа кода (если доступен clang-tidy)
find_program(CLANG_TIDY clang-tidy)
if(CLANG_TIDY)
    add_custom_target(analyze-src
        COMMAND ${CLANG_TIDY} main.cpp utils.cpp -- -I${CMAKE_CURRENT_SOURCE_DIR}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS text-menu
        COMMENT "Running static analysis"
    )
endif()

# Документация для исходного кода
if(DOXYGEN_FOUND)
    # Дополнительная цель для документации только исходного кода
    add_custom_target(docs-src
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_SOURCE_DIR}/docs/Doxyfile
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Generating documentation for source code"
    )
endif()

# Информация о цели
get_target_property(MYAPP_TYPE text-menu TYPE)
get_target_property(MYAPP_SOURCES text-menu SOURCES)

message(STATUS "Configured target 'text-menu'")
message(STATUS "  Type: ${MYAPP_TYPE}")
message(STATUS "  Sources: ${MYAPP_SOURCES}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")

# Экспорт переменных для родительского CMakeLists.txt
set(MYAPP_TARGET text-menu PARENT_SCOPE)


