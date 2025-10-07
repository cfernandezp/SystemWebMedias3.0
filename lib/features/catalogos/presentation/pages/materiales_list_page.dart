import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection_container.dart' as di;
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../bloc/materiales_bloc.dart';
import '../bloc/materiales_event.dart';
import '../bloc/materiales_state.dart';
import '../widgets/material_card.dart';
import '../widgets/material_search_bar.dart';
import '../widgets/material_detail_modal.dart';
import '../widgets/material_toggle_confirm_dialog.dart';

/// Página principal de listado de materiales (CA-001)
///
/// Criterios de Aceptación:
/// - CA-001: Visualizar lista de materiales con nombre, descripción, código, estado
/// - CA-011: Búsqueda en tiempo real por nombre, descripción o código
/// - CA-008: Desactivar material con confirmación
/// - CA-010: Reactivar material
/// - CA-012: Vista detallada de material
class MaterialesListPage extends StatelessWidget {
  const MaterialesListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MaterialesBloc>()..add(const LoadMaterialesEvent()),
      child: const _MaterialesListView(),
    );
  }
}

class _MaterialesListView extends StatelessWidget {
  const _MaterialesListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<MaterialesBloc, MaterialesState>(
        listener: (context, state) {
          if (state is MaterialOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
            // Recargar lista después de operación exitosa
            context.read<MaterialesBloc>().add(const LoadMaterialesEvent());
          }

          if (state is MaterialesError) {
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
                if (state is MaterialesLoaded)
                  MaterialSearchBar(
                    onSearchChanged: (query) {
                      if (query.isEmpty) {
                        context.read<MaterialesBloc>().add(const LoadMaterialesEvent());
                      } else {
                        context.read<MaterialesBloc>().add(SearchMaterialesEvent(query));
                      }
                    },
                  ),

                if (state is MaterialesLoaded)
                  const SizedBox(height: 24),

                // Lista de materiales
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
    MaterialesState state,
  ) {
    int activosCount = 0;
    int inactivosCount = 0;

    if (state is MaterialesLoaded) {
      activosCount = state.materiales.where((m) => m.activo).length;
      inactivosCount = state.materiales.where((m) => !m.activo).length;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestionar Materiales',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state is MaterialesLoaded
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
          text: 'Agregar Nuevo Material',
          icon: Icons.add,
          onPressed: () {
            final bloc = context.read<MaterialesBloc>();
            context.push('/materiales-form', extra: {'bloc': bloc});
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, MaterialesState state, bool isDesktop) {
    if (state is MaterialesLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is MaterialesLoaded) {
      final materiales = state.materiales;
      final searchQuery = state.searchQuery ?? '';

      if (materiales.isEmpty) {
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
          itemCount: materiales.length,
          itemBuilder: (context, index) {
            final material = materiales[index];
            return MaterialCard(
              nombre: material.nombre,
              descripcion: material.descripcion,
              codigo: material.codigo,
              activo: material.activo,
              productosCount: material.productosCount ?? 0,
              onViewDetail: () => _handleViewDetail(context, material.id),
              onEdit: () => _handleEdit(context, material),
              onToggleStatus: () => _handleToggleStatus(context, material),
            );
          },
        );
      } else {
        return ListView.separated(
          itemCount: materiales.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final material = materiales[index];
            return MaterialCard(
              nombre: material.nombre,
              descripcion: material.descripcion,
              codigo: material.codigo,
              activo: material.activo,
              productosCount: material.productosCount ?? 0,
              onViewDetail: () => _handleViewDetail(context, material.id),
              onEdit: () => _handleEdit(context, material),
              onToggleStatus: () => _handleToggleStatus(context, material),
            );
          },
        );
      }
    }

    return const Center(
      child: Text('Cargando materiales...'),
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
            'No se encontraron materiales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Comienza agregando un nuevo material'
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

  void _handleViewDetail(BuildContext context, String materialId) {
    // CA-012: Mostrar modal con detalles y estadísticas
    context.read<MaterialesBloc>().add(LoadMaterialDetailEvent(materialId));

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MaterialesBloc>(),
        child: BlocBuilder<MaterialesBloc, MaterialesState>(
          builder: (context, state) {
            if (state is MaterialDetailLoaded) {
              return MaterialDetailModal(materialDetail: state.detail);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context, dynamic material) {
    final bloc = context.read<MaterialesBloc>();
    context.push(
      '/materiales-form',
      extra: {
        'mode': 'edit',
        'material': {
          'id': material.id,
          'nombre': material.nombre,
          'descripcion': material.descripcion,
          'codigo': material.codigo,
          'activo': material.activo,
        },
        'bloc': bloc,
      },
    );
  }

  void _handleToggleStatus(BuildContext context, dynamic material) {
    showDialog(
      context: context,
      builder: (dialogContext) => MaterialToggleConfirmDialog(
        isActive: material.activo,
        productosCount: material.productosCount ?? 0,
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<MaterialesBloc>().add(ToggleMaterialActivoEvent(material.id));
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
