#!/bin/bash

# Test script for GOSTsimbox Gateway Flutter App
set -e

echo "🧪 Running GOSTsimbox Gateway Tests"

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Run analysis
echo "🔍 Running Flutter analysis..."
flutter analyze

# Run unit tests
echo "🧪 Running unit tests..."
flutter test test/unit/

# Run widget tests
echo "🎨 Running widget tests..."
flutter test test/widgets/

# Run integration tests
echo "🔗 Running integration tests..."
flutter test test/integration/

# Run all tests with coverage
echo "📊 Running all tests with coverage..."
flutter test --coverage

# Generate coverage report
echo "📈 Generating coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "✅ All Flutter tests completed successfully!"
echo "📊 Coverage report available at: coverage/html/index.html"
