# 🔐 Credenciales de Prueba

## Usuarios creados después de `npx supabase db reset`

### ADMIN
- **Email**: `admin@test.com`
- **Contraseña**: `asdasd211`
- **Rol**: ADMIN
- **Nombre**: Administrador Principal

### GERENTE
- **Email**: `gerente@test.com`
- **Contraseña**: `asdasd211`
- **Rol**: GERENTE
- **Nombre**: Gerente Tienda Centro
- **Tienda**: Centro

### VENDEDOR
- **Email**: `vendedor@test.com`
- **Contraseña**: `asdasd211`
- **Rol**: VENDEDOR
- **Nombre**: Vendedor Tienda Centro
- **Tienda**: Centro

---

## 📝 Notas

- Estas credenciales se crean automáticamente al ejecutar `npx supabase db reset`
- Los usuarios ya tienen el email confirmado (`email_confirmed_at` poblado)
- Todos los usuarios tienen contraseña encriptada en `auth.users`
- El error "Usuario no encontrado o verificado" ocurre cuando se usa una contraseña incorrecta

## 🔍 Ubicación en código

Credenciales definidas en: `supabase/migrations/00000000000006_seed_data.sql` (líneas 8-10)
