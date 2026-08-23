#!/bin/bash

echo "Сборка Android APK для gost_simbox..."

# Проверяем наличие Flutter
if ! command -v flutter &> /dev/null; then
    echo "Ошибка: Flutter не найден"
    exit 1
fi

# Очищаем предыдущую сборку
flutter clean

# Получаем зависимости
flutter pub get

# Собираем APK
if flutter build apk; then
    echo "APK успешно собран: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "Ошибка при сборке APK"
    exit 1
fi

# Опционально: собираем App Bundle (раскомментируйте при необходимости)
# if flutter build appbundle; then
#     echo "App Bundle успешно собран: build/app/outputs/bundle/release/app-release.aab"
# else
#     echo "Ошибка при сборке App Bundle"
#     exit 1
# fi
