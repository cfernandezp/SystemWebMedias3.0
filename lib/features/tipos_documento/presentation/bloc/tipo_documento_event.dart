import 'package:equatable/equatable.dart';

abstract class TipoDocumentoEvent extends Equatable {
  const TipoDocumentoEvent();

  @override
  List<Object?> get props => [];
}

class ListarTiposDocumentoEvent extends TipoDocumentoEvent {
  final bool incluirInactivos;

  const ListarTiposDocumentoEvent({this.incluirInactivos = false});

  @override
  List<Object?> get props => [incluirInactivos];
}

class CrearTipoDocumentoEvent extends TipoDocumentoEvent {
  final String codigo;
  final String nombre;
  final String formato;
  final int longitudMinima;
  final int longitudMaxima;

  const CrearTipoDocumentoEvent({
    required this.codigo,
    required this.nombre,
    required this.formato,
    required this.longitudMinima,
    required this.longitudMaxima,
  });

  @override
  List<Object?> get props => [
        codigo,
        nombre,
        formato,
        longitudMinima,
        longitudMaxima,
      ];
}

class ActualizarTipoDocumentoEvent extends TipoDocumentoEvent {
  final String id;
  final String codigo;
  final String nombre;
  final String formato;
  final int longitudMinima;
  final int longitudMaxima;
  final bool activo;

  const ActualizarTipoDocumentoEvent({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.formato,
    required this.longitudMinima,
    required this.longitudMaxima,
    required this.activo,
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
      ];
}

class EliminarTipoDocumentoEvent extends TipoDocumentoEvent {
  final String id;

  const EliminarTipoDocumentoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ValidarFormatoDocumentoEvent extends TipoDocumentoEvent {
  final String tipoDocumentoId;
  final String numeroDocumento;

  const ValidarFormatoDocumentoEvent({
    required this.tipoDocumentoId,
    required this.numeroDocumento,
  });

  @override
  List<Object?> get props => [tipoDocumentoId, numeroDocumento];
}
