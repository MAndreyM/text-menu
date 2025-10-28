#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Building Development Environment...${NC}"

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

# Сборка development образа
echo -e "${YELLOW}📦 Building development image...${NC}"
docker-compose build dev

# Проверка успешности сборки
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Development image built successfully!${NC}"
    
    # Показываем информацию о образе
    echo -e "${YELLOW}📊 Image information:${NC}"
    docker images | head -1
    docker images | grep $(basename "$PWD") | grep dev
    
    echo -e "\n${GREEN}🚀 Starting Development Container...${NC}"
    echo -e "${YELLOW}💡 Use 'exit' to leave the container when done${NC}"
    echo -e "${YELLOW}💡 Project files are mounted at /project${NC}"
    echo -e "${YELLOW}💡 Available commands:${NC}"
    echo -e "   - ninja build    # Build the project"
    echo -e "   - ninja test     # Run tests"
    echo -e "   - ninja docs     # Generate documentation"
    echo -e "${BLUE}================================${NC}"
    
    # Запуск контейнера
    docker-compose run --rm dev
else
    echo -e "${RED}❌ Failed to build development image${NC}"
    exit 1
fi
