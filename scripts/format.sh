#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎨 Formatting Code...${NC}"

# Получаем ID текущего пользователя и группы
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Форматирование исходного кода с сохранением прав
docker-compose run --rm --user "$USER_ID:$GROUP_ID" dev bash -c "
    echo 'Formatting C++ files...'
    find src/ tests/ -name '*.cpp' -o -name '*.h' | xargs clang-format -i -style=file
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Code formatted successfully!${NC}"
    
    # Показываем измененные файлы
    #echo -e "${YELLOW}📝 Formatted files:${NC}"
    #git diff --name-only || find src/ tests/ -name '*.cpp' -o -name '*.h'
    # Просто всегда показывать все файлы
    echo -e "${YELLOW}📝 Source files in project:${NC}"
    find src/ tests/ -name '*.cpp' -o -name '*.h'
else
    echo -e "${RED}❌ Code formatting failed${NC}"
    exit 1
fi