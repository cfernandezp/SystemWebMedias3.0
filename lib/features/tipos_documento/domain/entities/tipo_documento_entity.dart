import 'package:equatable/equatable.dart';

enum TipoDocumentoFormato {
  numerico,
  alfanumerico;

  static TipoDocumentoFormato fromString(String value) {
    switch (value.toUpperCase()) {
      case 'NUMERICO':
        return TipoDocumentoFormato.numerico;
      case 'ALFANUMERICO':
        return TipoDocumentoFormato.alfanumerico;
      default:
        throw ArgumentError('Formato de documento inválido: $value');
    }
  }

  String toBackendString() {
    switch (this) {
      case TipoDocumentoFormato.numerico:
        return 'NUMERICO';
      case TipoDocumentoFormato.alfanumerico:
        return 'ALFANUMERICO';
    }
  }
}

class TipoDocumentoEntity extends Equatable {
  final String id;
  final String codigo;
  final String nombre;
  final TipoDocumentoFormato formato;
  final int longitudMinima;
  final int longitudMaxima;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TipoDocumentoEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.formato,
    required this.longitudMinima,
    required this.longitudMaxima,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        codigo,
        nombre,
        formato,
        longitudMinima,
        longitudMaxima,
        activo,
        createdAt,
        updatedAt,
      ];
}
