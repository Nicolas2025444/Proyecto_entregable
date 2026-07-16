# Documentación Oficial del Proyecto: Sistema de Gestión de Citas Médicas

Este documento contiene el análisis de requerimientos, la descripción de la arquitectura del software, la justificación de las herramientas y el detalle de funcionalidades del sistema de agendamiento médico, adaptado a las necesidades de la clínica.

---

## 1. Análisis de Requerimientos y Propósito del Negocio

El sistema está diseñado para resolver las fricciones operativas en clínicas médicas, facilitando dos flujos de trabajo críticos:

1. **Para el Paciente:** Permitir la autogestión de citas médicas mediante la visualización de médicos disponibles por especialidad, selección interactiva de fechas a través de un calendario visual, y reserva de turnos evitando colisiones de horarios.
2. **Para el Médico:** Permitir la gestión ágil de su agenda diaria, visualizando las citas asignadas, cancelando citas que no puedan ser atendidas, y completando consultas mediante el registro de observaciones clínicas.

---

## 2. Propósito de las Herramientas dentro del Sistema

Cada librería y herramienta integrada en el desarrollo en Flutter cumple un rol específico que garantiza la robustez, seguridad y usabilidad del sistema:

*   **`http` (Cliente de Red):** Actúa como el puente de comunicación con la API REST. Permite realizar peticiones asíncronas GET, POST, PUT y DELETE para sincronizar datos con el servidor y la base de datos PostgreSQL.
*   **`provider` (Gestión de Estado):** Implementa el patrón observador para desacoplar la lógica de negocio de la interfaz de usuario. Administra estados globales (autenticación, listas de médicos, citas y conectividad) y notifica a las pantallas para que se redibujen reactivamente.
*   **`flutter_secure_storage` (Persistencia Local):** Resguarda de forma encriptada en el almacenamiento físico del dispositivo el token JWT de acceso y los datos del usuario logueado. Esto permite la persistencia de la sesión y evita que el usuario deba reautenticarse cada vez que abre la app.
*   **`table_calendar` (Calendario de Citas):** Provee una interfaz gráfica interactiva y premium para la selección de fechas de citas, facilitando una experiencia de usuario natural e intuitiva.
*   **`connectivity_plus` (Monitoreo de Red):** Escucha cambios de conectividad (WiFi/Datos) en tiempo real para activar mecanismos de error controlado (Offline banner) y prevenir caídas de la app.
*   **`intl` (Internacionalización):** Se utiliza para dar formato amigable a fechas y horas (ej. `dd/MM/yyyy - hh:mm a`) de acuerdo a las convenciones locales.

---

## 3. Arquitectura del Proyecto (Buenas Prácticas)

El código fuente sigue un patrón de diseño limpio y ordenado, estructurado en capas bien delimitadas para maximizar la legibilidad y mantenibilidad:

```text
lib/
├── core/
│   ├── config/      # Configuración de URLs de API y entornos (Mock/Real).
│   └── errors/      # Clases de Excepciones globales personalizadas.
├── data/
│   ├── datasources/ # Fuentes de datos HTTP (API) y simulaciones (Mock).
│   ├── models/      # Entidades de datos serializables (User, Medico, Cita).
│   ├── repositories/# Orquestador de la estrategia de obtención de datos.
│   └── services/    # Clientes de red (ApiClient) y almacenamiento local.
├── providers/       # Controladores de estado que exponen datos a la UI.
└── ui/
    ├── screens/     # Vistas principales de la aplicación (Login, Home, Booking).
    └── widgets/     # Componentes visuales reutilizables (Snackbars, Banners, Skeletons).
```

---

## 4. Detalle de Funcionalidades Implementadas (Criterios de Rúbrica)

### A. Consumo de API REST (CRUD Completo)
La comunicación HTTP está centralizada en `ApiClient`, la cual intercepta y añade dinámicamente las cabeceras `Authorization: Bearer <TOKEN>` y maneja las respuestas del servidor mapeándolas a excepciones específicas (401 Unauthorized, 404 Not Found, 500 Server Error). Se implementaron las cuatro operaciones CRUD:
1.  **GET (Lectura):** Obtención de la lista de médicos (`/medicos`) y listado de citas (`/citas`) filtradas por rol del usuario.
2.  **POST (Creación):** Creación de nuevas citas médicas (`/citas`) enviando el ID del médico, la fecha y hora seleccionada, y el motivo de consulta.
3.  **PUT (Actualización):** Actualización de observaciones médicas y estado de la cita a `completada` (`/citas/:id`).
4.  **DELETE (Eliminación/Cancelación):** Cancelación de citas (`/citas/:id`), liberando el bloque horario inmediatamente en el calendario.

### B. Gestión de Datos y Reactividad de Interfaz
*   **Actualización Reactiva Inmediata:** Los repositorios y providers actualizan las colecciones locales en memoria en cuanto se realiza una acción asíncrona exitosa. Esto hace que la UI reaccione instantáneamente ante cancelaciones o creaciones de citas sin requerir una recarga manual.
*   **Persistencia Local:** Los datos de sesión (token JWT y perfil de usuario) se almacenan de forma segura a través de `SessionStorageService` al loguearse, y se leen al iniciar la aplicación (`AuthGate`) para restaurar la sesión automáticamente.

### C. Diseño de Interfaz y Usabilidad (UI/UX)
*   **Navegación Fluida:** Separación del flujo médico y paciente de manera automatizada mediante roles. Navegación mediante pestañas (`TabBarView`) e interacción mediante paneles deslizantes (`ModalBottomSheet`).
*   **Tema Unificado:** Paleta de colores profesionales de salud (Azules médicos, verdes/teal de acento, fondos gris suave) configurada a través del `ThemeData` global de Flutter para todos los componentes de la aplicación.
*   **Mapeo de Errores y Estados de Carga:**
    *   **Pulsación de Skeletons:** En lugar de pantallas vacías, se muestran barras esqueléticas animadas (`_PulseSkeleton`) durante la carga de red.
    *   **Alerta de Red Offline:** Banner persistente superior en color rojo que se activa dinámicamente si se pierde el internet a mitad de una consulta, inhabilitando operaciones propensas a fallas.
    *   **Mensajes de Error Amigables:** Excepciones traducidas automáticamente a instrucciones comprensibles para el usuario final.
