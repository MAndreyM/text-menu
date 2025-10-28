#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 Generating Documentation...${NC}"

# Проверка наличия необходимых файлов
if [ ! -f "docs/Doxyfile" ]; then
    echo -e "${YELLOW}⚠️  Doxyfile not found, creating default...${NC}"
    mkdir -p docs
    docker-compose run --rm dev bash -c "doxygen -g /project/docs/Doxyfile"
fi

# Генерация документации
docker-compose run --rm docs

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Documentation generated successfully!${NC}"
    echo -e "${YELLOW}📁 Output location: docs/output/html/${NC}"
    echo -e "${YELLOW}🌐 Open docs/output/html/index.html in your browser${NC}"
    
    # Проверка существования index.html
    if [ -f "docs/output/html/index.html" ]; then
        echo -e "${GREEN}📄 Main documentation file: docs/output/html/index.html${NC}"
    fi
else
    echo -e "${RED}❌ Failed to generate documentation${NC}"
    exit 1
fi
