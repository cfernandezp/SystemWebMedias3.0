import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/producto_maestro_card.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/producto_maestro_filter_widget.dart';

class ProductosMaestrosListPage extends StatelessWidget {
  const ProductosMaestrosListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductoMaestroBloc>()..add(const ListarProductosMaestrosEvent()),
      child: const _ProductosMaestrosListView(),
    );
  }
}

class _ProductosMaestrosListView extends StatelessWidget {
  const _ProductosMaestrosListView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<ProductoMaestroBloc, ProductoMaestroState>(
        listener: (context, state) {
          if (state is ProductoMaestroOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
          }
          if (state is ProductoMaestroError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDesktop),
                const SizedBox(height: 24),
                ProductoMaestroFilterWidget(
                  onFilterChanged: (filters) {
                    context.read<ProductoMaestroBloc>().add(ListarProductosMaestrosEvent(filtros: filters));
                  },
                ),
                const SizedBox(height: 16),
                _buildCounter(context, state),
                const SizedBox(height: 24),
                _buildContent(context, state, isDesktop),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isAdmin = authState is AuthAuthenticated && authState.user.rol.toString().contains('admin');
          if (!isAdmin) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => context.push('/producto-maestro-form'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Crear Producto'),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos Maestros',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: () => context.go('/dashboard'),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('>', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            ),
            const Text(
              'Productos Maestros',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounter(BuildContext context, ProductoMaestroState state) {
    int activos = 0;
    int inactivos = 0;

    if (state is ProductoMaestroLoaded) {
      activos = state.productos.where((p) => p.activo).length;
      inactivos = state.productos.where((p) => !p.activo).length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$activos productos activos / $inactivos inactivos',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductoMaestroState state, bool isDesktop) {
    if (state is ProductoMaestroLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ProductoMaestroLoaded) {
      if (state.productos.isEmpty) {
        return _buildEmptyState(context);
      }

      if (isDesktop) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.productos.length,
          itemBuilder: (context, index) => ProductoMaestroCard(producto: state.productos[index]),
        );
      } else {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.productos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => ProductoMaestroCard(producto: state.productos[index]),
        );
      }
    }

    if (state is ProductoMaestroError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
            const SizedBox(height: 16),
            const Text('Error al cargar productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(state.message, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<ProductoMaestroBloc>().add(const ListarProductosMaestrosEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 24),
          const Text(
            'No hay productos maestros',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Crea el primer producto maestro\ncombinando marca, material, tipo y tallas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
