# Библиотека для реализации текстового меню
# На время разработки используем статическую библиотеку
# В дальнейшем может быть переведана в динамическую библиотеку

add_library(libtmenu STATIC
    include/command.hpp
    command.cpp
)

# Публичные заголовки
target_include_directories(libtmenu
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# Настройки компиляции
target_compile_features(libtmenu PUBLIC cxx_std_17)

# Настройки компилятора
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(libtmenu PRIVATE
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wconversion
        -Wsign-conversion
    )

    # Оптимизация
    target_compile_options(libtmenu PRIVATE
        $<$<CONFIG:Release>:-O3>
        $<$<CONFIG:Debug>:-O0 -g3>
    )
endif()

# Определения для разных конфигураций
target_compile_definitions(libtmenu
    PRIVATE
        $<$<CONFIG:Debug>:DEBUG=1 LIBTMENU_DEBUG>
        $<$<CONFIG:Release>:RELEASE=1 NDEBUG=1 LIBTMENU_RELEASE>
)

# Настройки позиционно-независимого кода (PIC) для статической библиотеки
# Это позволит в будущем легко перейти на динамическую библиотеку
set_target_properties(libtmenu PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
)

# Экспорт символов (для будущей совместимости с динамической библиотекой)
if(WIN32)
    target_compile_definitions(libtmenu PRIVATE LIBTMENU_STATIC_DEFINE)
endif()

# Установка библиотеки
install(TARGETS libtmenu
    EXPORT libtmenuTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(FILES include/command.hpp
    DESTINATION include/libtmenu
)

# Дополнительная цель для информации о библиотеке
add_custom_target(info-libtmenu
    COMMAND ${CMAKE_COMMAND} -E echo "Library: libtmenu (STATIC)"
    COMMAND ${CMAKE_COMMAND} -E echo "Version: ${PROJECT_VERSION}"
    COMMAND ${CMAKE_COMMAND} -E echo "C++ Standard: ${CMAKE_CXX_STANDARD}"
    COMMENT "Information about libtmenu library"
)

# Опция для переключения между статической и динамической библиотекой
option(LIBTMENU_SHARED "Build libtmenu as shared library" OFF)
if(LIBTMENU_SHARED)
    message(STATUS "Building libtmenu as SHARED library (experimental)")
    # В будущем здесь будет логика для создания динамической библиотеки
    # set_target_properties(libmenu PROPERTIES TYPE SHARED_LIBRARY)
else()
    message(STATUS "Building libtmenu as STATIC library (current implementation)")
endif()

message(STATUS "Configured static library 'libtmenu'")
message(STATUS "  Type: STATIC (development version)")
message(STATUS "  PIC enabled: YES (for future shared library compatibility)")
message(STATUS "  Sources: ${CMAKE_CURRENT_SOURCE_DIR}/include/command.hpp")