import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection_container.dart' as di;
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../bloc/tipos_bloc.dart';
import '../bloc/tipos_event.dart';
import '../bloc/tipos_state.dart';
import '../widgets/tipo_card.dart';
import '../widgets/tipo_search_bar.dart';
import '../widgets/tipo_detail_modal.dart';
import '../widgets/tipo_toggle_confirm_dialog.dart';

/// Página principal de listado de tipos (CA-001)
///
/// Criterios de Aceptación:
/// - CA-001: Visualizar lista de tipos con nombre, descripción, código, estado
/// - CA-011: Búsqueda en tiempo real por nombre, descripción o código
/// - CA-008: Desactivar tipo con confirmación
/// - CA-010: Reactivar tipo
/// - CA-012: Vista detallada de tipo
class TiposListPage extends StatelessWidget {
  const TiposListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TiposBloc>()..add(const LoadTiposEvent()),
      child: const _TiposListView(),
    );
  }
}

class _TiposListView extends StatelessWidget {
  const _TiposListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<TiposBloc, TiposState>(
        listener: (context, state) {
          if (state is TipoOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
            // Recargar lista después de operación exitosa
            context.read<TiposBloc>().add(const LoadTiposEvent());
          }

          if (state is TiposError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, theme, isDesktop, state),
                const SizedBox(height: 24),

                // Search bar
                if (state is TiposLoaded)
                  TipoSearchBar(
                    onSearchChanged: (query) {
                      if (query.isEmpty) {
                        context.read<TiposBloc>().add(const LoadTiposEvent());
                      } else {
                        context.read<TiposBloc>().add(SearchTiposEvent(query));
                      }
                    },
                  ),

                if (state is TiposLoaded)
                  const SizedBox(height: 24),

                // Lista de tipos
                Expanded(
                  child: _buildContent(context, state, isDesktop),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isDesktop,
    TiposState state,
  ) {
    int activosCount = 0;
    int inactivosCount = 0;

    if (state is TiposLoaded) {
      activosCount = state.tipos.where((t) => t.activo).length;
      inactivosCount = state.tipos.where((t) => !t.activo).length;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catálogo de Tipos',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state is TiposLoaded
                  ? '$activosCount activos / $inactivosCount inactivos'
                  : 'Cargando...',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        CorporateButton(
          text: 'Agregar Nuevo Tipo',
          icon: Icons.add,
          onPressed: () {
            final bloc = context.read<TiposBloc>();
            context.push('/tipos-form', extra: {'bloc': bloc});
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, TiposState state, bool isDesktop) {
    if (state is TiposLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is TiposLoaded) {
      final tipos = state.tipos;
      final searchQuery = state.searchQuery ?? '';

      if (tipos.isEmpty) {
        return _buildEmptyState(searchQuery);
      }

      if (isDesktop) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: tipos.length,
          itemBuilder: (context, index) {
            final tipo = tipos[index];
            return TipoCard(
              nombre: tipo.nombre,
              descripcion: tipo.descripcion,
              codigo: tipo.codigo,
              activo: tipo.activo,
              imagenUrl: tipo.imagenUrl,
              productosCount: tipo.productosCount ?? 0,
              onViewDetail: () => _handleViewDetail(context, tipo.id),
              onEdit: () => _handleEdit(context, tipo),
              onToggleStatus: () => _handleToggleStatus(context, tipo),
            );
          },
        );
      } else {
        return ListView.separated(
          itemCount: tipos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tipo = tipos[index];
            return TipoCard(
              nombre: tipo.nombre,
              descripcion: tipo.descripcion,
              codigo: tipo.codigo,
              activo: tipo.activo,
              imagenUrl: tipo.imagenUrl,
              productosCount: tipo.productosCount ?? 0,
              onViewDetail: () => _handleViewDetail(context, tipo.id),
              onEdit: () => _handleEdit(context, tipo),
              onToggleStatus: () => _handleToggleStatus(context, tipo),
            );
          },
        );
      }
    }

    return const Center(
      child: Text('Cargando tipos...'),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron tipos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Comienza agregando un nuevo tipo'
                : 'Intenta con otro criterio de búsqueda',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  void _handleViewDetail(BuildContext context, String tipoId) {
    // CA-012: Mostrar modal con detalles y estadísticas
    context.read<TiposBloc>().add(LoadTipoDetailEvent(tipoId));

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TiposBloc>(),
        child: BlocBuilder<TiposBloc, TiposState>(
          builder: (context, state) {
            if (state is TipoDetailLoaded) {
              return TipoDetailModal(tipoDetail: state.detail);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context, dynamic tipo) {
    final bloc = context.read<TiposBloc>();
    context.push(
      '/tipos-form',
      extra: {
        'mode': 'edit',
        'tipo': {
          'id': tipo.id,
          'nombre': tipo.nombre,
          'descripcion': tipo.descripcion,
          'codigo': tipo.codigo,
          'imagenUrl': tipo.imagenUrl,
          'activo': tipo.activo,
        },
        'bloc': bloc,
      },
    );
  }

  void _handleToggleStatus(BuildContext context, dynamic tipo) {
    showDialog(
      context: context,
      builder: (dialogContext) => TipoToggleConfirmDialog(
        isActive: tipo.activo,
        productosCount: tipo.productosCount ?? 0,
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<TiposBloc>().add(ToggleTipoActivoEvent(tipo.id));
        },
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
