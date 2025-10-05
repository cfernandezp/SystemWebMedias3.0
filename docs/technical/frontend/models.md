# Modelos Frontend (Dart)

**Framework**: Flutter Web
**Última actualización**: [Fecha] por [Agente]

---

## 📋 Convenciones

- **Nomenclatura**: camelCase (userId, createdAt)
- **Clases**: PascalCase (UserModel, ProductModel)
- **Archivos**: snake_case (user_model.dart, product_model.dart)
- **Ubicación**: `lib/features/[modulo]/data/models/`

---

## 🔐 Módulo: [Nombre del Módulo]

### [ModelName]
**HU**: [HU-XXX]
**Mapea con**: Tabla `[tabla_bd]`
**Ubicación**: `lib/features/[modulo]/data/models/[model]_model.dart`
**Estado**: [🎨 Diseño / ✅ Implementado]

**DISEÑADO POR**: @web-architect-expert ([Fecha])
**IMPLEMENTADO POR**: @flutter-expert ([Fecha])

#### Diseño Propuesto:
```dart
class ModelName {
  final String campoId;        // ← campo_id (UUID)
  final String campoNombre;    // ← campo_nombre (TEXT)
  final DateTime createdAt;    // ← created_at (TIMESTAMP)

  const ModelName({
    required this.campoId,
    required this.campoNombre,
    required this.createdAt,
  });

  // Mapping desde JSON (Backend snake_case → Dart camelCase)
  factory ModelName.fromJson(Map<String, dynamic> json) {
    return ModelName(
      campoId: json['campo_id'] as String,
      campoNombre: json['campo_nombre'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Mapping a JSON (Dart camelCase → Backend snake_case)
  Map<String, dynamic> toJson() {
    return {
      'campo_id': campoId,
      'campo_nombre': campoNombre,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

#### Código Final Implementado:
```dart
// [Código Dart real por @flutter-expert]
```

#### Validaciones Frontend:
```dart
// [Validadores implementados según RN-XXX]
```

#### Cambios vs Diseño Inicial:
- ✅ [Cambio 1]: [Descripción]

---

## 📝 Plantilla para Nuevo Model

```markdown
### NuevoModel
**HU**: HU-XXX
**Mapea con**: Tabla `nueva_tabla`
**Ubicación**: `lib/features/[modulo]/data/models/nuevo_model.dart`
**Estado**: 🎨 Diseño

```dart
class NuevoModel {
  final String id;
  final String nombre;

  factory NuevoModel.fromJson(Map<String, dynamic> json) => NuevoModel(
    id: json['id'],
    nombre: json['nombre'],
  );
}
```
```
