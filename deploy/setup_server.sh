#!/bin/bash

# 🛡️ Script de Configuración del Servidor - Prevención Segura
# Ejecutar en el servidor después de crear el droplet

echo "🛡️ Configurando Servidor Prevención Segura..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
apt update && apt upgrade -y

# Instalar Node.js
echo "📦 Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Verificar instalación
echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"

# Instalar PM2
echo "📦 Instalando PM2..."
npm install -g pm2

# Instalar Nginx
echo "📦 Instalando Nginx..."
apt install nginx -y

# Crear usuario para la aplicación
echo "👤 Creando usuario de aplicación..."
useradd -m -s /bin/bash prevencion
usermod -aG sudo prevencion

# Crear directorio de la aplicación
echo "📁 Creando directorios..."
mkdir -p /home/prevencion/app
mkdir -p /home/prevencion/logs
mkdir -p /home/prevencion/uploads

# Configurar permisos
chown -R prevencion:prevencion /home/prevencion/

# Configurar firewall
echo "🔥 Configurando firewall..."
ufw allow ssh
ufw allow 80
ufw allow 443
ufw allow 3000
ufw --force enable

# Configurar Nginx
echo "🌐 Configurando Nginx..."
cat > /etc/nginx/sites-available/prevencion-segura << 'EOF'
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Habilitar sitio
ln -s /etc/nginx/sites-available/prevencion-segura /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Reiniciar Nginx
systemctl restart nginx
systemctl enable nginx

# Instalar Certbot para SSL
echo "🔒 Instalando Certbot para SSL..."
apt install certbot python3-certbot-nginx -y

echo "✅ Servidor configurado correctamente!"
echo "📝 Próximos pasos:"
echo "1. Subir archivos de la aplicación"
echo "2. Instalar dependencias: npm install"
echo "3. Iniciar con PM2: pm2 start server.js"
echo "4. Configurar dominio y SSL"
