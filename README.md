# TStore - Flutter E-commerce Clean Architecture & Odoo 19 REST API Client

TStore es una aplicación e-commerce empresarial desarrollada en Flutter siguiendo los más altos estándares de diseño, arquitectura, seguridad y rendimiento. La aplicación está diseñada para conectarse a un servidor Odoo 19 utilizando controladores HTTP JSON REST y opera bajo una estrategia **Offline-First**.

## Características Clave

* **Clean Architecture & SOLID:** Separación estricta de capas (Presentation, Domain, Data) estructurada por módulos (Feature-First).
* **Estrategia Offline-First:** Navega por productos y categorías, agrega artículos al carrito y gestiona tus favoritos sin conexión a internet utilizando **Hive**.
* **Cola de Sincronización Fuera de Línea:** Las acciones en el carrito y favoritos tomadas fuera de línea se guardan en una cola de transacciones que se sincroniza automáticamente con Odoo cuando se restablece la conexión.
* **Alto Rendimiento:** Optimizado para manejar catálogos de más de 100,000 productos utilizando scroll infinito paginado, deserialización eficiente, lazy loading y almacenamiento local indexado.
* **Diseño Responsive Moderno:** Interfaz de usuario Material 3 fluida adaptada tanto para smartphones (Bottom Navigation) como para tablets (Navigation Rail lateral).
* **Seguridad:** Autenticación por Tokens JWT persistidos de manera segura con `flutter_secure_storage`.
* **Soporte Light/Dark:** Cambio automático y adaptativo de tema claro y oscuro según las preferencias del sistema operativo.

---

## Requisitos Previos

Asegúrate de contar con el entorno de desarrollo configurado:
* **Flutter SDK:** ^3.24.0 o superior.
* **Dart SDK:** ^3.5.0 o superior.
* **Android Studio / VS Code** con los plugins de Flutter y Dart.
* **Dispositivo físico o emulador Android** (compatible con Android 5.0+ / API 21+).

---

## Estructura de Archivos del Proyecto

El árbol del código fuente está estructurado de la siguiente forma:

```
lib/
├── core/
│   ├── config/              # Inyección de dependencias, GoRouter, variables de entorno (.env)
│   ├── constants/           # Constantes del negocio, rutas de almacenamiento y API
│   ├── database/            # Inicialización de Hive Database y adaptadores genéricos
│   ├── exceptions/          # Manejo de fallos (Failures) según Clean Architecture
│   ├── network/             # ApiClient (Dio), interceptores de JWT, MockApiInterceptor
│   ├── services/            # Servicios de conectividad sockets pura
│   ├── theme/               # Paleta de colores e-commerce clara y oscura con Material 3
│   ├── utils/               # Loggers con códigos de escape de color ANSI
│   └── widgets/             # Componentes visuales genéricos (ProductCard, Shimmer, ResponsiveLayout)
├── features/
│   ├── authentication/      # Registro, Login, perfil de Odoo
│   ├── cart/                # Gestión de carrito local y sincronización con Odoo
│   ├── categories/          # Árbol jerárquico de categorías y subcategorías
│   ├── checkout/            # Checkout e-commerce que requiere autenticación obligatoria
│   ├── favorites/           # Gestión de favoritos y sincronización optimista
│   ├── home/                # Pantalla principal con banners, promociones y listados
│   ├── orders/              # Historial de pedidos y consulta de facturas PDF
│   ├── products/            # Búsqueda, paginación infinita y detalle con visor HTML
│   ├── profile/             # Modificación de dirección de entrega, teléfonos y perfil
│   └── search/              # Búsqueda interactiva con debounce (300ms)
└── main.dart                # Bootstrapper del sistema e inicializador de ProviderScope (Riverpod)
```

---

## Configuración del Entorno

La aplicación lee variables de entorno de un archivo `.env` en la raíz del proyecto:

1. Crea o modifica el archivo `.env` en la raíz de tu proyecto:
   ```env
   API_BASE_URL=MOCK
   API_TIMEOUT_MS=15000
   OFFLINE_SYNC_INTERVAL_SEC=30
   APP_NAME=TStore Importaciones
   APP_VERSION=1.0.0
   ```
2. Para conectar a una instancia de producción de Odoo 19, reemplace `MOCK` por la URL base de sus controladores REST de Odoo (por ejemplo, `https://miodoo.com`).

---

## Instrucciones para Compilar y Ejecutar

### 1. Descargar Dependencias

Ejecute en la consola desde la raíz del proyecto para descargar e instalar todas las dependencias del `pubspec.yaml`:

```bash
flutter pub get
```

### 2. Generación de Archivos (en caso de usar build_runner)

Si agregas nuevos modelos con `@JsonSerializable` u otras clases generadas, ejecuta el comando de generación:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Ejecutar en Modo Debug

Para probar la aplicación en tu emulador o dispositivo físico conectado:

```bash
flutter run
```

### 4. Compilar APK para Producción

Para generar el paquete instalable APK optimizado para Android:

```bash
flutter build apk --release
```

El APK compilado se guardará en `build/app/outputs/flutter-apk/app-release.apk`.
