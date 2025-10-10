import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/color_card.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/color_search_bar.dart';

class ColoresListPage extends StatelessWidget {
  const ColoresListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ColoresBloc>()..add(const LoadColores()),
      child: const _ColoresListView(),
    );
  }
}

class _ColoresListView extends StatelessWidget {
  const _ColoresListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<ColoresBloc, ColoresState>(
        listener: (context, state) {
          if (state is ColorOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
          }

          if (state is ColoresError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme, isDesktop, state),
                const SizedBox(height: 24),

                if (state is ColoresLoaded || state is ColorOperationSuccess)
                  ColorSearchBar(
                    onSearchChanged: (query) {
                      context.read<ColoresBloc>().add(SearchColores(query));
                    },
                  ),

                if (state is ColoresLoaded || state is ColorOperationSuccess) const SizedBox(height: 16),

                _buildCounter(context, state),
                const SizedBox(height: 24),

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
          final bloc = context.read<ColoresBloc>();
          context.push('/color-form', extra: {'bloc': bloc});
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Color'),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isDesktop,
    ColoresState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catálogo de Colores',
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
        if (isDesktop)
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/filtrar-combinacion');
                },
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Filtrar por Combinación'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/colores-estadisticas');
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Ver Estadísticas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
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
          'Colores',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCounter(BuildContext context, ColoresState state) {
    int activos = 0;
    int inactivos = 0;

    if (state is ColoresLoaded) {
      activos = state.coloresActivos;
      inactivos = state.coloresInactivos;
    } else if (state is ColorOperationSuccess) {
      activos = state.colores.where((c) => c.activo).length;
      inactivos = state.colores.where((c) => !c.activo).length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$activos colores activos / $inactivos inactivos',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColoresState state, bool isDesktop) {
    if (state is ColoresLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is ColoresLoaded || state is ColorOperationSuccess) {
      final colores = state is ColoresLoaded
          ? state.filteredColores
          : (state as ColorOperationSuccess).colores;
      final searchQuery = state is ColoresLoaded ? state.searchQuery : '';

      if (colores.isEmpty) {
        return _buildEmptyState(searchQuery);
      }

      if (isDesktop) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: colores.length,
          itemBuilder: (context, index) {
            final color = colores[index];
            return ColorCard(
              nombre: color.nombre,
              codigoHex: color.codigoHexPrimario,
              activo: color.activo,
              productosCount: color.productosCount,
              onEdit: () => _handleEdit(context, color.id, {
                'id': color.id,
                'nombre': color.nombre,
                'codigosHex': color.codigosHex,
                'activo': color.activo,
              }),
              onDelete: () => _handleDelete(context, color.id, color.nombre, color.productosCount),
            );
          },
        );
      } else {
        return ListView.separated(
          itemCount: colores.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final color = colores[index];
            return ColorCard(
              nombre: color.nombre,
              codigoHex: color.codigoHexPrimario,
              activo: color.activo,
              productosCount: color.productosCount,
              onEdit: () => _handleEdit(context, color.id, {
                'id': color.id,
                'nombre': color.nombre,
                'codigosHex': color.codigosHex,
                'activo': color.activo,
              }),
              onDelete: () => _handleDelete(context, color.id, color.nombre, color.productosCount),
            );
          },
        );
      }
    }

    return const Center(
      child: Text('Cargando colores...'),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.palette_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron colores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Comienza agregando un nuevo color'
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

  void _handleEdit(BuildContext context, String colorId, Map<String, dynamic> colorData) {
    final bloc = context.read<ColoresBloc>();
    context.push(
      '/color-form',
      extra: {
        'mode': 'edit',
        'color': colorData,
        'bloc': bloc,
      },
    );
  }

  void _handleDelete(BuildContext context, String colorId, String nombre, int productosCount) {
    final bool enUso = productosCount > 0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(enUso ? '¿Desactivar color?' : '¿Eliminar color?'),
        content: Text(
          enUso
              ? 'El color "$nombre" está en uso en $productosCount producto${productosCount == 1 ? '' : 's'}. Se desactivará en lugar de eliminarse.'
              : '¿Estás seguro de eliminar permanentemente el color "$nombre"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ColoresBloc>().add(DeleteColorEvent(colorId));
            },
            style: FilledButton.styleFrom(
              backgroundColor: enUso ? Colors.orange : Colors.red,
            ),
            child: Text(enUso ? 'Desactivar' : 'Eliminar'),
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
