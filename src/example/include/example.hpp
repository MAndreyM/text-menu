// Классы реальных команд для демострации работы
// абстрактного класса Command

#pragma once
#include "../../libtmenu/include/command.hpp"
#include <iostream>
#include <string>

namespace example {

// Команда создания нового файла
class NewFileCommand: public tmenu::Command {
private:
    std::string filename_;

public:
    explicit NewFileCommand(const std::string& filename = "new_file.txt")
        : filename_(filename) {}
    
    bool execute() override {
        using std::cout;
        using std::endl;

        cout << "Создание нового файла: " << filename_ << endl;

        // Здесь должна быть реальная логика создания нового файла

        cout << "Файл " << filename_ << " успешно создан!" << endl;

        return true;
    }

    std::string name() const override {
        return "new_file";
    }

    std::string description() const override {
        return "Создает файл с казанным именем";
    }
};  // class NewFileCommand

// Команда выхода из приложения
class ExitCommand: public tmenu::Command {
public:
    bool execute() override {
        std::cout << "Выход из приложения..." << std::endl;
        return true;
    }

    std::string name() const override {
        return "exit";
    }

    std::string description() const override {
        return "Завершает работу приложения";
    }
};  // class ExitCommand

void demoCommands();

}   // namespace example