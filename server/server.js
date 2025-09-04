const express = require('express');
const cors = require('cors');
const multer = require('multer');
const fs = require('fs-extra');
const path = require('path');
const moment = require('moment');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Configurar multer para archivos
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads/evidence';
    fs.ensureDirSync(uploadDir);
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const timestamp = moment().format('YYYY-MM-DD_HH-mm-ss');
    const filename = `${timestamp}_${file.originalname}`;
    cb(null, filename);
  }
});

const upload = multer({ storage: storage });

// Crear directorios necesarios
fs.ensureDirSync('uploads/evidence');
fs.ensureDirSync('data');

// Endpoint para datos de emergencia
app.post('/api/emergency', (req, res) => {
  try {
    const { userId, type, location, message, timestamp, encrypted } = req.body;
    
    console.log('🚨 ALERTA SOS RECIBIDA:');
    console.log(`Usuario: ${userId}`);
    console.log(`Ubicación: ${location}`);
    console.log(`Mensaje: ${message}`);
    console.log(`Timestamp: ${timestamp}`);
    console.log(`Encriptado: ${encrypted}`);
    
    // Guardar en archivo de log
    const logData = {
      timestamp: new Date().toISOString(),
      type: 'emergency',
      userId,
      location,
      message,
      encrypted
    };
    
    const logFile = `data/emergency_${moment().format('YYYY-MM-DD')}.json`;
    let logs = [];
    
    if (fs.existsSync(logFile)) {
      logs = JSON.parse(fs.readFileSync(logFile, 'utf8'));
    }
    
    logs.push(logData);
    fs.writeFileSync(logFile, JSON.stringify(logs, null, 2));
    
    res.json({
      success: true,
      message: 'Alerta SOS recibida y procesada',
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Error procesando alerta SOS:', error);
    res.status(500).json({
      success: false,
      message: 'Error procesando alerta SOS',
      error: error.message
    });
  }
});

// Endpoint para actualizaciones de ubicación
app.post('/api/location', (req, res) => {
  try {
    const { userId, type, location, latitude, longitude, timestamp, encrypted } = req.body;
    
    console.log('📍 Ubicación actualizada:');
    console.log(`Usuario: ${userId}`);
    console.log(`Coordenadas: ${latitude}, ${longitude}`);
    console.log(`Ubicación: ${location}`);
    
    // Guardar en archivo de log
    const logData = {
      timestamp: new Date().toISOString(),
      type: 'location_update',
      userId,
      location,
      latitude,
      longitude,
      encrypted
    };
    
    const logFile = `data/location_${moment().format('YYYY-MM-DD')}.json`;
    let logs = [];
    
    if (fs.existsSync(logFile)) {
      logs = JSON.parse(fs.readFileSync(logFile, 'utf8'));
    }
    
    logs.push(logData);
    fs.writeFileSync(logFile, JSON.stringify(logs, null, 2));
    
    res.json({
      success: true,
      message: 'Ubicación actualizada',
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Error procesando ubicación:', error);
    res.status(500).json({
      success: false,
      message: 'Error procesando ubicación',
      error: error.message
    });
  }
});

// Endpoint para archivos de evidencia
app.post('/api/evidence', upload.single('file'), (req, res) => {
  try {
    const { userId, type, fileType, fileName, timestamp, encrypted } = req.body;
    
    console.log('📁 Archivo de evidencia recibido:');
    console.log(`Usuario: ${userId}`);
    console.log(`Tipo: ${fileType}`);
    console.log(`Archivo: ${fileName}`);
    
    // Guardar información del archivo
    const fileData = {
      timestamp: new Date().toISOString(),
      type: 'evidence',
      userId,
      fileType,
      originalName: fileName,
      savedName: req.file ? req.file.filename : null,
      path: req.file ? req.file.path : null,
      size: req.file ? req.file.size : 0,
      encrypted
    };
    
    const logFile = `data/evidence_${moment().format('YYYY-MM-DD')}.json`;
    let logs = [];
    
    if (fs.existsSync(logFile)) {
      logs = JSON.parse(fs.readFileSync(logFile, 'utf8'));
    }
    
    logs.push(fileData);
    fs.writeFileSync(logFile, JSON.stringify(logs, null, 2));
    
    res.json({
      success: true,
      message: 'Archivo de evidencia recibido',
      fileId: req.file ? req.file.filename : null,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Error procesando archivo de evidencia:', error);
    res.status(500).json({
      success: false,
      message: 'Error procesando archivo de evidencia',
      error: error.message
    });
  }
});

// Endpoint para progreso educativo
app.post('/api/education', (req, res) => {
  try {
    const { userId, type, lessonName, score, timestamp, encrypted } = req.body;
    
    console.log('📚 Progreso educativo:');
    console.log(`Usuario: ${userId}`);
    console.log(`Lección: ${lessonName}`);
    console.log(`Puntuación: ${score}`);
    
    // Guardar en archivo de log
    const logData = {
      timestamp: new Date().toISOString(),
      type: 'education_progress',
      userId,
      lessonName,
      score,
      encrypted
    };
    
    const logFile = `data/education_${moment().format('YYYY-MM-DD')}.json`;
    let logs = [];
    
    if (fs.existsSync(logFile)) {
      logs = JSON.parse(fs.readFileSync(logFile, 'utf8'));
    }
    
    logs.push(logData);
    fs.writeFileSync(logFile, JSON.stringify(logs, null, 2));
    
    res.json({
      success: true,
      message: 'Progreso educativo guardado',
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Error procesando progreso educativo:', error);
    res.status(500).json({
      success: false,
      message: 'Error procesando progreso educativo',
      error: error.message
    });
  }
});

// Endpoint para datos en lote
app.post('/api/batch', (req, res) => {
  try {
    const batchData = req.body;
    
    console.log('📦 Datos en lote recibidos:', batchData.length);
    
    // Procesar cada elemento del lote
    batchData.forEach((data, index) => {
      console.log(`Procesando elemento ${index + 1}:`, data.type);
    });
    
    res.json({
      success: true,
      message: `Lote de ${batchData.length} elementos procesado`,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Error procesando datos en lote:', error);
    res.status(500).json({
      success: false,
      message: 'Error procesando datos en lote',
      error: error.message
    });
  }
});

// Endpoint de estado del servidor
app.get('/api/status', (req, res) => {
  res.json({
    status: 'online',
    message: 'Servidor Prevención Segura funcionando',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Endpoint para obtener estado de emergencia (para la página web)
app.get('/api/emergency/status', (req, res) => {
  try {
    const today = moment().format('YYYY-MM-DD');
    const emergencyFile = `data/emergency_${today}.json`;
    const locationFile = `data/location_${today}.json`;
    
    let emergencyData = null;
    let locationData = null;
    let stats = {
      alertsToday: 0,
      totalAlerts: 0
    };

    // Leer datos de emergencia del día
    if (fs.existsSync(emergencyFile)) {
      const emergencies = JSON.parse(fs.readFileSync(emergencyFile, 'utf8'));
      if (emergencies.length > 0) {
        // Obtener la última emergencia activa
        emergencyData = emergencies[emergencies.length - 1];
        stats.alertsToday = emergencies.length;
      }
    }

    // Leer datos de ubicación del día
    if (fs.existsSync(locationFile)) {
      const locations = JSON.parse(fs.readFileSync(locationFile, 'utf8'));
      if (locations.length > 0) {
        // Obtener la última ubicación
        locationData = locations[locations.length - 1];
      }
    }

    // Calcular estadísticas totales
    const dataDir = 'data';
    if (fs.existsSync(dataDir)) {
      const files = fs.readdirSync(dataDir);
      const emergencyFiles = files.filter(file => file.startsWith('emergency_'));
      emergencyFiles.forEach(file => {
        const filePath = path.join(dataDir, file);
        const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        stats.totalAlerts += data.length;
      });
    }

    // Determinar si hay una alerta activa
    const isActive = emergencyData && 
      moment().diff(moment(emergencyData.timestamp), 'minutes') < 60; // Activa por 1 hora

    const responseData = {
      isActive,
      alert: isActive ? {
        isActive: true,
        startTime: emergencyData.timestamp,
        threatType: emergencyData.message?.split(':')[0] || 'Emergencia',
        description: emergencyData.message || 'Alerta SOS activada'
      } : null,
      location: locationData ? {
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        accuracy: locationData.accuracy || 0,
        speed: locationData.speed || 0,
        timestamp: locationData.timestamp
      } : null,
      device: {
        id: emergencyData?.userId || 'unknown',
        model: 'Android Device',
        version: '1.0.0'
      },
      stats
    };

    res.json({
      success: true,
      data: responseData
    });

  } catch (error) {
    console.error('Error obteniendo estado de emergencia:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo estado de emergencia',
      error: error.message
    });
  }
});

// Ruta principal para servir la página web
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Endpoint para obtener logs
app.get('/api/logs/:type/:date', (req, res) => {
  try {
    const { type, date } = req.params;
    const logFile = `data/${type}_${date}.json`;
    
    if (fs.existsSync(logFile)) {
      const logs = JSON.parse(fs.readFileSync(logFile, 'utf8'));
      res.json({
        success: true,
        data: logs,
        count: logs.length
      });
    } else {
      res.json({
        success: true,
        data: [],
        count: 0,
        message: 'No hay logs para esta fecha'
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error obteniendo logs',
      error: error.message
    });
  }
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log('🛡️ Servidor Prevención Segura iniciado');
  console.log(`🌐 Servidor corriendo en puerto ${PORT}`);
  console.log(`📊 Estado: http://localhost:${PORT}/api/status`);
  console.log('📁 Logs guardados en: ./data/');
  console.log('📁 Archivos guardados en: ./uploads/');
});
