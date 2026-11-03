# CHANGELOG.md - Registro de Cambios

Todos los cambios notables realizados en el proyecto TStore serán documentados en este archivo.

---

## [1.0.0] - 2026-07-19

### Inicialización del Proyecto E-commerce
* **Arquitectura Clean & SOLID:**
  * Estructura modular de carpetas basada en **Feature-First** (`authentication`, `products`, `cart`, `categories`, `orders`, `favorites`, `checkout`, `profile`, `search`).
  * Inyección de dependencias centralizada con **GetIt**.
  * Enrutamiento dinámico mediante **GoRouter** con redirección segura de checkout para usuarios no autenticados.
* **Gestión de Estado Reactiva:**
  * Adopción de **Riverpod** y sus respectivos providers automáticos e in-memory caching.
* **Persistencia Offline First:**
  * Integración completa de **Hive** para almacenamiento local rápido en formato JSON sin necesidad de complejas compilaciones nativas.
  * Implementación de colas de transacciones offline (`cart_pending_sync_queue` y `favorites_pending_sync_queue`) que registran cambios tomados sin conexión y los sincronizan con Odoo de forma automática al restablecerse el internet.
* **Networking & Clientes REST:**
  * Creación del cliente unificado `ApiClient` (utilizando **Dio**) con soporte para timeouts, interceptores de seguridad JWT, y flujo de reintento automático mediante refresco de tokens (`/api/auth/refresh`).
  * Inclusión del interceptor `MockApiInterceptor` que emula el comportamiento de controladores REST HTTP de Odoo 19 si la URL base en el archivo `.env` está configurada como `MOCK`.
* **Diseño Responsive Material 3:**
  * Pantalla adaptable a teléfonos (BottomNavigationBar) y tablets (NavigationRail lateral) utilizando `ResponsiveLayout`.
  * Soporte de temas Claro y Oscuro adaptativos según el sistema operativo.
* **Rendimiento e Imágenes:**
  * Paginación y scroll infinito implementado en la búsqueda y listado para optimizar la fluidez con catálogos masivos (+100k productos).
  * Renderización de descripciones completas en HTML con `HtmlWidget`.
  * Carga asíncrona (Lazy Loading) y placeholders utilizando `CachedNetworkImage` y Shimmer.
* **Calidad de Código:**
  * Cumplimiento del 100% de las reglas estáticas de análisis de Flutter (`No issues found` en `flutter analyze`).
