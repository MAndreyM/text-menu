#!/bin/bash
set -e

echo "🧹 Cleaning up..."

docker-compose down -v

# Проверяем существование директорий перед удалением
if [ -d "build/" ]; then
    echo "Removing build directory..."
    sudo rm -rf build/ 2>/dev/null || rm -rf build/
fi

if [ -d "docs/output/" ]; then
    echo "Removing docs/output directory..."
    sudo rm -rf docs/output/
fi

docker system prune -f

echo "✅ Cleanup completed!"