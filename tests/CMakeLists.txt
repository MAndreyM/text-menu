# Настройка тестов с doctest
if(USE_DOCTEST AND DOCTEST_INCLUDE_DIR)

    # Исполняемый файл тестов
    add_executable(test_runner 
        test_main.cpp 
    )

    # Подключаем doctest
    target_include_directories(test_runner PRIVATE ${DOCTEST_INCLUDE_DIR})
    
    # Линковка с основным проектом
#    target_link_libraries(test_runner myapp)

    # Настройка компиляции
    target_compile_definitions(test_runner PRIVATE DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN)
    
    # Добавляем тест в CTest
    add_test(NAME UnitTests COMMAND test_runner)
    
    # Дополнительные опции для doctest
    target_compile_definitions(test_runner PRIVATE 
        DOCTEST_CONFIG_NO_UNPREFIXED_OPTIONS
        DOCTEST_CONFIG_COLORS_ANSI
    )

else()
    message(WARNING "doctest not available - tests will not be built")
endif()

# Дополнительная цель для запуска тестов с подробным выводом
add_custom_target(test_verbose
    COMMAND ./test_runner --success --no-version --no-help
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS test_runner
    COMMENT "Running tests with verbose output"
)


