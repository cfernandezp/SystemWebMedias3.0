import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/producto_maestro_card.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/producto_maestro_filter_widget.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';

class ProductosMaestrosListPage extends StatelessWidget {
  const ProductosMaestrosListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductoMaestroBloc>()
        ..add(const ListarProductosMaestrosEvent()),
      child: const _ProductosMaestrosListView(),
    );
  }
}

class _ProductosMaestrosListView extends StatefulWidget {
  const _ProductosMaestrosListView();

  @override
  State<_ProductosMaestrosListView> createState() => _ProductosMaestrosListViewState();
}

class _ProductosMaestrosListViewState extends State<_ProductosMaestrosListView> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<ProductoMaestroBloc, ProductoMaestroState>(
        listener: (context, state) {
          if (state is ProductoMaestroError) {
            _showSnackbar(context, state.message, isError: true);
          }
          if (state is ProductoMaestroDeleted) {
            _showSnackbar(
              context,
              'Producto maestro eliminado exitosamente',
              isError: false,
            );
            context.read<ProductoMaestroBloc>().add(const ListarProductosMaestrosEvent());
          }
          if (state is ProductoMaestroDeactivated) {
            final message = state.affectedArticles > 0
                ? 'Producto desactivado junto con ${state.affectedArticles} artículos'
                : 'Producto desactivado exitosamente';
            _showSnackbar(context, message, isError: false);
            context.read<ProductoMaestroBloc>().add(const ListarProductosMaestrosEvent());
          }
          if (state is ProductoMaestroReactivated) {
            _showSnackbar(
              context,
              'Producto maestro reactivado exitosamente',
              isError: false,
            );
            context.read<ProductoMaestroBloc>().add(const ListarProductosMaestrosEvent());
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme, isDesktop),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                        label: Text(_showFilters ? 'Ocultar Filtros' : 'Mostrar Filtros'),
                      ),
                    ),
                    if (state is ProductoMaestroListLoaded && state.filtros != null) ...[
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () {
                          context.read<ProductoMaestroBloc>().add(
                            const ListarProductosMaestrosEvent(filtros: null),
                          );
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar Filtros'),
                      ),
                    ],
                  ],
                ),

                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  ProductoMaestroFilterWidget(
                    initialFilters: state is ProductoMaestroListLoaded ? state.filtros : null,
                    onApplyFilters: (filtros) {
                      context.read<ProductoMaestroBloc>().add(
                        ListarProductosMaestrosEvent(filtros: filtros),
                      );
                      setState(() {
                        _showFilters = false;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),

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
          if (authState is AuthAuthenticated && authState.user.isAdmin) {
            return FloatingActionButton.extended(
              onPressed: () {
                context.push(
                  '/producto-maestro-form',
                  extra: {'mode': 'create'},
                );
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Crear Producto Maestro'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos Maestros',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildBreadcrumbs(context),
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
          'Productos',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
    );
  }

  Widget _buildCounter(BuildContext context, ProductoMaestroState state) {
    int total = 0;
    int activos = 0;
    int inactivos = 0;

    if (state is ProductoMaestroListLoaded) {
      total = state.productos.length;
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
        '$total productos maestros ($activos activos / $inactivos inactivos)',
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

    if (state is ProductoMaestroListLoaded) {
      if (state.productos.isEmpty) {
        return _buildEmptyState();
      }

      if (isDesktop) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.productos.length,
          itemBuilder: (context, index) {
            final producto = state.productos[index];
            return ProductoMaestroCard(
              producto: producto,
              onEdit: () => _handleEdit(context, producto),
              onToggleStatus: () => _handleToggleStatus(context, producto),
              onDelete: () => _handleDelete(context, producto),
              onViewDetails: () => _handleViewDetails(context, producto),
            );
          },
        );
      } else {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.productos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final producto = state.productos[index];
            return ProductoMaestroCard(
              producto: producto,
              onEdit: () => _handleEdit(context, producto),
              onToggleStatus: () => _handleToggleStatus(context, producto),
              onDelete: () => _handleDelete(context, producto),
              onViewDetails: () => _handleViewDetails(context, producto),
            );
          },
        );
      }
    }

    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Text('Cargando productos maestros...'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16),
            Text(
              'No hay productos maestros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Comienza creando tu primer producto maestro',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context, producto) {
    context.push(
      '/producto-maestro-form',
      extra: {
        'mode': 'edit',
        'productoId': producto.id,
        'producto': producto,
      },
    );
  }

  void _handleViewDetails(BuildContext context, producto) {
    context.push(
      '/producto-maestro-detail',
      extra: {'productoId': producto.id},
    );
  }

  void _handleToggleStatus(BuildContext context, producto) {
    final isActive = producto.activo;
    final hasArticles = (producto.articulosTotales ?? 0) > 0;

    if (isActive && hasArticles) {
      showDialog(
        context: context,
        builder: (dialogContext) => _buildDeactivateCascadeDialog(
          context: dialogContext,
          productoId: producto.id,
          articulosActivos: producto.articulosActivos ?? 0,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => _buildConfirmationDialog(
          context: dialogContext,
          title: isActive ? 'Desactivar producto maestro?' : 'Reactivar producto maestro?',
          message: isActive
              ? 'El producto no aparecera en nuevos articulos'
              : 'El producto volvera a estar disponible',
          onConfirm: () {
            Navigator.pop(dialogContext);
            if (isActive) {
              context.read<ProductoMaestroBloc>().add(
                DesactivarProductoMaestroEvent(
                  productoId: producto.id,
                  desactivarArticulos: false,
                ),
              );
            } else {
              context.read<ProductoMaestroBloc>().add(
                ReactivarProductoMaestroEvent(producto.id),
              );
            }
          },
        ),
      );
    }
  }

  void _handleDelete(BuildContext context, producto) {
    final hasArticles = (producto.articulosTotales ?? 0) > 0;

    if (hasArticles) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: const Icon(Icons.warning, size: 48, color: Color(0xFFFF9800)),
          title: const Text('No se puede eliminar'),
          content: Text(
            'Este producto tiene ${producto.articulosTotales} articulos derivados. Solo puede desactivarlo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => _buildConfirmationDialog(
          context: dialogContext,
          title: 'Eliminar producto maestro?',
          message: 'Esta accion es permanente y no se puede deshacer',
          onConfirm: () {
            Navigator.pop(dialogContext);
            context.read<ProductoMaestroBloc>().add(
              EliminarProductoMaestroEvent(producto.id),
            );
          },
        ),
      );
    }
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

  Widget _buildDeactivateCascadeDialog({
    required BuildContext context,
    required String productoId,
    required int articulosActivos,
  }) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: const Icon(Icons.warning, size: 48, color: Color(0xFFFF9800)),
      title: const Text('Desactivar producto con articulos'),
      content: Text(
        'Este producto tiene $articulosActivos articulos activos. Que desea hacer?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<ProductoMaestroBloc>().add(
              DesactivarProductoMaestroEvent(
                productoId: productoId,
                desactivarArticulos: false,
              ),
            );
          },
          child: const Text('Solo producto'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<ProductoMaestroBloc>().add(
              DesactivarProductoMaestroEvent(
                productoId: productoId,
                desactivarArticulos: true,
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Producto + Articulos'),
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
