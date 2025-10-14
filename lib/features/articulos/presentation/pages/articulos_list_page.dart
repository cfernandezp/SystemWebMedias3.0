import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_event.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_state.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_bloc.dart';
import 'package:system_web_medias/features/articulos/presentation/widgets/articulo_card.dart';
import 'package:system_web_medias/features/articulos/presentation/widgets/articulo_search_bar.dart';
import 'package:system_web_medias/features/articulos/data/models/filtros_articulos_model.dart';

class ArticulosListPage extends StatelessWidget {
  const ArticulosListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ArticulosBloc>()..add(const ListarArticulosEvent()),
      child: const _ArticulosListView(),
    );
  }
}

class _ArticulosListView extends StatelessWidget {
  const _ArticulosListView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<ArticulosBloc, ArticulosState>(
        listener: (context, state) {
          if (state is ArticuloOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
          }
          if (state is ArticulosError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDesktop),
                const SizedBox(height: 24),
                ArticuloSearchBar(
                  onSearchChanged: (query) {
                    if (state is ArticulosLoaded || state is ArticuloOperationSuccess) {
                      context.read<ArticulosBloc>().add(
                        ListarArticulosEvent(
                          filtros: FiltrosArticulosModel(
                            searchText: query.isEmpty ? null : query,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
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
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isAdmin = authState is AuthAuthenticated && authState.user.rol.toString().contains('admin');
          if (!isAdmin) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => context.push('/articulo-form'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Crear Artículo'),
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
          'Artículos Especializados',
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
              'Artículos',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounter(BuildContext context, ArticulosState state) {
    int activos = 0;
    int inactivos = 0;

    if (state is ArticulosLoaded) {
      activos = state.articulos.where((a) => a.activo).length;
      inactivos = state.articulos.where((a) => !a.activo).length;
    } else if (state is ArticuloOperationSuccess) {
      activos = state.articulos.where((a) => a.activo).length;
      inactivos = state.articulos.where((a) => !a.activo).length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$activos artículos activos / $inactivos inactivos',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArticulosState state, bool isDesktop) {
    if (state is ArticulosLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ArticulosLoaded || state is ArticuloOperationSuccess) {
      final articulos = state is ArticulosLoaded
          ? state.articulos
          : (state as ArticuloOperationSuccess).articulos;

      if (articulos.isEmpty) {
        return _buildEmptyState(context);
      }

      if (isDesktop) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: articulos.length,
          itemBuilder: (context, index) => ArticuloCard(articulo: articulos[index]),
        );
      } else {
        return ListView.separated(
          itemCount: articulos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => ArticuloCard(articulo: articulos[index]),
        );
      }
    }

    if (state is ArticulosError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
            const SizedBox(height: 16),
            const Text('Error al cargar artículos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(state.message, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<ArticulosBloc>().add(const ListarArticulosEvent()),
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
          const Icon(Icons.inventory_outlined, size: 80, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 24),
          const Text(
            'No hay artículos especializados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Crea el primer artículo especializado\ncombinando un producto maestro con colores',
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