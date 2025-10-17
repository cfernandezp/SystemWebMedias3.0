import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_bloc.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_event.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_state.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/confirm_eliminar_dialog.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/confirm_desactivar_dialog.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/persona_tipo_chip.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_bloc.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_event.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_state.dart';

class PersonasListPage extends StatelessWidget {
  const PersonasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<PersonaBloc>()
            ..add(const ListarPersonasEvent()),
        ),
        BlocProvider(
          create: (_) => di.sl<TipoDocumentoBloc>()
            ..add(const ListarTiposDocumentoEvent()),
        ),
      ],
      child: const _PersonasListView(),
    );
  }
}

class _PersonasListView extends StatefulWidget {
  const _PersonasListView();

  @override
  State<_PersonasListView> createState() => _PersonasListViewState();
}

class _PersonasListViewState extends State<_PersonasListView> {
  String? _tipoDocumentoIdFilter;
  String? _tipoPersonaFilter;
  bool? _activoFilter;
  String _searchQuery = '';
  int _currentPage = 1;
  int _itemsPerPage = 20;
  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _offset => (_currentPage - 1) * _itemsPerPage;

  int _calculateTotalPages(int total) {
    return (total / _itemsPerPage).ceil();
  }

  int _calculateShowingFrom(int total) {
    if (total == 0) return 0;
    return _offset + 1;
  }

  int _calculateShowingTo(int total) {
    if (total == 0) return 0;
    final to = _offset + _itemsPerPage;
    return to > total ? total : to;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = DesignBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: DesignColors.backgroundLight,
      body: BlocConsumer<PersonaBloc, PersonaState>(
        listener: (context, state) {
          if (state is PersonaDeleteSuccess) {
            _showSnackbar(context, state.message, isError: false);
            context.read<PersonaBloc>().add(ListarPersonasEvent(
              tipoDocumentoId: _tipoDocumentoIdFilter,
              tipoPersona: _tipoPersonaFilter,
              activo: _activoFilter,
              busqueda: _searchQuery.isEmpty ? null : _searchQuery,
              limit: _itemsPerPage,
              offset: _offset,
            ));
          }

          if (state is PersonaError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? DesignSpacing.lg : DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, isDesktop),
                  SizedBox(height: DesignSpacing.lg),
                  _buildFilters(context, theme, isDesktop),
                  SizedBox(height: DesignSpacing.lg),
                  if (state is PersonaListSuccess)
                    _buildPaginationInfo(context, state, isDesktop),
                  SizedBox(height: DesignSpacing.md),
                  _buildContent(context, state, isDesktop),
                  SizedBox(height: DesignSpacing.md),
                  if (state is PersonaListSuccess)
                    _buildPagination(context, state, isDesktop),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/personas-form');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Nueva Persona'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Personas',
          style: TextStyle(
            fontSize: isDesktop ? DesignTypography.font3xl : DesignTypography.font2xl,
            fontWeight: DesignTypography.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        Text(
          'Registro único de todas las personas del negocio',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, ThemeData theme, bool isDesktop) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 1;
                  });
                  context.read<PersonaBloc>().add(ListarPersonasEvent(
                    tipoDocumentoId: _tipoDocumentoIdFilter,
                    tipoPersona: _tipoPersonaFilter,
                    activo: _activoFilter,
                    busqueda: value.isEmpty ? null : value,
                    limit: _itemsPerPage,
                    offset: 0,
                  ));
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, documento...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.md),
        Wrap(
          spacing: DesignSpacing.sm,
          runSpacing: DesignSpacing.sm,
          children: [
            BlocBuilder<TipoDocumentoBloc, TipoDocumentoState>(
              builder: (context, state) {
                if (state is TipoDocumentoListLoaded) {
                  return DropdownMenu<String>(
                    width: isDesktop ? 200 : MediaQuery.of(context).size.width - 32,
                    label: const Text('Tipo Documento'),
                    dropdownMenuEntries: [
                      const DropdownMenuEntry(value: '', label: 'Todos'),
                      ...state.tipos
                          .where((td) => td.activo)
                          .map((td) => DropdownMenuEntry(
                                value: td.id,
                                label: td.codigo,
                              )),
                    ],
                    onSelected: (value) {
                      setState(() {
                        _tipoDocumentoIdFilter = value?.isEmpty == true ? null : value;
                        _currentPage = 1;
                      });
                      context.read<PersonaBloc>().add(ListarPersonasEvent(
                        tipoDocumentoId: _tipoDocumentoIdFilter,
                        tipoPersona: _tipoPersonaFilter,
                        activo: _activoFilter,
                        busqueda: _searchQuery.isEmpty ? null : _searchQuery,
                        limit: _itemsPerPage,
                        offset: 0,
                      ));
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            _buildFilterChip(
              context,
              label: 'Todos',
              isSelected: _tipoPersonaFilter == null,
              onTap: () {
                setState(() {
                  _tipoPersonaFilter = null;
                  _currentPage = 1;
                });
                _applyFilters(context);
              },
            ),
            _buildFilterChip(
              context,
              label: 'Natural',
              icon: Icons.person,
              isSelected: _tipoPersonaFilter == 'Natural',
              onTap: () {
                setState(() {
                  _tipoPersonaFilter = 'Natural';
                  _currentPage = 1;
                });
                _applyFilters(context);
              },
            ),
            _buildFilterChip(
              context,
              label: 'Jurídica',
              icon: Icons.business,
              isSelected: _tipoPersonaFilter == 'Juridica',
              onTap: () {
                setState(() {
                  _tipoPersonaFilter = 'Juridica';
                  _currentPage = 1;
                });
                _applyFilters(context);
              },
            ),
            _buildFilterChip(
              context,
              label: 'Activos',
              icon: Icons.check_circle,
              isSelected: _activoFilter == true,
              onTap: () {
                setState(() {
                  _activoFilter = _activoFilter == true ? null : true;
                  _currentPage = 1;
                });
                _applyFilters(context);
              },
            ),
            _buildFilterChip(
              context,
              label: 'Inactivos',
              icon: Icons.cancel,
              isSelected: _activoFilter == false,
              onTap: () {
                setState(() {
                  _activoFilter = _activoFilter == false ? null : false;
                  _currentPage = 1;
                });
                _applyFilters(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignRadius.full),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.full),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              SizedBox(width: DesignSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: DesignTypography.fontSm,
                fontWeight: DesignTypography.semibold,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationInfo(BuildContext context, PersonaListSuccess state, bool isDesktop) {
    final showingFrom = _calculateShowingFrom(state.total);
    final showingTo = _calculateShowingTo(state.total);

    return Row(
      children: [
        if (isDesktop) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Text(
              'Mostrando $showingFrom-$showingTo de ${state.total} personas',
              style: TextStyle(
                fontSize: DesignTypography.fontSm,
                fontWeight: DesignTypography.semibold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Items por página:',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.textSecondary,
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          DropdownButton<int>(
            value: _itemsPerPage,
            items: const [
              DropdownMenuItem(value: 10, child: Text('10')),
              DropdownMenuItem(value: 20, child: Text('20')),
              DropdownMenuItem(value: 50, child: Text('50')),
              DropdownMenuItem(value: 100, child: Text('100')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _itemsPerPage = value;
                  _currentPage = 1;
                });
                _applyFilters(context);
              }
            },
          ),
        ] else ...[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Text(
                'Mostrando $showingFrom-$showingTo de ${state.total}',
                style: TextStyle(
                  fontSize: DesignTypography.fontSm,
                  fontWeight: DesignTypography.semibold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context, PersonaState state, bool isDesktop) {
    if (state is PersonaLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is PersonaListSuccess) {
      if (state.personas.isEmpty) {
        return _buildEmptyState();
      }

      if (isDesktop) {
        return _buildDesktopTable(context, state.personas);
      } else {
        return _buildMobileList(context, state.personas);
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildDesktopTable(BuildContext context, List<dynamic> personas) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Tipo Doc')),
          DataColumn(label: Text('Nro Documento')),
          DataColumn(label: Text('Nombre/Razón Social')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Roles')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: personas.map((persona) {
          return DataRow(
            cells: [
              DataCell(Text('${persona.tipoDocumentoId}')),
              DataCell(Text(persona.numeroDocumento)),
              DataCell(Text(
                persona.nombreCompleto ?? persona.razonSocial ?? '',
                overflow: TextOverflow.ellipsis,
              )),
              DataCell(PersonaTipoChip(tipo: persona.tipoPersona)),
              DataCell(_buildRolesBadges(persona.roles)),
              DataCell(_buildEstadoChip(persona.activo)),
              DataCell(_buildActions(context, persona)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<dynamic> personas) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: personas.length,
      separatorBuilder: (context, index) => SizedBox(height: DesignSpacing.md),
      itemBuilder: (context, index) {
        final persona = personas[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                persona.tipoPersona.toString().contains('natural')
                    ? Icons.person
                    : Icons.business,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              persona.nombreCompleto ?? persona.razonSocial ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${persona.tipoDocumentoId}: ${persona.numeroDocumento}'),
                Row(
                  children: [
                    PersonaTipoChip(tipo: persona.tipoPersona),
                    SizedBox(width: DesignSpacing.xs),
                    _buildEstadoChip(persona.activo),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                context.push('/personas-detail', extra: {'personaId': persona.id});
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRolesBadges(List<dynamic> roles) {
    if (roles.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.sm,
          vertical: DesignSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: DesignColors.disabled.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.xs),
        ),
        child: const Text(
          'Sin roles',
          style: TextStyle(
            fontSize: 11,
            color: DesignColors.disabled,
          ),
        ),
      );
    }

    return Wrap(
      spacing: DesignSpacing.xs,
      children: roles.map((rol) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: DesignSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: rol['activo']
                ? DesignColors.success.withValues(alpha: 0.1)
                : DesignColors.disabled.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.xs),
          ),
          child: Text(
            rol['tipo'],
            style: TextStyle(
              fontSize: 11,
              color: rol['activo'] ? DesignColors.success : DesignColors.disabled,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEstadoChip(bool activo) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: activo
            ? DesignColors.success.withValues(alpha: 0.1)
            : DesignColors.disabled.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.xs),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontSize: 11,
          color: activo ? DesignColors.success : DesignColors.disabled,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, dynamic persona) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 18),
          onPressed: () {
            context.push('/personas-detail', extra: {'personaId': persona.id});
          },
          tooltip: 'Ver detalle',
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: () {
            context.push('/personas-form', extra: {
              'mode': 'edit',
              'personaId': persona.id,
            });
          },
          tooltip: 'Editar',
        ),
        if (persona.activo)
          IconButton(
            icon: const Icon(Icons.block, size: 18, color: DesignColors.warning),
            onPressed: () => _handleDesactivar(context, persona),
            tooltip: 'Desactivar',
          ),
        IconButton(
          icon: const Icon(Icons.delete, size: 18, color: DesignColors.error),
          onPressed: () => _handleEliminar(context, persona),
          tooltip: 'Eliminar',
        ),
      ],
    );
  }

  Widget _buildPagination(BuildContext context, PersonaListSuccess state, bool isDesktop) {
    final totalPages = _calculateTotalPages(state.total);
    final isFirstPage = _currentPage == 1;
    final isLastPage = !state.hasMore;

    if (isDesktop) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: DesignSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: isFirstPage ? null : () {
                setState(() {
                  _currentPage = 1;
                });
                _applyFilters(context);
              },
              icon: const Icon(Icons.first_page),
              tooltip: 'Primera página',
            ),
            SizedBox(width: DesignSpacing.sm),
            ElevatedButton.icon(
              onPressed: isFirstPage ? null : () {
                setState(() {
                  _currentPage--;
                });
                _applyFilters(context);
              },
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Anterior'),
            ),
            SizedBox(width: DesignSpacing.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Row(
                children: [
                  Text(
                    'Página',
                    style: TextStyle(
                      fontSize: DesignTypography.fontSm,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _pageController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        final page = int.tryParse(value);
                        if (page != null && page >= 1 && page <= totalPages) {
                          setState(() {
                            _currentPage = page;
                            _pageController.clear();
                          });
                          _applyFilters(context);
                        } else {
                          _pageController.clear();
                          _showSnackbar(
                            context,
                            'Ingrese una página válida (1-$totalPages)',
                            isError: true,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Text(
                    '/ $totalPages',
                    style: TextStyle(
                      fontSize: DesignTypography.fontSm,
                      fontWeight: DesignTypography.semibold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Text(
              'Página $_currentPage de $totalPages',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(width: DesignSpacing.md),
            ElevatedButton.icon(
              onPressed: isLastPage ? null : () {
                setState(() {
                  _currentPage++;
                });
                _applyFilters(context);
              },
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Siguiente'),
            ),
            SizedBox(width: DesignSpacing.sm),
            IconButton(
              onPressed: isLastPage ? null : () {
                setState(() {
                  _currentPage = totalPages;
                });
                _applyFilters(context);
              },
              icon: const Icon(Icons.last_page),
              tooltip: 'Última página',
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: DesignSpacing.lg),
        child: Column(
          children: [
            Text(
              'Página $_currentPage de $totalPages',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: DesignSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isFirstPage ? null : () {
                    setState(() {
                      _currentPage--;
                    });
                    _applyFilters(context);
                  },
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text('Anterior'),
                ),
                SizedBox(width: DesignSpacing.md),
                ElevatedButton.icon(
                  onPressed: isLastPage ? null : () {
                    setState(() {
                      _currentPage++;
                    });
                    _applyFilters(context);
                  },
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('Siguiente'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: DesignColors.disabled,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'No se encontraron personas',
            style: TextStyle(
              fontSize: DesignTypography.fontLg,
              fontWeight: DesignTypography.semibold,
              color: DesignColors.textSecondary,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Comienza agregando una nueva persona',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.disabled,
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters(BuildContext context) {
    context.read<PersonaBloc>().add(ListarPersonasEvent(
      tipoDocumentoId: _tipoDocumentoIdFilter,
      tipoPersona: _tipoPersonaFilter,
      activo: _activoFilter,
      busqueda: _searchQuery.isEmpty ? null : _searchQuery,
      limit: _itemsPerPage,
      offset: _offset,
    ));
  }

  void _handleDesactivar(BuildContext context, dynamic persona) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDesactivarDialog(
        hasRolesActivos: persona.roles.any((r) => r['activo'] == true),
        onConfirm: (desactivar, desactivarRoles) {
          if (desactivar) {
            context.read<PersonaBloc>().add(DesactivarPersonaEvent(
              personaId: persona.id,
              desactivarRoles: desactivarRoles,
            ));
          }
        },
      ),
    );
  }

  void _handleEliminar(BuildContext context, dynamic persona) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmEliminarDialog(
        nombrePersona: persona.nombreCompleto ?? persona.razonSocial ?? '',
        hasTransacciones: false,
        onConfirm: () {
          context.read<PersonaBloc>().add(EliminarPersonaEvent(
            personaId: persona.id,
          ));
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
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? DesignColors.error : DesignColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
