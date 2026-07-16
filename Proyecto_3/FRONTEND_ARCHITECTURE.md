# Arquitectura del Frontend: Guía de Ingeniería (Flutter)

Este documento detalla el diseño de software, patrones de presentación, sistema de diseño y flujos de datos reactivos del lado del cliente (Frontend) del proyecto.

---

## 1. Patrón de Diseño Arquitectónico: MVVM (Model-View-ViewModel)

La aplicación implementa el patrón **MVVM** adaptado para el ecosistema de Flutter, garantizando un desacoplamiento absoluto de responsabilidades:

```text
 ┌──────────────┐         Peticiones de Datos / Métodos          ┌─────────────────┐
 │   Vistas     ├───────────────────────────────────────────────>│   ViewModels    │
 │   (Views)    │<───────────────────────────────────────────────┤   (Providers)   │
 └──────┬───────┘          Notificación de Cambio de Estado      └────────┬────────┘
        │                                                                 │
        │ Enlaza Datos y Tema                                            │ Consulta Datos
        ▼                                                                 ▼
 ┌──────────────┐                                                ┌─────────────────┐
 │    Diseño    │                                                │  Repositorios / │
 │ (UI System)  │                                                │     Modelos     │
 └──────────────┘                                                └─────────────────┘
```

*   **Model (Modelo):** Representa las entidades de datos del negocio (`User`, `Medico`, `Cita`). Son clases inmutables con serializadores JSON puros.
*   **View (Vista / UI):** Widgets de Flutter (`PacienteHomeScreen`, `BookingScreen`, `MedicoHomeScreen`). Su única tarea es pintar la pantalla y capturar gestos del usuario. **No contienen lógica de negocio**.
*   **ViewModel (Provider):** Clases controladoras de estado (`AuthProvider`, `CitaProvider`, `MedicoProvider`). Manejan la lógica de la UI, llaman a los repositorios, gestionan banderas de carga (`isLoading`), de guardado (`isSaving`), y propagan cambios usando `notifyListeners()`.

---

## 2. Gestión de Estado Reactiva (Provider)

El estado se maneja a través de un árbol de herencia reactiva utilizando `MultiProvider` en la raíz de la app (`main.dart`).

### Flujo de Estado Típico (Ej: Agendamiento de Cita)
1.  **Gesto:** El usuario pulsa "Confirmar Reservación" en `BookingScreen`.
2.  **Llamada al Provider:** La Vista invoca a `context.read<CitaProvider>().createCita(...)`.
3.  **Estado - Cargando:** El provider cambia `isSaving = true` y llama a `notifyListeners()`.
4.  **UI - Spinner:** La vista se entera del cambio (`context.watch<CitaProvider>()`) y renderiza un `CircularProgressIndicator` en el botón.
5.  **Lógica Asíncrona:** El provider espera la respuesta del servidor (`CitaRepository`).
6.  **Actualización Reactiva Local:** Si la llamada es exitosa, el objeto `Cita` se inserta directamente en la lista local en memoria.
7.  **Estado - Éxito:** El provider cambia `isSaving = false` y notifica.
8.  **UI - Éxito:** La vista quita el spinner, muestra un diálogo animado de éxito y actualiza la lista de citas del paciente al instante sin forzar recargas de red innecesarias.

---

## 3. Sistema de Diseño Visual y Experiencia de Usuario (UI/UX)

La interfaz se diseñó bajo los estándares de **Material Design 3**, adaptados a una estética limpia y profesional del área de la salud:

### A. Paleta de Colores Coherente
*   **Primary (`Color(0xFF1E3A8A)`):** Azul marino profundo. Aporta seriedad, confianza y profesionalismo clínico.
*   **Secondary (`Color(0xFF0D9488)`):** Verde azulado (Teal). Utilizado para llamadas a la acción, acentos positivos y badges de éxito.
*   **Surface (`Color(0xFFF8FAFC)`):** Fondo grisáceo muy claro y limpio que reduce la fatiga visual.
*   **Destructive (`Colors.red`):** Rojo de alerta reservado exclusivamente para la cancelación de citas y banners de desconexión.

### B. Micro-animaciones y UX Sensorial
*   **Skeleton Loading (Efecto Shimmer):** Durante las peticiones HTTP, se utiliza el widget personalizado `_PulseSkeleton` que anima la opacidad de contenedores grises simulando la carga del contenido final. Esto mejora la percepción del rendimiento de la app.
*   **Choice Chips Customizados:** El selector de horas utiliza chips estilizados que deshabilitan visualmente los horarios ocupados y cambian de color suavemente al seleccionarse.
*   **Bottom Sheets Contextuales:** En lugar de abrir pantallas nuevas para cada detalle, se emplean paneles inferiores que se deslizan desde la parte inferior de la pantalla.

---

## 4. Estructura Completa de Archivos del Frontend

```text
lib/
├── main.dart                      # Inicializador de Providers, MaterialApp y ThemeData.
├── core/
│   ├── config/
│   │   └── api_config.dart        # Variables de IP, rutas de endpoints y modo dual (Mock/Real).
│   └── errors/
│       └── api_exception.dart     # Definición de tipos de error (Red, Servidor, Validación).
├── data/
│   ├── models/
│   │   ├── user.dart              # Mapeo de datos del usuario autenticado.
│   │   ├── medico.dart            # Mapeo de la entidad médico.
│   │   └── cita.dart              # Mapeo de la entidad de citas médicas.
│   ├── datasources/
│   │   ├── auth_api.dart          # HTTP para login.
│   │   ├── mock_auth_api.dart     # Simulación de login local.
│   │   ├── medico_api.dart        # HTTP para médicos.
│   │   ├── mock_medico_api.dart   # Simulación de médicos local.
│   │   ├── cita_api.dart          # HTTP para citas.
│   │   └── mock_cita_api.dart     # Simulación de base de datos de citas.
│   ├── repositories/
│   │   ├── auth_repository.dart   # Orquestador de autenticación.
│   │   ├── medico_repository.dart # Orquestador de carga de médicos.
│   │   └── cita_repository.dart   # Orquestador del CRUD de citas.
│   └── services/
│       ├── api_client.dart        # Cliente HTTP centralizado (GET, POST, PUT, DELETE).
│       ├── token_storage_service.dart # Persistencia encriptada de JWT.
│       └── session_storage_service.dart # Persistencia encriptada de usuario.
├── providers/
│   ├── auth_provider.dart         # Estado de la sesión del usuario.
│   ├── medico_provider.dart       # Estado de la lista de médicos.
│   ├── cita_provider.dart         # Estado del CRUD de citas médicas.
│   └── connectivity_provider.dart # Estado del internet del dispositivo.
└── ui/
    ├── screens/
    │   ├── auth_gate.dart         # Selector automático de pantalla por rol/sesión.
    │   ├── login_screen.dart      # Formulario de autenticación con validadores.
    │   ├── paciente_home_screen.dart # Panel con listado de médicos y citas del paciente.
    │   ├── booking_screen.dart    # Calendario TableCalendar y agendamiento interactivo.
    │   └── medico_home_screen.dart # Panel médico con listado de turnos y diagnóstico.
    └── widgets/
        ├── app_snackbar.dart      # Mensajes flotantes de alerta o confirmación.
        ├── login_validators.dart  # Validaciones de formato de email y contraseña.
        └── connectivity_banner.dart # Banner rojo flotante persistente de desconexión.
```

---

## 5. Resiliencia del Frontend ante Fallos

El frontend no depende de la estabilidad absoluta del servidor para mantenerse estable. Se han implementado tres capas de protección ante fallos:
1.  **Capa de Clientes HTTP:** `ApiClient` traduce fallos del protocolo TCP o DNS (`SocketException`) a una `NetworkException` controlada.
2.  **Capa de Providers:** Los providers capturan la excepción y guardan el mensaje de error legible sin romper la ejecución de la UI.
3.  **Capa de Widgets:** `ConnectivityBanner` monitoriza constantemente el estado de red. Si el sistema operativo pierde conexión, se renderiza al instante un banner superior rojo advirtiendo la falta de internet y bloqueando de manera preventiva el envío de formularios de citas para evitar datos corruptos.
