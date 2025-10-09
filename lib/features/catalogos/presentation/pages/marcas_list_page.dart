import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/marca_card.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/marca_search_bar.dart';

/// Página principal de listado de marcas (CA-001)
///
/// Criterios de Aceptación:
/// - CA-001: Visualizar lista de marcas con nombre, código, estado
/// - CA-011: Búsqueda en tiempo real por nombre o código
/// - CA-008: Desactivar marca con confirmación
/// - CA-010: Reactivar marca
class MarcasListPage extends StatelessWidget {
  const MarcasListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MarcasBloc>()..add(const LoadMarcas()),
      child: const _MarcasListView(),
    );
  }
}

class _MarcasListView extends StatelessWidget {
  const _MarcasListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<MarcasBloc, MarcasState>(
        listener: (context, state) {
          // Manejar MarcaOperationSuccess
          if (state is MarcaOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
          }

          // Manejar MarcasError
          if (state is MarcasError) {
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
                if (state is MarcasLoaded || state is MarcaOperationSuccess)
                  MarcaSearchBar(
                    onSearchChanged: (query) {
                      context.read<MarcasBloc>().add(SearchMarcas(query));
                    },
                  ),

                if (state is MarcasLoaded || state is MarcaOperationSuccess) const SizedBox(height: 16),

                // Counter
                _buildCounter(context, state),
                const SizedBox(height: 24),

                // Lista de marcas
                Expanded(
                  child: _buildContent(context, state, isDesktop),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final bloc = context.read<MarcasBloc>();
          context.push('/marca-form', extra: {'bloc': bloc});
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Marca'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isDesktop,
    MarcasState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestionar Marcas',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildBreadcrumbs(context),
          ],
        ),
      ],
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
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
          'Catálogos',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('>', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ),
        const Text(
          'Marcas',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCounter(BuildContext context, MarcasState state) {
    int activas = 0;
    int inactivas = 0;

    if (state is MarcasLoaded) {
      activas = state.marcasActivas;
      inactivas = state.marcasInactivas;
    } else if (state is MarcaOperationSuccess) {
      activas = state.marcas.where((m) => m.activo).length;
      inactivas = state.marcas.where((m) => !m.activo).length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$activas marcas activas / $inactivas inactivas',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarcasState state, bool isDesktop) {
    if (state is MarcasLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Renderizar lista tanto para MarcasLoaded como MarcaOperationSuccess
    if (state is MarcasLoaded || state is MarcaOperationSuccess) {
      final marcas = state is MarcasLoaded
          ? state.filteredMarcas
          : (state as MarcaOperationSuccess).marcas;
      final searchQuery = state is MarcasLoaded ? state.searchQuery : '';

      if (marcas.isEmpty) {
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
          itemCount: marcas.length,
          itemBuilder: (context, index) {
            final marca = marcas[index];
            return MarcaCard(
              nombre: marca.nombre,
              codigo: marca.codigo,
              activo: marca.activo,
              onEdit: () => _handleEdit(context, marca.id, {
                'id': marca.id,
                'nombre': marca.nombre,
                'codigo': marca.codigo,
                'activo': marca.activo,
              }),
              onToggleStatus: () => _handleToggleStatus(context, marca.id, marca.activo),
            );
          },
        );
      } else {
        return ListView.separated(
          itemCount: marcas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final marca = marcas[index];
            return MarcaCard(
              nombre: marca.nombre,
              codigo: marca.codigo,
              activo: marca.activo,
              onEdit: () => _handleEdit(context, marca.id, {
                'id': marca.id,
                'nombre': marca.nombre,
                'codigo': marca.codigo,
                'activo': marca.activo,
              }),
              onToggleStatus: () => _handleToggleStatus(context, marca.id, marca.activo),
            );
          },
        );
      }
    }

    // Estado inicial o error
    return const Center(
      child: Text('Cargando marcas...'),
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
            'No se encontraron marcas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Comienza agregando una nueva marca'
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

  void _handleEdit(BuildContext context, String marcaId, Map<String, dynamic> marcaData) {
    // Pasar la instancia del Bloc para compartir estado
    final bloc = context.read<MarcasBloc>();
    context.push(
      '/marca-form',
      extra: {
        'mode': 'edit',
        'marca': marcaData,
        'bloc': bloc,
      },
    );
  }

  void _handleToggleStatus(BuildContext context, String marcaId, bool isActive) {
    showDialog(
      context: context,
      builder: (dialogContext) => _buildConfirmationDialog(
        context: dialogContext,
        title: isActive ? '¿Desactivar marca?' : '¿Reactivar marca?',
        message: isActive
            ? 'Los productos existentes no se verán afectados'
            : 'La marca volverá a estar disponible para nuevos productos',
        onConfirm: () {
          Navigator.pop(dialogContext);
          // Llamar a BLoC para toggle_marca
          context.read<MarcasBloc>().add(ToggleMarca(marcaId));
        },
      ),
    );
  }

  Widget _buildConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Confirmar'),
        ),
      ],
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
