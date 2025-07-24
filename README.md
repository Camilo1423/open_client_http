<div align="center">
  <img src="assets/icon/icon.png" width="120" height="120" alt="Open Client HTTP Logo">
  
  # Open Client HTTP
  
  ### Cliente HTTP REST Profesional para Flutter
  
  *Una aplicación completa para realizar peticiones HTTP con una interfaz intuitiva y características avanzadas*
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-GPL%20v3.0-blue?style=for-the-badge)](LICENSE)

</div>

---

## 📱 Acerca del Proyecto

**Open Client HTTP** es una aplicación móvil desarrollada en Flutter que funciona como un cliente REST completo, similar a Postman o Insomnia. Permite a los desarrolladores y testers realizar peticiones HTTP de manera eficiente, con soporte para múltiples métodos de autenticación, personalización de headers, parámetros y cuerpos de petición.

### ✨ Características Principales

- 🚀 **Peticiones HTTP Completas**: Soporte para GET, POST, PUT, DELETE, PATCH, OPTIONS y HEAD
- 🔐 **Autenticación Múltiple**: Bearer Token, Basic Auth, API Key y más
- 📝 **Editor de Cuerpo**: Editor avanzado para JSON, XML y texto plano
- 🎨 **Temas Personalizables**: Modo claro y oscuro con sincronización automática
- 📊 **Visualización de Respuestas**: Renderizado inteligente de respuestas JSON
- 📱 **Diseño Responsive**: Interfaz optimizada para móviles y tablets
- 💾 **Historial de Peticiones**: Guarda y reutiliza peticiones anteriores
- ⚙️ **Configuración Avanzada**: Timeouts personalizables y limpieza de historial

---

## 🛠️ Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación optimizado para UI

### Arquitectura y Patrones
- **Clean Architecture**: Separación clara entre capas de presentación, dominio y datos
- **Repository Pattern**: Abstracción de fuentes de datos
- **Use Cases**: Lógica de negocio encapsulada
- **Provider/Riverpod**: Gestión de estado reactiva

### Librerías Principales
- **Riverpod**: Gestión de estado y inyección de dependencias
- **Go Router**: Navegación declarativa y type-safe
- **Dio**: Cliente HTTP avanzado con interceptores
- **Flutter Secure Storage**: Almacenamiento seguro de credenciales
- **Interactive JSON Preview**: Visualización interactiva de JSON

---

## 🚀 Instalación y Configuración

### Prerrequisitos

Antes de comenzar, asegúrate de tener instalado:

- **Flutter SDK** (v3.8.1 o superior)
- **Dart SDK** (v3.8.1 o superior)
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Git** para clonar el repositorio

### Verificación del Entorno

```bash
flutter doctor
```

### 📥 Clonar el Repositorio

```bash
git clone https://github.com/Camilo1423/open_client_http.git
cd open_client_http
```

### 📦 Instalación de Dependencias

```bash
flutter pub get
```

### 🔧 Generar Código Automático

Este proyecto utiliza code generation para Riverpod:

```bash
flutter packages pub run build_runner build
```

Para desarrollo continuo:
```bash
flutter packages pub run build_runner watch
```

### 🎯 Configurar Iconos de la Aplicación

```bash
flutter pub run flutter_launcher_icons:main
```

---

## ▶️ Ejecutar la Aplicación

### Desarrollo en Android
```bash
flutter run -d android
```

### Desarrollo en iOS
```bash
flutter run -d ios
```

### Modo Debug Web
```bash
flutter run -d web
```

### Construcción para Producción

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

---

## 🏗️ Arquitectura del Proyecto

```
lib/
├── config/                 # Configuración y constantes
│   ├── constants/          # Constantes globales
│   └── theme/             # Configuración de temas
├── data/                   # Capa de datos
│   ├── datasources/       # Fuentes de datos externas
│   └── repositories/      # Implementación de repositorios
├── domain/                 # Capa de dominio (lógica de negocio)
│   ├── models/            # Modelos de datos
│   ├── repositories/      # Contratos de repositorios
│   └── usecases/          # Casos de uso
└── presentation/           # Capa de presentación
    ├── providers/         # Gestión de estado (Riverpod)
    ├── router/            # Configuración de rutas
    ├── screens/           # Pantallas de la aplicación
    └── widgets/           # Componentes reutilizables
```

### Principios de Clean Architecture

1. **Independencia de Framework**: La lógica de negocio no depende de Flutter
2. **Testabilidad**: Cada capa puede ser probada independientemente
3. **Independencia de UI**: La interfaz puede cambiar sin afectar la lógica
4. **Separación de Responsabilidades**: Cada capa tiene una responsabilidad específica

---

## 📱 Funcionalidades Detalladas

### 🏠 Pantalla Principal (Home)
- **Configuración de Peticiones**: Selección de método HTTP y URL
- **Acciones Rápidas**: Botones para parámetros y autorización
- **Editor de Cuerpo**: Área para contenido de peticiones POST/PUT
- **Botón de Envío**: Ejecuta la petición con validación

### 🔧 Gestión de Parámetros
- **Query Parameters**: Parámetros de consulta dinámicos
- **Headers HTTP**: Configuración de cabeceras personalizadas
- **Validación**: Verificación automática de formato

### 🔐 Sistema de Autenticación
- **No Auth**: Sin autenticación
- **Bearer Token**: Autenticación con token JWT
- **Basic Auth**: Usuario y contraseña en Base64
- **API Key**: Clave de API personalizada

### 📝 Editor de Cuerpo de Petición
- **Syntax Highlighting**: Resaltado de sintaxis JSON
- **Validación**: Verificación de formato JSON
- **Auto-formato**: Indentación automática

### 📊 Visualización de Respuestas
- **JSON Interactivo**: Exploración expandible de objetos JSON
- **Códigos de Estado**: Visualización clara de status codes
- **Headers de Respuesta**: Información completa de headers
- **Tiempo de Respuesta**: Métricas de rendimiento

### ⚙️ Configuraciones
- **Temas**: Alternancia entre modo claro y oscuro
- **Timeouts**: Configuración de tiempos de espera
- **Historial**: Gestión de peticiones guardadas
- **Limpieza**: Herramientas de mantenimiento

---

## 🔄 Estados de la Aplicación

### Estados de Petición
- **Idle**: Estado inicial
- **Loading**: Ejecutando petición
- **Success**: Petición exitosa
- **Error**: Error en la petición

### Gestión con Riverpod
```dart
// Ejemplo de provider
final currentRequestProvider = StateNotifierProvider<CurrentRequestNotifier, CurrentRequest>((ref) {
  return CurrentRequestNotifier();
});
```

---

## 🧪 Testing

### Ejecutar Tests Unitarios
```bash
flutter test
```

### Ejecutar Tests de Integración
```bash
flutter test integration_test/
```

### Coverage de Código
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📱 Plataformas Soportadas

| Plataforma | Estado | Versión Mínima |
|------------|--------|----------------|
| Android    | ✅     | API 21+        |
| iOS        | ✅     | iOS 12+        |

---

## 🚀 Deployment

### Android Play Store
1. Crear keystore para firma
2. Configurar `android/key.properties`
3. Ejecutar `flutter build appbundle --release`
4. Subir a Play Console

### iOS App Store
1. Configurar certificados en Xcode
2. Ejecutar `flutter build ios --release`
3. Usar Xcode para upload a App Store Connect

---

## 🤝 Contribución

### Proceso de Contribución
1. Fork el repositorio
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

### Estándares de Código
- Seguir las convenciones de Dart/Flutter
- Documentar funciones públicas
- Escribir tests para nuevas funcionalidades
- Mantener cobertura de tests > 80%

---

## 📄 Licencia

Este proyecto está licenciado bajo la **GNU General Public License v3.0**.

Consulta el archivo [LICENSE](LICENSE) para más detalles.

### Resumen de la Licencia
- ✅ Uso comercial permitido
- ✅ Modificación permitida
- ✅ Distribución permitida
- ✅ Uso privado permitido
- ❗ Las modificaciones deben ser liberadas bajo la misma licencia
- ❗ Debe incluir aviso de copyright y licencia

---

## 📞 Soporte y Contacto

### Reportar Bugs
Si encuentras algún problema, por favor [abre un issue](../../issues) con:
- Descripción detallada del problema
- Pasos para reproducir
- Screenshots si es aplicable
- Información del dispositivo y versión

### Solicitar Características
Para nuevas funcionalidades, [abre un issue](../../issues) con:
- Descripción de la característica deseada
- Casos de uso
- Mockups o ejemplos si es posible

---

## 🎯 Roadmap

### Próximas Características
- [ ] Exportación de colecciones
- [ ] Importación de colecciones open api

### En Desarrollo
- [ ] Mejoras en el editor JSON
- [ ] Más métodos de autenticación
- [ ] Optimizaciones de rendimiento

---

<div align="center">
  
  **¡Gracias por usar Open Client HTTP!** 🚀
  
  Si te gusta el proyecto, ¡dale una ⭐!
  
</div>
