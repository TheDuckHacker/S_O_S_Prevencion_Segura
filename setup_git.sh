#!/bin/bash

# 🚀 Script de Configuración para GitHub - Prevención Segura
# Este script configura el repositorio Git y prepara el proyecto para GitHub

echo "🛡️ Configurando Prevención Segura para GitHub..."

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

# Inicializar Git si no existe
if [ ! -d ".git" ]; then
    echo "📁 Inicializando repositorio Git..."
    git init
fi

# Configurar Git (reemplaza con tu información)
echo "⚙️ Configurando Git..."
read -p "Ingresa tu nombre de usuario de Git: " git_username
read -p "Ingresa tu email de Git: " git_email

git config user.name "$git_username"
git config user.email "$git_email"

# Agregar todos los archivos
echo "📦 Agregando archivos al repositorio..."
git add .

# Commit inicial
echo "💾 Creando commit inicial..."
git commit -m "feat: implementación inicial de Prevención Segura

- Sistema SOS con ubicación en tiempo real
- Módulo educativo interactivo
- Simulador de escenarios de riesgo
- Pantalla de historial de alertas
- Mapa de ubicación
- Grabación de evidencia
- Diseño moderno con paleta de colores personalizada
- Tipografía Poppins para mejor legibilidad
- Animaciones suaves y transiciones
- Arquitectura con Provider para gestión de estado"

# Crear rama develop
echo "🌿 Creando rama develop..."
git checkout -b develop

# Volver a main
git checkout main

echo "✅ Configuración completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Crea un repositorio en GitHub: https://github.com/new"
echo "2. Agrega el remote origin:"
echo "   git remote add origin https://github.com/TU-USUARIO/prevencion-segura.git"
echo "3. Push al repositorio:"
echo "   git push -u origin main"
echo "4. Push la rama develop:"
echo "   git push -u origin develop"
echo ""
echo "🎉 ¡Tu proyecto está listo para GitHub!"
