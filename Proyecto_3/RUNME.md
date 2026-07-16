# Guía de Ejecución Paso a Paso: RUNME

Esta guía te ayudará a configurar y correr el proyecto de gestión de citas médicas en tu entorno local.

---

## 1. Requisitos Previos

Asegúrate de contar con lo siguiente instalado en tu equipo de desarrollo:
1.  **Flutter SDK (Versión 3.12.2 o superior)**. Ejecuta `flutter --version` para verificar.
2.  **Dart SDK**.
3.  **Android Studio** (con un Emulador configurado) o **VS Code** con la extensión de Flutter.
4.  Conexión a internet estable para descargar las librerías iniciales.

---

## 2. Configuración e Instalación

Sigue estos pasos en la terminal (PowerShell o Git Bash) dentro de la carpeta raíz del proyecto (`Proyecto_3/Proyecto_3`):

1.  **Descargar e instalar dependencias:**
    Descarga e instala las librerías añadidas en el archivo `pubspec.yaml` (`table_calendar`, `connectivity_plus`, `intl`):
    ```powershell
    flutter pub get
    ```

2.  **Verificar sanidad del código (Lints y Análisis):**
    Ejecuta el analizador de Flutter para verificar que la sintaxis y tipos son correctos y no existen errores:
    ```powershell
    flutter analyze
    ```
    *(Debería retornar un resultado libre de errores y warnings).*

---

## 3. Configuración Manual (Conexión Real vs Simulación Mock)

El proyecto cuenta con un sistema de alternancia dinámico. Puedes configurarlo editando de forma manual el archivo de configuración global del servidor en la siguiente ruta:

📂 **[`lib/core/config/api_config.dart`](file:///c:/Users/nico1_zeptshs/Documents/Programacion%20Web%20y%20Movil/Presentar/Proyecto_3/Proyecto_3/lib/core/config/api_config.dart)**

### Opción A: Modo Simulación (Mock API) - *Por defecto*
Permite probar todas las funcionalidades (agendamiento, calendario, observaciones del médico y lógica offline) inmediatamente en tu emulador sin necesidad de levantar un backend o configurar PostgreSQL:
*   Asegúrate de que `useMockApi` esté establecido en `true`:
    ```dart
    static const bool useMockApi = true;
    ```
*   **Credenciales de Prueba (Modo Mock):**
    *   **Flujo Paciente:** Correo: `paciente@correo.com` / Contraseña: `123456`
    *   **Flujo Médico:** Correo: `medico@correo.com` / Contraseña: `123456`

### Opción B: Conexión Real (API REST + PostgreSQL)
Para conectar el frontend con tu API REST y tu base de datos de PostgreSQL real:
1.  Cambia `useMockApi` a `false`:
    ```dart
    static const bool useMockApi = false;
    ```
2.  Ajusta el parámetro `defaultValue` de `API_BASE_URL` para que apunte a tu servidor backend corriendo localmente o en producción.
    *   *Nota para Emulador Android:* Utiliza `http://10.0.2.2:3000/api` para hacer referencia al localhost de tu PC.
    *   *Nota para dispositivo físico:* Cambia `10.0.2.2` por la dirección IP local de tu ordenador (ej. `http://192.168.1.50:3000/api`).

---

## 4. Ejecución del Proyecto

1.  Asegúrate de tener un emulador Android/iOS iniciado o un dispositivo físico conectado mediante depuración USB.
2.  Corre el proyecto mediante el comando estándar:
    ```powershell
    flutter run
    ```
3.  Si estás utilizando VS Code o Android Studio, simplemente abre el proyecto, selecciona el dispositivo de destino en la barra inferior y presiona **F5** (Iniciar depuración).

---

## 5. Compilación del Instalador (Opcional)

Si deseas generar el instalador APK ejecutable para Android para cargarlo a un dispositivo físico:
```powershell
flutter build apk --release
```
El archivo resultante se creará en la ruta:
`build/app/outputs/flutter-apk/app-release.apk`
