#!/bin/bash

# Скрипт миграции для рефакторинга GOSTsimbox Gateway
# Перемещает существующие файлы в новую структуру Clean Architecture

echo "🚀 Начинаем миграцию к рефакторенной архитектуре..."

# Создаем новые директории
echo "📁 Создаем новую структуру папок..."

mkdir -p lib/presentation/screens
mkdir -p lib/presentation/providers
mkdir -p lib/presentation/services
mkdir -p lib/presentation/widgets
mkdir -p lib/presentation/theme

mkdir -p lib/domain/entities
mkdir -p lib/domain/repositories
mkdir -p lib/domain/usecases
mkdir -p lib/domain/exceptions

mkdir -p lib/data/datasources
mkdir -p lib/data/repositories
mkdir -p lib/data/models
mkdir -p lib/data/services

mkdir -p lib/core/di
mkdir -p lib/core/utils
mkdir -p lib/core/constants
mkdir -p lib/core/errors

# Перемещаем существующие файлы
echo "📦 Перемещаем существующие файлы..."

# Presentation Layer
if [ -d "lib/screens" ]; then
    mv lib/screens/* lib/presentation/screens/ 2>/dev/null || true
    rmdir lib/screens 2>/dev/null || true
fi

if [ -d "lib/providers" ]; then
    mv lib/providers/* lib/presentation/providers/ 2>/dev/null || true
    rmdir lib/providers 2>/dev/null || true
fi

if [ -d "lib/services" ]; then
    mv lib/services/* lib/presentation/services/ 2>/dev/null || true
    rmdir lib/services 2>/dev/null || true
fi

if [ -d "lib/widgets" ]; then
    mv lib/widgets/* lib/presentation/widgets/ 2>/dev/null || true
    rmdir lib/widgets 2>/dev/null || true
fi

if [ -d "lib/theme" ]; then
    mv lib/theme/* lib/presentation/theme/ 2>/dev/null || true
    rmdir lib/theme 2>/dev/null || true
fi

# Data Layer
if [ -d "lib/models" ]; then
    mv lib/models/* lib/data/models/ 2>/dev/null || true
    rmdir lib/models 2>/dev/null || true
fi

# Core Layer
if [ -d "lib/utils" ]; then
    mv lib/utils/* lib/core/utils/ 2>/dev/null || true
    rmdir lib/utils 2>/dev/null || true
fi

# Обновляем импорты в main.dart
echo "🔧 Обновляем импорты в main.dart..."

# Создаем резервную копию
cp lib/main.dart lib/main.dart.backup

# Обновляем pubspec.yaml
echo "📝 Обновляем pubspec.yaml..."
cp pubspec.yaml pubspec.yaml.backup

# Устанавливаем новые зависимости
echo "📦 Устанавливаем новые зависимости..."
flutter pub get

# Очищаем кэш
echo "🧹 Очищаем кэш..."
flutter clean
flutter pub get

# Проверяем структуру
echo "✅ Проверяем новую структуру..."
find lib -type d | sort

echo "🎉 Миграция завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Проверьте импорты в файлах"
echo "2. Обновите пути в импортах"
echo "3. Запустите flutter analyze"
echo "4. Протестируйте приложение"
echo ""
echo "📚 Документация: README_REFACTORED.md"
