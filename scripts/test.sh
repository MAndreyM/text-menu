#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Running Tests...${NC}"

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Проверка наличия docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose is not installed. Please install docker-compose first.${NC}"
    exit 1
fi

# Функция для вывода заголовка
print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Функция для проверки успешности выполнения
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1${NC}"
        return 1
    fi
}

print_header "1. Building Test Environment"
docker-compose build test
check_success "Test environment built"

print_header "2. Running Unit Tests with doctest"
if docker-compose run --rm test; then
    echo -e "${GREEN}✅ All unit tests passed!${NC}"
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi

print_header "3. Additional Test Scenarios"

# Тест с различными опциями doctest
echo -e "${YELLOW}📋 Running tests with different options...${NC}"

# Тест с подробным выводом
echo -e "\n${YELLOW}🔍 Detailed test output:${NC}"
docker-compose run --rm test bash -c "
    cd build && ./tests/test_runner --success --no-version --no-help
"
check_success "Detailed tests completed"

# Тест с подсветкой
echo -e "\n${YELLOW}🎨 Tests with colors:${NC}"
docker-compose run --rm test bash -c "
    cd build && ./tests/test_runner --force-colors
 "
check_success "Colorized tests completed"

# Проверка сборки в Release режиме
print_header "4. Testing Release Build"
docker-compose run --rm test bash -c "
    mkdir -p build_release &&
    cd build_release &&
    cmake -G Ninja .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=ON &&
    ninja &&
    ./tests/test_runner --success
"
check_success "Release build tests passed"

# Статический анализ кода (если доступен)
print_header "5. Static Code Analysis"
if docker-compose run --rm dev bash -c "command -v clang-tidy >/dev/null 2>&1"; then
    echo -e "${YELLOW}🔍 Running Static Code Analysis...${NC}"
    
    # Анализ основной библиотеки
    echo -e "${YELLOW}📁 Analyzing libtmenu...${NC}"
    if docker-compose run --rm dev bash -c "
        cd /project && \
        clang-tidy src/libtmenu/include/command.hpp -- -Isrc/libtmenu/include && \
        clang-tidy src/libtmenu/command.cpp -- -Isrc/libtmenu/include
    "; then
        echo -e "${GREEN}✅ libtmenu analysis completed${NC}"
    else
        echo -e "${YELLOW}⚠️  libtmenu analysis completed with warnings${NC}"
    fi
    
    # Анализ примера
    echo -e "${YELLOW}📁 Analyzing example...${NC}"
    if docker-compose run --rm dev bash -c "
        cd /project && \
        clang-tidy src/example/include/example.hpp -- -Isrc/libtmenu/include -Isrc/example/include && \
        clang-tidy src/example/example.cpp -- -Isrc/libtmenu/include -Isrc/example/include
    "; then
        echo -e "${GREEN}✅ example analysis completed${NC}"
    else
        echo -e "${YELLOW}⚠️  example analysis completed with warnings${NC}"
    fi
    
    # Анализ главного файла
    echo -e "${YELLOW}📁 Analyzing main...${NC}"
    if docker-compose run --rm dev bash -c "
        cd /project && \
        clang-tidy src/main.cpp -- -Isrc/example/include
    "; then
        echo -e "${GREEN}✅ main analysis completed${NC}"
    else
        echo -e "${YELLOW}⚠️  main analysis completed with warnings${NC}"
    fi
    
    echo -e "${GREEN}✅ Static analysis completed!${NC}"
else
    echo -e "${YELLOW}⚠️  clang-tidy not available, skipping static analysis${NC}"
fi

# Проверка размера бинарника
print_header "6. Binary Size Check"
docker-compose run --rm test bash -c "
    echo 'Debug binary size:'
    if [ -f build/myapp ]; then
        ls -lh build/myapp | awk '{print \$5}'
    else
        echo 'Debug binary not found'
    fi
    echo -e '\nRelease binary size:'
    if [ -f build_release/myapp ]; then
        ls -lh build_release/myapp | awk '{print \$5}'
    else
        echo 'Release binary not found'
    fi
"

# Финальный отчет
print_header "🎉 TEST SUMMARY"
echo -e "${GREEN}✅ All tests completed successfully!${NC}"
echo -e "${YELLOW}📊 Next steps:${NC}"
echo -e "   - Run './scripts/build-prod.sh' to create production image"
echo -e "   - Run './scripts/docs.sh' to generate documentation"
echo -e "   - Use 'make dev' for development environment"

echo -e "\n${GREEN}🚀 Ready for production!${NC}"