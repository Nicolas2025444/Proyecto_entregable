# Arquitectura del Software y Detalle Técnico del Proyecto

Este documento está dirigido a docentes e ingenieros evaluadores de software. Detalla las tecnologías utilizadas, la arquitectura implementada, y el funcionamiento interno de los componentes críticos del sistema (Manejo de tokens, API/DB y Manejo de Errores).

---

## 1. Tecnologías Utilizadas y Justificación

*   **Flutter SDK & Dart:** Plataforma y lenguaje principal para compilación nativa eficiente.
*   **Provider (Manejo de Estado):** Implementación reactiva para separar la interfaz de usuario de la lógica de negocio. Permite mantener actualizada la pantalla en tiempo real ante eventos externos.
*   **Http Package (Consumo REST):** Cliente HTTP ligero y versátil para realizar peticiones asíncronas hacia el backend.
*   **Flutter Secure Storage (Seguridad local):** Interfaz para almacenar credenciales de forma cifrada (utiliza el KeyStore en Android y Keychain en iOS).
*   **Table Calendar (Calendario):** Widget interactivo optimizado para gestión de agendas y calendarios de agendamiento.
*   **Connectivity Plus (Monitoreo de red):** Utilidad para escuchar el estado de red a nivel de sistema operativo y disparar flujos de error controlado.

---

## 2. Patrón Arquitectónico (MVC Adaptado / Clean Architecture)

El proyecto está diseñado bajo un desacoplamiento estricto de responsabilidades estructurado en tres grandes capas:

### A. Capa de Presentación (UI & Control de Estado)
*   **Vistas (`lib/ui/screens`):** Pantallas del sistema (Login, Paciente, Médico, Reservas) estructuradas con componentes nativos de Material 3.
*   **Widgets Reutilizables (`lib/ui/widgets`):** Tarjetas, barras de carga esqueléticas (`_PulseSkeleton`) y alertas de desconexión (`ConnectivityBanner`).
*   **Providers (`lib/providers`):** Controladores de estado (`ChangeNotifier`). Manejan el flujo lógico de los datos, exponen el estado actual de carga (`isLoading`), de guardado (`isSaving`), y propagan excepciones de red hacia la interfaz de usuario de forma reactiva.

### B. Capa de Datos (Data Layer)
*   **Modelos (`lib/data/models`):** Entidades de dominio serializables (`User`, `Medico`, `Cita`). Contienen constructores factorizados `.fromJson` y convertidores `.toJson` para intercambiar información estructurada con la API REST.
*   **Data Sources (`lib/data/datasources`):** Clases dedicadas a la comunicación directa con la red. Contienen llamadas puras mediante el cliente HTTP. Se implementa una **fuente de datos dual**:
    *   `*_api.dart`: Conecta con el backend PostgreSQL real.
    *   `mock_*_api.dart`: Simula el backend en memoria de forma mutable, permitiendo validar las funcionalidades en ausencia de conexión al servidor.
*   **Repositorios (`lib/data/repositories`):** Actúan como un orquestador que decide el origen de los datos (Real vs Mock) según la bandera de compilación y resuelve errores de infraestructura en mensajes legibles.

### C. Servicios y Core (Core Layer)
*   **Cliente HTTP (`lib/data/services/api_client.dart`):** Centralizador de las peticiones GET, POST, PUT, DELETE.
*   **Persistencia local (`lib/data/services/session_storage_service.dart`):** Enlace con el almacén encriptado del dispositivo para la sesión activa.
*   **Gestor de Errores (`lib/core/errors/api_exception.dart`):** Excepciones personalizadas para el dominio.

---

## 3. Detalle de Componentes Críticos (Criterios de Ingeniería)

### A. Seguridad: Ciclo de Vida del Token JWT
1.  **Persistencia del Token:** Al loguearse con éxito, la respuesta JSON que contiene el token JWT y el perfil de usuario se envía a `SessionStorageService`. Este escribe encriptadamente el token bajo la clave `jwt_token` y el perfil del usuario codificado en JSON bajo la clave `user_data`.
2.  **Interceptación de Cabeceras (Headers):** Cada petición que requiera autenticación activa la bandera `requiresAuth = true`. El cliente de red (`ApiClient`) intercepta la petición y llama al método asíncrono privado `_buildHeaders`. Este obtiene el JWT guardado en `FlutterSecureStorage` y añade automáticamente la cabecera:
    ```text
    Authorization: Bearer <TOKEN_JWT_AQUÍ>
    ```
    Si el token no existe, el cliente lanza una `UnauthorizedException` previniendo la petición fallida al servidor.
3.  **Persistencia de Sesión al Inicio:** Al abrir la aplicación, `AuthGate` llama a `AuthProvider.restoreSession()`. Este verifica de forma segura si existe una sesión activa y un token válido sin obligar al usuario a iniciar sesión de nuevo.

### B. Conexión a la Base de Datos (API Gateway)
*   El cliente móvil no conecta directamente a la base de datos PostgreSQL por motivos de seguridad informática. En su lugar, consume una API REST centralizada que expone los siguientes endpoints transaccionales:
    *   `POST /auth/login` -> Autenticación y generación de JWT.
    *   `GET /medicos` -> Obtención de médicos especialistas.
    *   `GET /citas` -> Obtención de citas filtradas por usuario.
    *   `POST /citas` -> Creación de cita médica en base de datos.
    *   `PUT /citas/:id` -> Actualización de observaciones de consulta y cambio de estado a completada.
    *   `DELETE /citas/:id` -> Cancelación y eliminación del registro.
*   **Mock mutable reactivo:** En modo simulación, la clase `MockCitaApi` mantiene una lista estática mutable en memoria. Al llamar a `createCita` o `updateCita`, los datos locales cambian en caliente, permitiendo simular inserciones, actualizaciones y eliminaciones reactivas idénticas a PostgreSQL en tiempo de ejecución.

### C. Manejo de Errores Global y Resiliencia
El manejo de excepciones está blindado en la clase `ApiClient._handleResponse` y `_mapStatusCodeToException`:
```dart
ApiException _mapStatusCodeToException(http.Response response) {
  final message = _extractErrorMessage(response.body);

  return switch (response.statusCode) {
    400 || 422 => ValidationException(message ?? 'Datos no válidos.'),
    401 => UnauthorizedException(message ?? 'Sesión expirada.'),
    404 => NotFoundException(message ?? 'Recurso no encontrado.'),
    >= 500 => ServerException(message ?? 'Error interno del servidor.'),
    _ => UnknownApiException(message ?? 'Error inesperado.'),
  };
}
```
*   **Errores Físicos de Conexión:** Si el servidor está apagado o no hay cobertura, se captura `SocketException` o `HttpException` en el cliente y se lanza una `NetworkException`.
*   **Resiliencia de Interfaz:** Los Providers capturan estas excepciones en bloques `try-catch`, actualizan `errorMessage` e inhabilitan cargadores. La UI reacciona mostrando pantallas de error con botones de "Reintentar" o banners rojos flotantes de desconexión sin congelar ni corromper la aplicación.
