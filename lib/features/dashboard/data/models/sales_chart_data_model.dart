import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';

class SalesChartDataModel extends SalesChartData {
  const SalesChartDataModel({
    required super.mes,
    required super.ventas,
  });

  factory SalesChartDataModel.fromJson(Map<String, dynamic> json) {
    return SalesChartDataModel(
      mes: json['mes'] as String,
      ventas: (json['ventas'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'ventas': ventas,
    };
  }
}
