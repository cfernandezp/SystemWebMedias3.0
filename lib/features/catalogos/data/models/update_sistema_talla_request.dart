/// Request model para actualizar sistema de tallas.
///
/// Implementa E002-HU-004 (Gestionar Sistemas de Tallas).
/// Cumple CA-006: Editar Sistema Existente.
/// Cumple RN-004-07: Tipo de sistema no se puede modificar.
class UpdateSistemaTallaRequest {
  final String id;
  final String nombre;
  final String? descripcion;
  final bool? activo;

  const UpdateSistemaTallaRequest({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.activo,
  });

  /// Convierte a JSON para RPC
  Map<String, dynamic> toJson() {
    return {
      'p_id': id,
      'p_nombre': nombre,
      'p_descripcion': descripcion,
      'p_activo': activo,
    };
  }
}
