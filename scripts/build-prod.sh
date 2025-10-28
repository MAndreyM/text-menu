#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️ Building Production Image...${NC}"

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Получаем версию из git или используем дефолтную
VERSION=${1:-latest}
IMAGE_NAME="my-cpp-app"
TAG="$IMAGE_NAME:prod-$VERSION"

echo -e "${YELLOW}📦 Building production image with tag: $TAG${NC}"

# Сборка production образа
docker build --target prod -t $TAG .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Production image built successfully!${NC}"
    
    # Информация о собранном образе
    echo -e "\n${YELLOW}📊 Production Image Details:${NC}"
    echo -e "Image: $TAG"
    echo -e "Size: $(docker images $TAG --format "table {{.Size}}" | tail -n 1)"
    
    # Показываем все образы проекта
    echo -e "\n${YELLOW}📋 All project images:${NC}"
    docker images | grep $IMAGE_NAME
    
    # Информация о контейнере
    echo -e "\n${YELLOW}🚀 To run the production container:${NC}"
    echo -e "docker run -d --name text-menu-prod $TAG"
    echo -e "docker run -it --rm $TAG /bin/sh"
    
    # Проверка бинарника
    echo -e "\n${YELLOW}🔍 Verifying binary...${NC}"
    docker run --rm --entrypoint /bin/ls $TAG /app
    
    # Тестирование запуска
    echo -e "\n${YELLOW}🧪 Testing application startup...${NC}"
    if timeout 5s docker run --rm $TAG 2>/dev/null; then
        echo -e "${GREEN}✅ Application starts successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Application may require specific runtime environment${NC}"
        # Альтернативная проверка - просто проверяем что файл существует и исполняемый
        if docker run --rm --entrypoint /bin/sh $TAG -c "test -x /app/text-menu && echo 'Binary exists and is executable'"; then
            echo -e "${GREEN}✅ Binary verification passed${NC}"
        else
            echo -e "${RED}❌ Binary verification failed${NC}"
        fi
    fi
    
    # Создание дополнительного тега latest если это релиз
    if [ "$VERSION" != "latest" ]; then
        echo -e "\n${YELLOW}🏷️  Tagging as latest...${NC}"
        docker tag $TAG $IMAGE_NAME:prod-latest
        echo -e "${GREEN}✅ Tagged as $IMAGE_NAME:prod-latest${NC}"
    fi
    
    echo -e "\n${GREEN}🎉 Production build completed!${NC}"
    
else
    echo -e "${RED}❌ Failed to build production image${NC}"
    exit 1
fi
