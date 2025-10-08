/// Request model para crear sistema de tallas.
///
/// Implementa E002-HU-004 (Gestionar Sistemas de Tallas).
/// Cumple CA-002: Agregar Nuevo Sistema de Tallas.
class CreateSistemaTallaRequest {
  final String nombre;
  final String tipoSistema;
  final String? descripcion;
  final List<String> valores;
  final bool activo;

  const CreateSistemaTallaRequest({
    required this.nombre,
    required this.tipoSistema,
    this.descripcion,
    required this.valores,
    this.activo = true,
  });

  /// Convierte a JSON para RPC (camelCase → snake_case)
  Map<String, dynamic> toJson() {
    return {
      'p_nombre': nombre,
      'p_tipo_sistema': tipoSistema,                    // ⭐ camelCase → snake_case
      'p_descripcion': descripcion,
      'p_valores': valores,
      'p_activo': activo,
    };
  }
}
