# ÉPICA E001: Autenticación y Autorización

## 📋 INFORMACIÓN DE LA ÉPICA
- **Código**: E001
- **Nombre**: Autenticación y Autorización
- **Descripción**: Sistema completo de registro, validación de email, login con aprobación de admin, logout y recuperación de contraseña
- **Story Points Totales**: 21 pts
- **Estado**: ⚪ Pendiente

## 📚 HISTORIAS DE USUARIO

### E001-HU-001: Registro de Alta al Sistema Web
- **Archivo**: `docs/historias-usuario/E001-HU-001-registro-alta-sistema.md`
- **Estado**: ✅ Completado
- **Story Points**: 8 pts
- **Prioridad**: Crítica
- **Descripción**: Autoregistro público con validación de email y aprobación de admin

### E001-HU-002: Login por Roles con Aprobación
- **Archivo**: `docs/historias-usuario/E001-HU-002-login-por-roles.md`
- **Estado**: ✅ Completado
- **Story Points**: 5 pts
- **Prioridad**: Crítica
- **Descripción**: Login solo para usuarios aprobados por admin según su rol

### E001-HU-003: Logout Seguro
- **Archivo**: `docs/historias-usuario/E001-HU-003-logout-seguro.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 3 pts
- **Prioridad**: Alta
- **Descripción**: Cierre de sesión seguro con limpieza de tokens

### E001-HU-004: Recuperar Contraseña
- **Archivo**: `docs/historias-usuario/E001-HU-004-recuperar-contraseña.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 5 pts
- **Prioridad**: Media
- **Descripción**: Recuperación de contraseña por email para usuarios aprobados

## 🎯 CRITERIOS DE ACEPTACIÓN DE LA ÉPICA
- [ ] Usuarios pueden registrarse públicamente con validación de email
- [ ] Admin inicial existe via script de BD para aprobar usuarios
- [ ] Solo usuarios aprobados pueden hacer login según su rol
- [ ] Sistema mantiene sesiones de forma segura
- [ ] Existe mecanismo de recuperación de contraseña
- [ ] Todas las validaciones de seguridad funcionan

## 📊 PROGRESO
- Total HU: 4
- ✅ Completadas: 1 (25%)
- 🟡 En Desarrollo: 0 (0%)
- ⚪ Pendientes: 3 (75%)

## 🗃️ DATOS TÉCNICOS

### Estados de Usuario en BD:
- **REGISTRADO**: Usuario se registró, email validado, esperando aprobación admin
- **APROBADO**: Admin aprobó usuario, puede hacer login
- **RECHAZADO**: Admin rechazó usuario, no puede hacer login
- **SUSPENDIDO**: Usuario suspendido temporalmente

### Roles del Sistema:
- **ADMIN**: Puede aprobar usuarios, gestionar todo el sistema
- **GERENTE**: Gestiona su tienda y vendedores
- **VENDEDOR**: Registra ventas en su tienda

### Script de Admin Inicial:
```sql
-- Script para crear admin inicial del sistema
INSERT INTO users (email, password_hash, nombre_completo, rol, estado, email_verificado, created_at)
VALUES (
  'admin@admin.com',
  '[HASH_SEGURO]',
  'Administrador del Sistema',
  'ADMIN',
  'APROBADO',
  true,
  NOW()
);
```

## 🔄 FLUJO GENERAL DE LA ÉPICA
1. **Usuario se registra** → Estado: REGISTRADO, email_verificado: false
2. **Usuario confirma email** → Estado: REGISTRADO, email_verificado: true
3. **Admin revisa y aprueba** → Estado: APROBADO
4. **Usuario puede hacer login** → Acceso según rol asignado
5. **Funcionalidades de logout y recuperación** → Disponibles para usuarios aprobados