import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/catalogos/data/models/sistema_talla_model.dart';

class ValorTallaModel extends Equatable {
  final String id;
  final String valor;
  final int orden;
  final SistemaTallaModel? sistemaTalla;

  const ValorTallaModel({
    required this.id,
    required this.valor,
    required this.orden,
    this.sistemaTalla,
  });

  factory ValorTallaModel.fromJson(Map<String, dynamic> json) {
    SistemaTallaModel? sistema;
    if (json['sistema_talla'] != null) {
      sistema = SistemaTallaModel.fromJson(json['sistema_talla'] as Map<String, dynamic>);
    }

    return ValorTallaModel(
      id: json['id'] as String? ?? '',
      valor: json['valor'] as String? ?? '',
      orden: json['orden'] as int? ?? 0,
      sistemaTalla: sistema,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valor': valor,
      'orden': orden,
      if (sistemaTalla != null) 'sistema_talla': sistemaTalla!.toJson(),
    };
  }

  ValorTallaModel copyWith({
    String? id,
    String? valor,
    int? orden,
    SistemaTallaModel? sistemaTalla,
  }) {
    return ValorTallaModel(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      orden: orden ?? this.orden,
      sistemaTalla: sistemaTalla ?? this.sistemaTalla,
    );
  }

  @override
  List<Object?> get props => [id, valor, orden, sistemaTalla];
}
