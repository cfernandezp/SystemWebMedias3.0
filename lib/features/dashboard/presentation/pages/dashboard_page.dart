import 'package:flutter/material.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/vendedor_dashboard.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/gerente_dashboard.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/admin_dashboard.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/sales_line_chart.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/top_productos_list.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/top_vendedores_list.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/transacciones_recientes_list.dart';

/// DashboardPage (Page)
///
/// Página principal del dashboard que muestra el organism correcto según rol.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Routing flat: '/dashboard'
///
/// Características:
/// - BlocBuilder con polimorfismo según rol
/// - AppBar con botón refresh
/// - Loading skeleton mientras carga
/// - Manejo de errores con retry
///
/// NOTA: Temporalmente sin BLoC hasta implementación de backend
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  String _currentRole = 'VENDEDOR'; // Simular rol, luego vendrá del BLoC

  // Datos mock temporales
  late VendedorMetrics _vendedorMetrics;
  late GerenteMetrics _gerenteMetrics;
  late AdminMetrics _adminMetrics;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock data para vendedor
    _vendedorMetrics = VendedorMetrics(
      ventasHoy: 1250.50,
      tendenciaVentasHoy: 12.5,
      comisionesMes: 850.00,
      tendenciaComisiones: 8.3,
      productosStock: 145,
      productosStockBajo: 3,
      ordenesPendientes: 5,
      ventasPorMes: [
        const SalesChartData(mes: 'Oct', monto: 30000),
        const SalesChartData(mes: 'Nov', monto: 35000),
        const SalesChartData(mes: 'Dic', monto: 42000),
        const SalesChartData(mes: 'Ene', monto: 38000),
        const SalesChartData(mes: 'Feb', monto: 45000),
        const SalesChartData(mes: 'Mar', monto: 48000),
      ],
      topProductos: [
        const TopProducto(
          id: '1',
          nombre: 'Medias Deportivas Negras',
          cantidadVendida: 120,
          ranking: 1,
        ),
        const TopProducto(
          id: '2',
          nombre: 'Medias Ejecutivas Grises',
          cantidadVendida: 95,
          ranking: 2,
        ),
        const TopProducto(
          id: '3',
          nombre: 'Medias Casuales Blancas',
          cantidadVendida: 80,
          ranking: 3,
        ),
      ],
    );

    // Mock data para gerente
    _gerenteMetrics = GerenteMetrics(
      ventasMesActual: 35000,
      tendenciaVentas: 15.2,
      clientesActivos: 245,
      tendenciaClientes: 8.7,
      productosStock: 450,
      productosStockBajo: 12,
      ordenesPendientes: 18,
      metaMensual: 50000,
      ventasPorMes: [
        const SalesChartData(mes: 'Oct', monto: 45000),
        const SalesChartData(mes: 'Nov', monto: 48000),
        const SalesChartData(mes: 'Dic', monto: 52000),
        const SalesChartData(mes: 'Ene', monto: 46000),
        const SalesChartData(mes: 'Feb', monto: 51000),
        const SalesChartData(mes: 'Mar', monto: 53000),
      ],
      topVendedores: [
        const TopVendedor(
          id: '1',
          nombreCompleto: 'Juan Pérez',
          montoVentas: 15000,
          cantidadTransacciones: 50,
          ranking: 1,
        ),
        const TopVendedor(
          id: '2',
          nombreCompleto: 'María González',
          montoVentas: 12000,
          cantidadTransacciones: 45,
          ranking: 2,
        ),
      ],
      transaccionesRecientes: [
        TransaccionReciente(
          id: '1',
          clienteNombre: 'Carlos Ramírez',
          vendedorNombre: 'Juan Pérez',
          monto: 1250.50,
          fecha: DateTime.now().subtract(const Duration(hours: 2)),
          estado: TransaccionEstado.completada,
        ),
        TransaccionReciente(
          id: '2',
          clienteNombre: 'Ana López',
          vendedorNombre: 'María González',
          monto: 850.00,
          fecha: DateTime.now().subtract(const Duration(hours: 3)),
          estado: TransaccionEstado.pendiente,
        ),
      ],
    );

    // Mock data para admin
    _adminMetrics = AdminMetrics(
      ventasTotales: 250000,
      tendenciaVentas: 18.5,
      clientesActivos: 1245,
      tendenciaClientes: 12.3,
      ordenesPendientes: 48,
      tiendasActivas: 5,
      productosStockCritico: 8,
      usuariosActivos: 25,
      ventasPorMes: [
        const SalesChartData(mes: 'Oct', monto: 220000),
        const SalesChartData(mes: 'Nov', monto: 235000),
        const SalesChartData(mes: 'Dic', monto: 270000),
        const SalesChartData(mes: 'Ene', monto: 245000),
        const SalesChartData(mes: 'Feb', monto: 260000),
        const SalesChartData(mes: 'Mar', monto: 280000),
      ],
      topProductos: [
        const TopProducto(
          id: '1',
          nombre: 'Medias Deportivas Negras',
          cantidadVendida: 450,
          ranking: 1,
        ),
        const TopProducto(
          id: '2',
          nombre: 'Medias Ejecutivas Grises',
          cantidadVendida: 380,
          ranking: 2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Actualizar datos',
          ),
          // Botón temporal para cambiar de rol (demo)
          PopupMenuButton<String>(
            icon: const Icon(Icons.swap_horiz),
            onSelected: (role) {
              setState(() {
                _currentRole = role;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'VENDEDOR',
                child: Text('Ver como Vendedor'),
              ),
              const PopupMenuItem(
                value: 'GERENTE',
                child: Text('Ver como Gerente'),
              ),
              const PopupMenuItem(
                value: 'ADMIN',
                child: Text('Ver como Admin'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    // Polimorfismo según rol
    switch (_currentRole) {
      case 'VENDEDOR':
        return VendedorDashboard(
          metrics: _vendedorMetrics,
          isLoading: _isLoading,
        );
      case 'GERENTE':
        return GerenteDashboard(
          metrics: _gerenteMetrics,
          isLoading: _isLoading,
        );
      case 'ADMIN':
        return AdminDashboard(
          metrics: _adminMetrics,
          isLoading: _isLoading,
        );
      default:
        return _buildError();
    }
  }

  Widget _buildLoadingSkeleton() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando métricas...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFF44336),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar el dashboard',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
