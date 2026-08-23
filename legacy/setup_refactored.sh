#!/bin/bash

# Скрипт настройки рефакторенного gost_simbox_android
# От прототипа до MVP

echo "🚀 Настройка рефакторенного gost_simbox_android..."

# Проверка наличия Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не найден. Установите Flutter SDK."
    exit 1
fi

# Проверка версии Flutter
FLUTTER_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | head -1)
echo "📱 Найдена версия: $FLUTTER_VERSION"

# Очистка предыдущих сборок
echo "🧹 Очистка предыдущих сборок..."
flutter clean

# Получение зависимостей
echo "📦 Установка зависимостей..."
flutter pub get

# Проверка зависимостей
echo "🔍 Проверка зависимостей..."
flutter pub deps

# Генерация локализации
echo "🌍 Генерация локализации..."
flutter gen-l10n

# Проверка анализа кода
echo "🔍 Анализ кода..."
flutter analyze

# Сборка для Android
echo "📱 Сборка для Android..."
flutter build apk --debug

echo "✅ Настройка завершена!"
echo ""
echo "📋 Что было сделано:"
echo "  • Очистка предыдущих сборок"
echo "  • Установка зависимостей (включая flutter_tele)"
echo "  • Генерация локализации"
echo "  • Анализ кода"
echo "  • Сборка debug APK"
echo ""
echo "🎯 Следующие шаги:"
echo "  1. Установите APK на устройство: flutter install"
echo "  2. Запустите приложение: flutter run"
echo "  3. Протестируйте функциональность"
echo ""
echo "📚 Документация: README_REFACTORING.md" 