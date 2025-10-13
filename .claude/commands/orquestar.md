---
description: Comando para orquestar la implementación de HUs coordinando todos los agentes especializados
enabled: true
agent: workflow-architect-expert
---

# Comando: /orquestar

Este comando invoca al **workflow-architect-expert** para coordinar la implementación completa de una Historia de Usuario.

## Uso

```
/orquestar [ID-HU] [opciones]
```

## Parámetros

- `ID-HU`: Identificador de la Historia de Usuario (ej: E002-HU-006)
- `opciones`:
  - `--fast`: Ejecuta workflow rápido (sin diseño previo)
  - `--design-only`: Solo fase de diseño
  - `--parallel`: Ejecuta tareas en paralelo cuando sea posible
  - `--full`: Workflow completo con todas las fases

## Ejemplos

```bash
# Implementación completa de una HU
/orquestar E002-HU-006

# Solo diseñar sin implementar
/orquestar E002-HU-006 --design-only

# Implementación rápida (CRUD simple)
/orquestar E002-HU-007 --fast
```

## Lo que hace el workflow-architect-expert:

1. ✅ Lee y analiza la Historia de Usuario
2. ✅ Diseña el pipeline óptimo de implementación
3. ✅ Invoca agentes en orden correcto (secuencial o paralelo)
4. ✅ Valida Quality Gates entre fases
5. ✅ Gestiona errores y re-ejecuta cuando sea necesario
6. ✅ Genera reporte final de implementación

## Agentes que puede coordinar:

- **po-user-stories-template**: Creación/refinamiento de HUs
- **negocio-medias-expert**: Análisis de reglas de negocio
- **ux-ui-expert**: Diseño de interfaces
- **supabase-expert**: Backend y base de datos
- **flutter-expert**: Frontend Flutter Web
- **qa-testing-expert**: Testing end-to-end
- **web-architect-expert**: Validación de arquitectura