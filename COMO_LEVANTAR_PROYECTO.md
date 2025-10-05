# 🚀 Cómo Levantar el Proyecto - Sistema de Venta de Medias

**Última actualización**: 2025-10-04
**Versión**: 3.0

---

## 📋 PRE-REQUISITOS

Asegúrate de tener instalado:

- ✅ **Docker Desktop** - Corriendo en background
- ✅ **Supabase CLI** - v2.40.7+ (`supabase --version`)
- ✅ **Flutter SDK** - v3.0+ (`flutter --version`)
- ✅ **Git Bash** (Windows) o terminal compatible

---

## 🔧 PASO 1: LEVANTAR BACKEND (Supabase)

### Iniciar Supabase Local

```bash
# Desde la raíz del proyecto
cd c:/SystemWebMedias3.0

# Iniciar todos los servicios
supabase start
```

**Tiempo estimado**: ~30-60 segundos

### Verificar que esté corriendo

```bash
supabase status
```

**Deberías ver**:
```
 API URL: http://127.0.0.1:54321
 Studio URL: http://127.0.0.1:54323
 DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
supabase local development setup is running.
```

### Acceder a Supabase Studio (Dashboard)

Abre en tu navegador:
```
http://127.0.0.1:54323
```

Aquí puedes:
- Ver tablas y datos
- Ejecutar queries SQL
- Probar las Database Functions
- Gestionar usuarios

---

## 🎨 PASO 2: LEVANTAR FRONTEND (Flutter)

### Instalar dependencias

```bash
# Primera vez o después de cambios en pubspec.yaml
flutter pub get
```

### Ejecutar en modo desarrollo

```bash
# Opción 1: Chrome
flutter run -d chrome

# Opción 2: Edge
flutter run -d edge

# Opción 3: Con puerto específico
flutter run -d chrome --web-port 8080
```

**URL del frontend**: http://localhost:8080 (o el puerto que uses)

---

## 🧪 PASO 3: PROBAR EL SISTEMA

### Test Manual - Database Functions

Abre **Supabase Studio** → **SQL Editor** y ejecuta:

```sql
-- Test 1: Registrar usuario
SELECT register_user(
  'test@ejemplo.com',
  'password123',
  'Usuario Test'
);

-- Deberías ver un JSON con el usuario creado y token_confirmacion

-- Test 2: Confirmar email (copia el token del paso anterior)
SELECT confirm_email('token_generado_aqui');

-- Test 3: Reenviar confirmación
SELECT resend_confirmation('test@ejemplo.com');
```

### Test Manual - Tabla Users

```sql
-- Ver usuarios registrados
SELECT
  id,
  email,
  nombre_completo,
  estado,
  email_verificado,
  created_at
FROM users
ORDER BY created_at DESC;
```

---

## 🛑 DETENER EL PROYECTO

### Detener Supabase

```bash
# Detener servicios (mantiene datos)
supabase stop

# Detener y limpiar TODO (⚠️ BORRA DATOS)
supabase stop --no-backup
```

### Detener Flutter

En la terminal donde corre Flutter:
- Presiona `q` + Enter
- O `Ctrl + C`

---

## ⚠️ TROUBLESHOOTING

### Problema: Error "port is already allocated"

**Solución**:
```bash
# Ver qué proyecto está usando el puerto
docker ps -a | grep supabase

# Detener todos los proyectos Supabase
supabase stop --all

# Reintentar
supabase start
```

### Problema: "Error 500" al iniciar Supabase

**Causa**: Edge Runtime deshabilitado (intencional)
**Solución**: Ignorar, el sistema usa Database Functions (no Edge Functions)

### Problema: Contenedores zombie

**Solución**:
```bash
# Limpiar contenedores huérfanos
docker ps -a | grep supabase | awk '{print $1}' | xargs -r docker rm -f

# Limpiar volúmenes
docker volume prune -f

# Reintentar
supabase start
```

### Problema: Flutter no encuentra Chrome

**Solución**:
```bash
# Ver dispositivos disponibles
flutter devices

# Usar el que aparezca en la lista
flutter run -d <device-id>
```

---

## 📊 INFORMACIÓN DEL STACK

### Backend
- **Base de datos**: PostgreSQL 17 (via Supabase)
- **Autenticación**: Database Functions (RPC)
- **Storage**: Supabase Storage
- **Emails**: Inbucket (testing local) - http://127.0.0.1:54324

### Frontend
- **Framework**: Flutter Web
- **Arquitectura**: Clean Architecture
- **State Management**: flutter_bloc
- **HTTP Client**: supabase_flutter

### Migraciones aplicadas
- ✅ `20251004145739_hu001_users_registration.sql` - Tabla users y RLS
- ✅ `20251004170000_hu001_database_functions.sql` - Funciones register, confirm, resend

---

## 🔑 CREDENCIALES LOCALES

### Supabase (Local Development)

```
URL API: http://127.0.0.1:54321
anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

### PostgreSQL (Directo)

```
Host: 127.0.0.1
Port: 54322
Database: postgres
User: postgres
Password: postgres
```

---

## 📚 DOCUMENTACIÓN ADICIONAL

- [SISTEMA_DOCUMENTACION.md](SISTEMA_DOCUMENTACION.md) - Estructura del proyecto
- [docs/technical/backend/MIGRATION_EDGE_TO_DB_FUNCTIONS.md](docs/technical/backend/MIGRATION_EDGE_TO_DB_FUNCTIONS.md) - Decisión arquitectónica
- [docs/historias-usuario/E001-HU-001-registro-alta-sistema.md](docs/historias-usuario/E001-HU-001-registro-alta-sistema.md) - Historia de Usuario implementada

---

## 💡 COMANDOS ÚTILES

```bash
# Ver logs de Supabase
docker logs -f supabase_db_SystemWebMedias3.0

# Resetear base de datos (aplica todas las migrations)
supabase db reset

# Crear nueva migration
supabase migration new nombre_de_la_migracion

# Ver diferencias en schema
supabase db diff --schema public

# Ejecutar tests de Flutter
flutter test

# Analizar código Flutter
flutter analyze
```

---

**¿Problemas?** Revisa la sección [Troubleshooting](#-troubleshooting) o consulta los logs de Docker.
