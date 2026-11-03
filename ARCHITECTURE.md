# ARCHITECTURE.md - Arquitectura del Sistema TStore

Este documento explica las bases arquitectónicas utilizadas en el diseño e implementación de la aplicación e-commerce TStore.

---

## 1. Clean Architecture

La aplicación está diseñada sobre **Clean Architecture**, dividiendo el código en tres capas fundamentales con dependencias unidireccionales de afuera hacia adentro:

```
[ Capa de Presentación (UI / Riverpod Providers) ]
               │
               ▼  (Llama)
[ Capa de Dominio (Entities / UseCases / Repository Interfaces) ]
               ▲
               │  (Implementa)
[ Capa de Datos (Models / Repositories / DataSources / Hive DB / Dio HTTP) ]
```

### Capa de Dominio (Domain)
Es el núcleo lógico e independiente de la aplicación. No depende de ningún framework, base de datos o cliente HTTP.
* **Entities:** Objetos de datos puros que representan los modelos de negocio del e-commerce (`User`, `Product`, `Category`, `CartItem`, `Order`).
* **UseCases:** Casos de uso específicos que contienen las reglas de negocio (ej. `LoginUseCase`, `GetProductsUseCase`, `AddToCartUseCase`).
* **Repository Interfaces:** Definición de contratos que la capa de datos debe implementar.

### Capa de Datos (Data)
Implementa los contratos de la capa de dominio y se encarga de recuperar/persistir información de fuentes externas.
* **Models:** Extensiones de las entidades con soporte para serialización y deserialización (`UserModel`, `ProductModel`, etc.).
* **DataSources:** Clases de bajo nivel encargadas de llamar a las APIs REST (`RemoteDataSource`) o de interactuar con el almacenamiento local Hive (`LocalDataSource`).
* **Repositories:** Coordinan las llamadas entre las fuentes remotas y locales para implementar estrategias como **Offline First**.

### Capa de Presentación (Presentation)
Contiene todo lo relacionado con la interfaz de usuario y el control de su estado.
* **Views:** Pantallas optimizadas y responsivas (Material 3).
* **Widgets:** Elementos UI reutilizables.
* **State Providers (Riverpod):** Manejadores de estado reactivos que exponen los datos y ejecutan casos de uso de la capa de dominio en segundo plano.

---

## 2. Principios SOLID en Acción

* **Single Responsibility Principle (SRP):** Cada clase tiene una única responsabilidad. Por ejemplo, `ApiClient` solo gestiona las peticiones HTTP y errores de red; `CartLocalDataSource` solo gestiona la persistencia local del carrito; los casos de uso representan una única acción del negocio.
* **Open/Closed Principle (OCP):** Las clases están abiertas a la extensión pero cerradas a la modificación. El patrón de inyección de dependencias permite extender la lógica inyectando nuevos componentes sin cambiar el código cliente.
* **Liskov Substitution Principle (LSP):** Las clases derivadas como `ProductModel` heredan y se comportan exactamente como la entidad base `Product`, permitiendo ser utilizadas de forma transparente en cualquier parte de la aplicación.
* **Interface Segregation Principle (ISP):** Las interfaces de repositorio como `FavoritesRepository` están segregadas y solo contienen operaciones relevantes para su contexto.
* **Dependency Inversion Principle (DIP):** Las capas de alto nivel (Domain / Presentation) no dependen de las capas de bajo nivel (Data). Ambas dependen de abstracciones (interfaces de Repositorio). El contenedor GetIt se encarga de resolver las instancias reales en tiempo de ejecución.

---

## 3. Arquitectura Modular y Feature-First

El proyecto adopta una estructura de carpetas basada en **módulos funcionales (Feature-First)**. Cada característica del e-commerce (ej. `authentication`, `products`, `cart`, `orders`) está contenida en su propio directorio con su correspondiente división interna (Data, Domain, Presentation).

### ¿Cómo añadir nuevos módulos sin modificar la arquitectura principal?
La arquitectura es completamente modular y escalable. Para añadir un nuevo módulo como un **Chat IA**, **Pasarela de Pagos**, o **Cupones de Descuento**:

1. **Crear la estructura del módulo:**
   Crea la carpeta dentro de `lib/features/chat_ia/` con sus subdirectorios `data/`, `domain/` y `presentation/`.
2. **Definir entidades, repositorios y casos de uso:**
   Escribe la lógica del chat o los cupones dentro de su capa de dominio.
3. **Definir la persistencia o red:**
   Crea las llamadas necesarias en el `ApiClient` o un nuevo Box de Hive en el módulo de datos.
4. **Registrar dependencias:**
   Registra el nuevo servicio en `lib/core/config/dependency_injection.dart` sin alterar los módulos existentes.
5. **Configurar navegación:**
   Crea la ruta correspondiente en `lib/core/config/app_router.dart`.

---

## 4. Gestión de Estado y Flujo Reactivo (Riverpod)

Utilizamos **Riverpod** para la reactividad de la interfaz por las siguientes razones:
* **Seguridad en tiempo de compilación:** A diferencia de Provider clásico, Riverpod no arroja excepciones `ProviderNotFoundException` en tiempo de ejecución.
* **Independencia del árbol de widgets:** Los estados se pueden leer o escuchar desde fuera de la interfaz (ej. desde interceptores de red o servicios de fondo).
* **Manejo automático del ciclo de vida:** Libera recursos automáticamente cuando las pantallas se destruyen (`AutoDispose`).

El flujo de información sigue un ciclo unidireccional:
1. La UI detecta un evento del usuario y lo delega al `StateNotifierProvider` correspondiente.
2. El Notifier activa el `UseCase` del dominio.
3. El `UseCase` solicita los datos al `Repository`.
4. El `Repository` decide si los lee de `Hive` (local) o llama al `ApiClient` (remoto).
5. Los datos fluyen de regreso al `Notifier`, actualizando el estado de la UI de forma reactiva.
