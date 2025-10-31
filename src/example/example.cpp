#include "include/example.hpp"

namespace example {

// Демонстрация работы с командами
void demoCommands() {
    using std::cout;
    using std::endl;

    cout << "=== Демонстрация системы команд ===" << endl;

    // Создаем команды
    NewFileCommand newFileCmd("example.txt");
    ExitCommand exitCmd;

    // Демонстрируем информацию о командах
    cout << "Доступные команды:" << endl;
    cout << "1. " << newFileCmd.name()
         << " - " << newFileCmd.description()
         << endl;
    cout << "2. " << exitCmd.name()
         << " - " << exitCmd.description()
         << endl;
    cout << endl;

    // Выполняем команды
    cout << "Выполнение команд:" << endl;
    newFileCmd.execute();
    exitCmd.execute();

    cout << "=== Демонстрация завершина ===" << endl;
}   // demoCommands()

}   // namespace example