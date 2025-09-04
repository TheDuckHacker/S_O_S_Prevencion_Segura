# 🤝 Guía de Contribución - Prevención Segura

¡Gracias por tu interés en contribuir a **Prevención Segura**! Esta guía te ayudará a entender cómo puedes participar en el desarrollo de esta aplicación de seguridad.

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [Cómo Contribuir](#cómo-contribuir)
- [Configuración del Entorno](#configuración-del-entorno)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Estándares de Código](#estándares-de-código)
- [Proceso de Pull Request](#proceso-de-pull-request)
- [Reportar Bugs](#reportar-bugs)
- [Solicitar Features](#solicitar-features)

## 📜 Código de Conducta

Este proyecto sigue un código de conducta para asegurar un ambiente colaborativo y respetuoso. Al participar, aceptas mantener este código.

### Nuestros Compromisos

- **Inclusión**: Crear un ambiente inclusivo para todos
- **Respeto**: Tratar a todos con respeto y dignidad
- **Colaboración**: Trabajar juntos hacia objetivos comunes
- **Profesionalismo**: Mantener un comportamiento profesional

## 🚀 Cómo Contribuir

### Tipos de Contribuciones

1. **🐛 Reportar Bugs**
   - Usa el template de issues para bugs
   - Incluye pasos para reproducir el problema
   - Especifica el entorno (OS, Flutter version, etc.)

2. **✨ Solicitar Features**
   - Usa el template de issues para features
   - Explica el caso de uso y beneficio
   - Considera la implementación

3. **💻 Contribuir Código**
   - Fork el repositorio
   - Crea una rama para tu feature
   - Sigue los estándares de código
   - Envía un Pull Request

4. **📚 Mejorar Documentación**
   - Corregir errores en README
   - Agregar ejemplos de código
   - Mejorar comentarios en el código

5. **🎨 Diseño y UX**
   - Mejorar la interfaz de usuario
   - Crear assets gráficos
   - Optimizar la experiencia de usuario

## 🛠️ Configuración del Entorno

### Prerrequisitos

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Git
- Editor de código (VS Code, Android Studio, etc.)

### Pasos de Configuración

1. **Fork y Clonar**
```bash
git clone https://github.com/tu-usuario/prevencion-segura.git
cd prevencion-segura
```

2. **Instalar Dependencias**
```bash
flutter pub get
```

3. **Verificar Configuración**
```bash
flutter doctor
```

4. **Ejecutar Tests**
```bash
flutter test
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── providers/               # Gestión de estado (Provider)
│   ├── sos_provider.dart    # Estado del sistema SOS
│   ├── education_provider.dart # Estado del módulo educativo
│   └── location_provider.dart # Estado de ubicación
├── screens/                 # Pantallas de la aplicación
│   ├── home_screen.dart     # Pantalla principal
│   ├── sos_screen.dart      # Pantalla de emergencia
│   ├── education_screen.dart # Módulo educativo
│   ├── history_screen.dart  # Historial de alertas
│   └── map_screen.dart      # Mapa y ubicación
├── utils/                   # Utilidades y constantes
│   └── app_colors.dart      # Paleta de colores
└── widgets/                 # Widgets reutilizables (futuro)

assets/
├── fonts/                   # Fuentes personalizadas
├── images/                  # Imágenes y iconos
└── animations/              # Animaciones Lottie
```

## 📝 Estándares de Código

### Dart/Flutter

- **Formato**: Usa `dart format` para formatear código
- **Análisis**: Ejecuta `flutter analyze` antes de commits
- **Naming**: Usa camelCase para variables y métodos
- **Comentarios**: Documenta funciones complejas
- **Imports**: Organiza imports por grupos

### Estructura de Commits

Usa el formato convencional de commits:

```
tipo(scope): descripción

[body opcional]

[footer opcional]
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Cambios de formato
- `refactor`: Refactorización de código
- `test`: Agregar o modificar tests
- `chore`: Cambios en build o herramientas

**Ejemplos:**
```
feat(sos): agregar grabación de audio en emergencias
fix(education): corregir cálculo de puntuación
docs(readme): actualizar instrucciones de instalación
```

### Testing

- **Unit Tests**: Para lógica de negocio
- **Widget Tests**: Para componentes UI
- **Integration Tests**: Para flujos completos

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests específicos
flutter test test/widget_test.dart
```

## 🔄 Proceso de Pull Request

### Antes de Enviar

1. **Sincronizar** con la rama principal
```bash
git checkout main
git pull origin main
git checkout tu-rama
git rebase main
```

2. **Verificar** que todo funcione
```bash
flutter analyze
flutter test
flutter run
```

3. **Actualizar** documentación si es necesario

### Crear Pull Request

1. **Título Descriptivo**: Explica claramente el cambio
2. **Descripción Detallada**: 
   - Qué cambió y por qué
   - Cómo probar los cambios
   - Screenshots si aplica
3. **Referenciar Issues**: Usa `#123` para referenciar issues
4. **Labels**: Asigna labels apropiados

### Template de Pull Request

```markdown
## 📝 Descripción
Breve descripción de los cambios realizados.

## 🔗 Issues Relacionados
- Closes #123
- Relates to #456

## 🧪 Cómo Probar
1. Paso 1
2. Paso 2
3. Resultado esperado

## 📱 Screenshots (si aplica)
[Agregar capturas de pantalla]

## ✅ Checklist
- [ ] Código formateado con `dart format`
- [ ] Tests pasando
- [ ] Documentación actualizada
- [ ] No hay warnings de análisis
```

## 🐛 Reportar Bugs

### Template de Bug Report

```markdown
**Descripción del Bug**
Descripción clara y concisa del problema.

**Pasos para Reproducir**
1. Ir a '...'
2. Hacer clic en '....'
3. Ver error

**Comportamiento Esperado**
Qué esperabas que pasara.

**Comportamiento Actual**
Qué está pasando realmente.

**Screenshots**
Si aplica, agrega capturas de pantalla.

**Entorno:**
- OS: [ej. Windows 10, macOS 12, Ubuntu 20.04]
- Flutter Version: [ej. 3.10.0]
- Dart Version: [ej. 3.0.0]
- Dispositivo: [ej. Android 12, iOS 15]

**Información Adicional**
Cualquier otra información relevante.
```

## ✨ Solicitar Features

### Template de Feature Request

```markdown
**¿Tu feature request está relacionada con un problema?**
Descripción clara del problema.

**Describe la solución que te gustaría**
Descripción clara de lo que quieres que pase.

**Describe alternativas que has considerado**
Otras soluciones o features que has considerado.

**Contexto adicional**
Cualquier otro contexto sobre la feature request.
```

## 🏷️ Labels y Milestones

### Labels Disponibles

- `bug`: Algo no funciona
- `enhancement`: Mejora a funcionalidad existente
- `feature`: Nueva funcionalidad
- `documentation`: Mejoras en documentación
- `good first issue`: Bueno para nuevos contribuidores
- `help wanted`: Se necesita ayuda extra
- `priority: high`: Alta prioridad
- `priority: medium`: Prioridad media
- `priority: low`: Baja prioridad

## 📞 Contacto

- **Issues**: Usa GitHub Issues para reportar problemas
- **Discussions**: Usa GitHub Discussions para preguntas generales
- **Email**: [tu-email@ejemplo.com]

## 🙏 Reconocimientos

Gracias a todos los contribuidores que hacen posible este proyecto. Tu esfuerzo es invaluable para crear una herramienta de seguridad más efectiva.

---

**Recuerda**: Cada contribución, por pequeña que sea, hace una diferencia. ¡Gracias por ayudar a hacer el mundo más seguro! 🛡️
