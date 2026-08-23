#!/bin/bash

# Скрипт для замены GoogleFonts.poppins на AppTextStyles.poppins

echo "Заменяю GoogleFonts.poppins на AppTextStyles.poppins..."

# Заменяем импорты
find lib -name "*.dart" -exec sed -i '' 's/import '\''package:google_fonts\/google_fonts.dart'\'';/import '\''..\/utils\/text_styles.dart'\'';/g' {} \;

# Заменяем GoogleFonts.poppins на AppTextStyles.poppins
find lib -name "*.dart" -exec sed -i '' 's/GoogleFonts\.poppins(/AppTextStyles.poppins(/g' {} \;

# Заменяем GoogleFonts.poppins с fontWeight на соответствующие методы
find lib -name "*.dart" -exec sed -i '' 's/AppTextStyles\.poppins([^)]*fontWeight: FontWeight\.bold[^)]*)/AppTextStyles.poppinsBold(/g' {} \;
find lib -name "*.dart" -exec sed -i '' 's/AppTextStyles\.poppins([^)]*fontWeight: FontWeight\.w600[^)]*)/AppTextStyles.poppinsSemiBold(/g' {} \;
find lib -name "*.dart" -exec sed -i '' 's/AppTextStyles\.poppins([^)]*fontWeight: FontWeight\.w500[^)]*)/AppTextStyles.poppinsMedium(/g' {} \;

echo "Замена завершена!" 