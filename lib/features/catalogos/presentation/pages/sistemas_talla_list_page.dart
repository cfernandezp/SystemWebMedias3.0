import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection_container.dart';
import '../../data/models/sistema_talla_model.dart';
import '../bloc/sistemas_talla/sistemas_talla_bloc.dart';
import '../bloc/sistemas_talla/sistemas_talla_event.dart';
import '../bloc/sistemas_talla/sistemas_talla_state.dart';
import '../widgets/sistema_talla_card.dart';
import '../widgets/sistema_talla_valores_modal.dart';

/// Página principal de listado de sistemas de tallas (CA-001, CA-012)
///
/// Criterios de Aceptación:
/// - CA-001: Visualizar lista de sistemas de tallas con filtros y búsqueda
/// - CA-012: Búsqueda en tiempo real por nombre
/// - CA-011: Desactivar sistema con confirmación
class SistemasTallaListPage extends StatelessWidget {
  const SistemasTallaListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SistemasTallaBloc>()
        ..add(LoadSistemasTallaEvent()),
      child: const _SistemasTallaListPageContent(),
    );
  }
}

class _SistemasTallaListPageContent extends StatefulWidget {
  const _SistemasTallaListPageContent({Key? key}) : super(key: key);

  @override
  State<_SistemasTallaListPageContent> createState() => _SistemasTallaListPageContentState();
}

class _SistemasTallaListPageContentState extends State<_SistemasTallaListPageContent> {
  String? _tipoFilter;
  bool? _activoFilter;
  String? _searchQuery;

  void _loadData() {
    context.read<SistemasTallaBloc>().add(LoadSistemasTallaEvent(
      search: _searchQuery,
      tipoFilter: _tipoFilter,
      activoFilter: _activoFilter,
    ));
  }

  void _handleEdit(BuildContext context, SistemaTallaModel sistema) {
    final bloc = context.read<SistemasTallaBloc>();
    context.push(
      '/sistemas-talla-form',
      extra: {
        'mode': 'edit',
        'sistema': {
          'id': sistema.id,
          'nombre': sistema.nombre,
          'tipo_sistema': sistema.tipoSistema,
          'descripcion': sistema.descripcion,
          'activo': sistema.activo,
        },
        'bloc': bloc,
      },
    );
  }

  void _showValoresModal(BuildContext context, SistemaTallaModel sistema) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SistemasTallaBloc>(),
        child: BlocBuilder<SistemasTallaBloc, SistemasTallaState>(
          builder: (context, state) {
            if (state is SistemaTallaValoresLoaded) {
              return SistemaTallaValoresModal(
                nombre: state.sistema.nombre,
                tipoSistema: state.sistema.tipoSistema,
                descripcion: state.sistema.descripcion,
                valores: state.valores.map((v) => {
                  'id': v.id,
                  'valor': v.valor,
                  'orden': v.orden,
                  'activo': v.activo,
                  'productosCount': v.productosCount,
                }).toList(),
                onEdit: () {
                  Navigator.of(dialogContext).pop();
                  _handleEdit(context, state.sistema);
                },
              );
            }

            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(24),
                height: 200,
                child: const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<SistemasTallaBloc, SistemasTallaState>(
        listener: (context, state) {
          if (state is SistemasTallaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme, isDesktop),
                const SizedBox(height: 24),
                _buildSearchAndFilters(context),
                const SizedBox(height: 16),
                _buildCounter(context, state),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildContent(context, isDesktop, state),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('sistemas-talla-form');
        },
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Sistema'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistemas de Tallas',
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
          'Sistemas de Tallas',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre...',
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.isEmpty ? null : value;
              });
              _loadData();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _tipoFilter,
            decoration: InputDecoration(
              labelText: 'Tipo',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: 'UNICA', child: Text('ÚNICA')),
              DropdownMenuItem(value: 'NUMERO', child: Text('NÚMERO')),
              DropdownMenuItem(value: 'LETRA', child: Text('LETRA')),
              DropdownMenuItem(value: 'RANGO', child: Text('RANGO')),
            ],
            onChanged: (value) {
              setState(() {
                _tipoFilter = value;
              });
              _loadData();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<bool>(
            initialValue: _activoFilter,
            decoration: InputDecoration(
              labelText: 'Estado',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: true, child: Text('Activos')),
              DropdownMenuItem(value: false, child: Text('Inactivos')),
            ],
            onChanged: (value) {
              setState(() {
                _activoFilter = value;
              });
              _loadData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(BuildContext context, SistemasTallaState state) {
    int activos = 0;
    int inactivos = 0;

    if (state is SistemasTallaLoaded) {
      activos = state.sistemas.where((s) => s.activo).length;
      inactivos = state.sistemas.where((s) => !s.activo).length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$activos sistemas activos / $inactivos inactivos',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop, SistemasTallaState state) {
    if (state is SistemasTallaLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SistemasTallaLoaded) {
      if (state.sistemas.isEmpty) {
        return _buildEmptyState(context);
      }

      return isDesktop
        ? _buildDesktopGrid(state.sistemas)
        : _buildMobileList(state.sistemas);
    }

    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.straighten,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay sistemas de tallas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comienza agregando un nuevo sistema',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopGrid(List<SistemaTallaModel> sistemas) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: sistemas.length,
      itemBuilder: (context, index) {
        final sistema = sistemas[index];
        return SistemaTallaCard(
          nombre: sistema.nombre,
          tipoSistema: sistema.tipoSistema,
          descripcion: sistema.descripcion,
          activo: sistema.activo,
          valoresCount: sistema.valoresCount,
          productosCount: 0, // Placeholder hasta HU productos
          onViewDetail: () {
            context.read<SistemasTallaBloc>().add(
              LoadSistemaTallaValoresEvent(sistema.id)
            );
            _showValoresModal(context, sistema);
          },
          onEdit: () => _handleEdit(context, sistema),
          onToggleStatus: () {
            context.read<SistemasTallaBloc>().add(ToggleSistemaTallaActivoEvent(sistema.id));
            _loadData();
          },
        );
      },
    );
  }

  Widget _buildMobileList(List<SistemaTallaModel> sistemas) {
    return ListView.separated(
      itemCount: sistemas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sistema = sistemas[index];
        return SistemaTallaCard(
          nombre: sistema.nombre,
          tipoSistema: sistema.tipoSistema,
          descripcion: sistema.descripcion,
          activo: sistema.activo,
          valoresCount: sistema.valoresCount,
          productosCount: 0, // Placeholder hasta HU productos
          onViewDetail: () {
            context.read<SistemasTallaBloc>().add(
              LoadSistemaTallaValoresEvent(sistema.id)
            );
            _showValoresModal(context, sistema);
          },
          onEdit: () => _handleEdit(context, sistema),
          onToggleStatus: () {
            context.read<SistemasTallaBloc>().add(ToggleSistemaTallaActivoEvent(sistema.id));
            _loadData();
          },
        );
      },
    );
  }
}
