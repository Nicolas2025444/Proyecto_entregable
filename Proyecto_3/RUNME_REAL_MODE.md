# Guía de Ejecución en Modo Real (API REST + PostgreSQL)

Esta guía te guiará paso a paso para configurar tu base de datos física PostgreSQL, levantar tu servidor backend y compilar el frontend de Flutter en Modo Real.

---

## Paso 1: Configurar PostgreSQL y pgAdmin

Si tu backend no crea las tablas automáticamente o deseas crearlas manualmente desde pgAdmin para asegurarte de que la estructura sea correcta, sigue estos pasos:

1.  Abre **pgAdmin** en tu computadora.
2.  Conéctate a tu servidor de base de datos e introduce tu clave.
3.  Crea una base de datos nueva (ej. clic derecho en `Databases` -> `Create` -> `Database...` y llámala `gestion_citas`).
4.  Haz clic derecho sobre tu nueva base de datos `gestion_citas` y selecciona **Query Tool** (Herramienta de Consultas).
5.  Copia, pega y ejecuta el siguiente script SQL para crear las tablas necesarias e insertar registros de prueba (médicos y pacientes) compatibles con las IDs del proyecto:

```sql
-- 1. Crear tabla de Usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- Nota: Si tu backend requiere hash (como bcrypt), ingresa el hash correspondiente.
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol VARCHAR(50) NOT NULL CHECK (rol IN ('paciente', 'medico'))
);

-- 2. Crear tabla de Médicos
CREATE TABLE medicos (
    id INT PRIMARY KEY REFERENCES usuarios(id) ON DELETE CASCADE,
    especialidad VARCHAR(255) NOT NULL
);

-- 3. Crear tabla de Citas
CREATE TABLE citas (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP NOT NULL,
    motivo TEXT NOT NULL,
    observaciones TEXT,
    estado VARCHAR(50) DEFAULT 'pendiente' NOT NULL CHECK (estado IN ('pendiente', 'completada', 'cancelada')),
    paciente_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
    medico_id INT REFERENCES usuarios(id) ON DELETE CASCADE
);

-- ==========================================
-- INSERTAR DATOS DE PRUEBA (SEMILLAS / SEED)
-- ==========================================

-- Insertar Paciente de Prueba (ID 1)
INSERT INTO usuarios (id, email, password, nombre, apellido, rol) 
VALUES (1, 'paciente@correo.com', '123456', 'Ana', 'Paciente', 'paciente');

-- Insertar Médicos de Prueba (Usuarios)
INSERT INTO usuarios (id, email, password, nombre, apellido, rol) 
VALUES (2, 'medico@correo.com', '123456', 'Carlos', 'Médico', 'medico');

INSERT INTO usuarios (id, email, password, nombre, apellido, rol) 
VALUES (3, 'sofia.pediatra@correo.com', '123456', 'Sofía', 'Valenzuela', 'medico');

INSERT INTO usuarios (id, email, password, nombre, apellido, rol) 
VALUES (4, 'fernando.general@correo.com', '123456', 'Fernando', 'Gómez', 'medico');

-- Insertar Especialidades de Médicos
INSERT INTO medicos (id, especialidad) VALUES (2, 'Cardiología');
INSERT INTO medicos (id, especialidad) VALUES (3, 'Pediatría');
INSERT INTO medicos (id, especialidad) VALUES (4, 'Medicina General');

-- Ajustar las secuencias de las IDs para evitar colisiones
SELECT setval('usuarios_id_seq', (SELECT MAX(id) FROM usuarios));
```

*(Una vez ejecutado en pgAdmin, las tablas quedarán creadas e inicializadas).*

---

## Paso 2: Iniciar tu Servidor Backend

1.  Abre la terminal en la carpeta de tu servidor backend.
2.  Configura las credenciales de conexión en el backend hacia tu PostgreSQL (`host`, `port`, `user`, `password`, `database: "gestion_citas"`).
3.  Inicia el servidor backend utilizando tu comando correspondiente. Por ejemplo:
    ```bash
    npm run start
    # o bien
    node server.js
    ```
4.  Verifica el puerto en el que está corriendo el servidor (comúnmente es el puerto `3000` o `5000`).

---

## Paso 3: Configurar Flutter en Modo Real

1.  Abre el proyecto de Flutter en tu editor (VS Code o Android Studio).
2.  Abre el archivo:
    📂 **[`lib/core/config/api_config.dart`](file:///c:/Users/nico1_zeptshs/Documents/Programacion%20Web%20y%20Movil/Presentar/Proyecto_3/Proyecto_3/lib/core/config/api_config.dart)**
3.  Modifica la bandera `useMockApi` a `false`:
    ```dart
    static const bool useMockApi = false;
    ```
4.  Modifica `API_BASE_URL` para reflejar el puerto de tu backend:
    *   *Si estás corriendo en el emulador de Android Studio:*
        ```dart
        defaultValue: 'http://10.0.2.2:3000/api', -- Reemplaza 3000 por el puerto de tu backend
        ```
    *   *Si estás compilando para Web o Escritorio:*
        ```dart
        defaultValue: 'http://localhost:3000/api',
        ```

---

## Paso 4: Correr y Verificar

1.  Conecta tu emulador o dispositivo físico.
2.  Ejecuta la app móvil mediante la terminal:
    ```powershell
    flutter run
    ```
3.  **Hacer Login:**
    *   Ingresa con el usuario paciente (`paciente@correo.com` / `123456`).
    *   Agenda una nueva cita seleccionando un día, hora y motivo en la pantalla.
    *   **Comprobación en pgAdmin:** Abre pgAdmin y haz un `SELECT * FROM citas;`. Deberías ver el registro que acabas de guardar en tiempo real desde el teléfono móvil.
4.  **Cerrar sesión e Iniciar como Médico:**
    *   Ingresa con el médico (`medico@correo.com` / `123456`).
    *   Visualiza la cita agendada por el paciente en la pestaña "Pendientes".
    *   Toca la cita, presiona "Atender / Obs", escribe un diagnóstico y confirma.
    *   **Comprobación en pgAdmin:** Vuelve a ejecutar `SELECT * FROM citas;` en pgAdmin. Verás que el estado de la cita cambió a `completada` y las observaciones contienen el diagnóstico ingresado.
