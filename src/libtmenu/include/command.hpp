/*
 * Copyright (C) 2025 Mamedov A. mam28.andr@yndex.ru
 * 
 * This file is part of text-menu.
 * 
 * text-menu is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * text-menu is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with text-menu. If not, see <https://www.gnu.org/licenses/>.
 */

#pragma once
#include <string>
#include <memory>

namespace tmenu {

/**
 * @brief Абстрактный базовый класс для всех команд меню
 * 
 * Данный класс определяет интерфейс для всех команд, которые могут быть
 * выполнены в системе меню. Каждая конкретная команда должна наследоваться
 * от этого класса и реализовывать все чисто виртуальные методы.
 */
class Command {
public:
    /**
     * @brief Виртуальный деструктор для обеспечения корректного удаления
     * объектов производных классов
     */
    virtual ~Command() = default;

    /**
     * @brief Выполняет команду
     * @return true усликоманда выполнена успешно,
     * false в противном случае
     * 
     * Этот метод должен быть реализован в производных классах и содержать
     * основную логику выполнения команды.
     */
    virtual bool execute() = 0;

    /**
     * @brief Возвращает название команды
     * @return Строка с названием команды
     * 
     * Название команды используется для отображения в меню и должно быть
     * кратким и понятным для пользователя.
     */
    virtual std::string name() const = 0;

    /**
     * @brief Возвращает описание команды
     * @return Строка с описанием команды
     * 
     * Описание команды предоставляет дополнительную информацию о том,
     * что делает команда, и может отображаться в справке или подсказках.
     */
    virtual std::string description() const = 0;
    
};  // class Command

}   // namespace tmenu