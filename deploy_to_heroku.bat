@echo off
echo 🚀 Desplegando Prevención Segura a Heroku...
echo.

REM Verificar si Heroku CLI está instalado
heroku --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Heroku CLI no está instalado
    echo 📥 Descarga Heroku CLI desde: https://devcenter.heroku.com/articles/heroku-cli
    pause
    exit /b 1
)

echo ✅ Heroku CLI está instalado
echo.

REM Verificar si Git está instalado
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git no está instalado
    echo 📥 Descarga Git desde: https://git-scm.com/
    pause
    exit /b 1
)

echo ✅ Git está instalado
echo.

REM Navegar a la carpeta del servidor
cd server

REM Inicializar Git si no existe
if not exist ".git" (
    echo 📁 Inicializando repositorio Git...
    git init
    git add .
    git commit -m "Initial commit - Prevención Segura Server"
)

REM Crear aplicación en Heroku
echo 🆕 Creando aplicación en Heroku...
set /p APP_NAME="Ingresa el nombre de tu app (ej: prevencion-segura-2024): "
heroku create %APP_NAME%

REM Configurar variables de entorno
echo ⚙️ Configurando variables de entorno...
heroku config:set NODE_ENV=production

REM Desplegar
echo 🚀 Desplegando a Heroku...
git add .
git commit -m "Deploy to Heroku"
git push heroku main

REM Abrir la aplicación
echo 🌐 Abriendo aplicación...
heroku open

echo.
echo ✅ ¡Despliegue completado!
echo 📱 Tu servidor está disponible en: https://%APP_NAME%.herokuapp.com
echo 📊 Estado: https://%APP_NAME%.herokuapp.com/api/status
echo.
echo 📝 Próximos pasos:
echo 1. Actualiza la URL en tu app Flutter
echo 2. Configura el dominio personalizado (opcional)
echo 3. Configura SSL (automático en Heroku)
echo.

pause
