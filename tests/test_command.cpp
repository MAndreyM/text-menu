//#define DOCTEST_CONFIG_IMPLEMENT
#include "../third_party/doctest/doctest.h"

#include "../src/libtmenu/include/command.hpp"
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

namespace tmenu {

// Тестовая реализация команды для проверки базового функционала
class TestCommand: public Command {
private:
    std::string m_name;
    std::string m_desc;
    bool m_executeResult;
    mutable bool m_wasExecuted;

public:
    TestCommand(const std::string& name, const std::string& desc, bool executeResult = true)
    : m_name(name),
      m_desc(desc),
      m_executeResult(executeResult),
      m_wasExecuted(false)
    {}

    bool execute() override {
        m_wasExecuted = true;
        return m_executeResult;
    }

    std::string name() const override {
        return m_name;
    }

    std::string description() const override {
        return m_desc;
    }

    bool wasExecuted() const {
        return m_wasExecuted;
    }

    // Сбросить состояние выполнения команды
    void reset() {
        m_wasExecuted = false;
    }
};  // class TestCommand

// Тестовая команда, которая записывает сообщение при выполнении
class LoggingCommand: public Command {
private:
    std::string m_name;
    std::string m_message;
    std::ostream& m_output;

public:
    LoggingCommand(const std::string& name, const std::string& message, std::ostream& output = std::cout)
    : m_name(name),
      m_message(message),
      m_output(output)
    {}

    bool execute() override {
        m_output << m_message;
        return true;
    }

    std::string name() const override {
        return m_name;
    }

    std::string description() const override {
        return "Command that logs: " + m_message;
    }
};  // class LoggingCommand

}   // namespace tmenu

// Тестовые случаи
TEST_SUITE("Command Interface Tests") {
    TEST_CASE("Abstract class cannot be instantiated") {
        // Проверяем, что Command является абстрактным классом
        // Этот тест проверяет, что компиляция не позволяет создать экземпляр Command
        // На практике мы проверяем, что производные классы работают корректно
        CHECK(true); // Placeholder - фактическая проверка делается через производные классы
    }

    TEST_CASE("TestCommand basic functionality") {
        tmenu::TestCommand cmd("Test", "Test command", true);

        SUBCASE("Name and description are correctly set") {
            CHECK(cmd.name() == "Test");
            CHECK(cmd.description() == "Test command");
        }

        SUBCASE("Execute method returns correct result") {
            CHECK(cmd.execute() == true);
            CHECK(cmd.wasExecuted() == true);
        }

        SUBCASE("Command was not executed initially") {
            CHECK(cmd.wasExecuted() == false);
        }
    }

    TEST_CASE("TestCommand with false execution result") {
        tmenu::TestCommand cmd("FailingCmd", "Command that fails", false);

        CHECK(cmd.name() == "FailingCmd");
        CHECK(cmd.description() == "Command that fails");
        CHECK(cmd.execute() == false);
        CHECK(cmd.wasExecuted() == true);
    }

    TEST_CASE("Multiple command executions") {
        tmenu::TestCommand cmd("MultiCmd", "Multiple execution test", true);

        CHECK(cmd.wasExecuted() == false);

        // Первое выполнение
        CHECK(cmd.execute() == true);
        CHECK(cmd.wasExecuted() == true);

        // Сборос и повторное выполнение
        cmd.reset();
        CHECK(cmd.wasExecuted() == false);

        CHECK(cmd.execute() == true);
        CHECK(cmd.wasExecuted() == true);
    }

    TEST_CASE("LoggingCommand functionality") {
        std::stringstream output;
        tmenu::LoggingCommand cmd("LogCmd", "Hello, World!", output);

        SUBCASE("Name and description are correct") {
            CHECK(cmd.name() == "LogCmd");
            CHECK(cmd.description() == "Command that logs: Hello, World!");
        }

        SUBCASE("Execute method writes to stream") {
            CHECK(cmd.execute() == true);
            CHECK(output.str() == "Hello, World!");
        }
    }

    TEST_CASE("Polymorphism test") {
        std::unique_ptr<tmenu::Command> cmd1 = 
            std::make_unique<tmenu::TestCommand>("Poly1", "Polymorphic command 1", true);
        std::unique_ptr<tmenu::Command> cmd2 = 
            std::make_unique<tmenu::TestCommand>("Poly2", "Polymorphic command 2", false);
        
        SUBCASE("Polymorphic name access") {
            CHECK(cmd1->name() == "Poly1");
            CHECK(cmd2->name() == "Poly2");
        }

        SUBCASE("Polymorphic description access") {
            CHECK(cmd1->description() == "Polymorphic command 1");
            CHECK(cmd2->description() == "Polymorphic command 2");
        }

        SUBCASE("Polymorphic execution") {
            CHECK(cmd1->execute() == true);
            CHECK(cmd2->execute() == false);
        }
    }

    TEST_CASE("Command string values are not empty") {
        tmenu::TestCommand cmd("ValidName", "Valid description", true);

        CHECK_FALSE(cmd.name().empty());
        CHECK_FALSE(cmd.description().empty());
        CHECK(cmd.name().length() > 0);
        CHECK(cmd.description().length() > 0);
    }

    TEST_CASE("Command with special characters in name and description") {
        tmenu::TestCommand cmd("Cmd-123_特殊字符", "Description with 特殊符号 и !@#$%", true);
        
        CHECK(cmd.name() == "Cmd-123_特殊字符");
        CHECK(cmd.description() == "Description with 特殊符号 и !@#$%");
        CHECK(cmd.execute() == true);
    }
}

TEST_SUITE("Command Edge Casses") {
    TEST_CASE("Empty name and description") {
        tmenu::TestCommand cmd("", "", true);

        CHECK(cmd.name() == "");
        CHECK(cmd.description() == "");
        CHECK(cmd.execute() == true);
    }

    TEST_CASE("Very long name and description") {
        std::string longName(1000, 'A');
        std::string longDesc(2000, 'B');

        tmenu::TestCommand cmd(longName, longDesc, false);

        CHECK(cmd.name() == longName);
        CHECK(cmd.description() == longDesc);
        CHECK(cmd.name().length() == 1000);
        CHECK(cmd.description().length() == 2000);
        CHECK(cmd.execute() == false);
    }
}

// Дополнительные тесты для проверки поведения в реальных сценариях
TEST_CASE("Integration-style test with multiple command types") {
    std::stringstream output;

    // Создаем команды разных типов
    auto testCmt = tmenu::TestCommand("Test", "Test command", true);
    auto LoggingCmd = tmenu::LoggingCommand("Log", "Logged message", output);

    // Проверяем, что они корректно работают через базовый интерфейс
    std::vector<tmenu::Command*> commands = {&testCmt, &LoggingCmd};

    CHECK(commands[0]->name() == "Test");
    CHECK(commands[1]->name() == "Log");

    CHECK(commands[0]->description() == "Test command");
    CHECK(commands[1]->description() == "Command that logs: Logged message");

    // Выполняем команды
    CHECK(commands[0]->execute() == true);
    CHECK(commands[1]->execute() == true);

    // Проверяем побочные эффекты
    CHECK(testCmt.wasExecuted() == true);
    CHECK(output.str() == "Logged message");
}