# Componentes UI - Design System

**Metodología**: Atomic Design
**Última actualización**: [Fecha] por [Agente]

---

## 📋 Estructura

- **Atoms**: Componentes básicos (botones, inputs, iconos)
- **Molecules**: Combinaciones simples (cards, forms)
- **Organisms**: Componentes complejos (listas, headers)
- **Templates**: Layouts y estructuras de página

---

## 🔐 Módulo: [Nombre del Módulo]

### [ComponentName] (Atom/Molecule/Organism)
**HU**: [HU-XXX]
**Ubicación**: `lib/shared/design_system/[atoms|molecules|organisms]/[component].dart`
**Estado**: [🎨 Diseño / ✅ Implementado]

**DISEÑADO POR**: @web-architect-expert ([Fecha])
**IMPLEMENTADO POR**: @ux-ui-expert ([Fecha])

#### Diseño Propuesto:
```dart
class ComponentName extends StatelessWidget {
  final String prop1;
  final VoidCallback? onAction;

  const ComponentName({
    Key? key,
    required this.prop1,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Text(prop1, style: DesignTypography.body1),
    );
  }
}
```

#### Propiedades:
| Prop | Tipo | Descripción | Requerido |
|------|------|-------------|-----------|
| `prop1` | String | Descripción | ✅ |
| `onAction` | VoidCallback? | Acción al click | ❌ |

#### Design Tokens Usados:
- Colores: `DesignColors.primary`, `DesignColors.surface`
- Spacing: `DesignSpacing.md`, `DesignSpacing.lg`
- Typography: `DesignTypography.body1`

#### Validaciones UI (según RN):
- ✅ [RN-XXX]: [Cómo se implementa visualmente]

#### Estados:
- `initial`: Estado inicial
- `loading`: Mostrando loader
- `error`: Mostrando error
- `success`: Acción completada

#### Código Final Implementado:
```dart
// [Código Dart real por @ux-ui-expert]
```

---

## 📝 Plantilla para Nuevo Componente

```markdown
### NuevoComponente (Atom)
**HU**: HU-XXX
**Ubicación**: `lib/shared/design_system/atoms/nuevo_componente.dart`
**Estado**: 🎨 Diseño

```dart
class NuevoComponente extends StatelessWidget {
  final String text;

  Widget build(BuildContext context) {
    return Text(
      text,
      style: DesignTypography.body1,
    );
  }
}
```
```
