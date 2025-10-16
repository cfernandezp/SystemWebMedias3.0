import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_bloc.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_event.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_state.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/widgets/tipo_documento_card.dart';

class TiposDocumentoListPage extends StatelessWidget {
  const TiposDocumentoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TipoDocumentoBloc>()
        ..add(const ListarTiposDocumentoEvent(incluirInactivos: false)),
      child: const _TiposDocumentoListView(),
    );
  }
}

class _TiposDocumentoListView extends StatefulWidget {
  const _TiposDocumentoListView();

  @override
  State<_TiposDocumentoListView> createState() => _TiposDocumentoListViewState();
}

class _TiposDocumentoListViewState extends State<_TiposDocumentoListView> {
  bool _mostrarInactivos = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = DesignBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: DesignColors.backgroundLight,
      body: BlocConsumer<TipoDocumentoBloc, TipoDocumentoState>(
        listener: (context, state) {
          if (state is TipoDocumentoOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
            context.read<TipoDocumentoBloc>().add(
              ListarTiposDocumentoEvent(incluirInactivos: _mostrarInactivos),
            );
          }

          if (state is TipoDocumentoError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(isDesktop ? DesignSpacing.lg : DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme, isDesktop),
                SizedBox(height: DesignSpacing.lg),
                _buildFilterSection(context),
                SizedBox(height: DesignSpacing.lg),
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
          context.push('/tipo-documento-form');
        },
        backgroundColor: DesignColors.primaryTurquoise,
        foregroundColor: DesignColors.surface,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Tipo'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de Documento',
          style: TextStyle(
            fontSize: isDesktop ? DesignTypography.font3xl : DesignTypography.font2xl,
            fontWeight: DesignTypography.bold,
            color: DesignColors.primaryTurquoise,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
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
              fontSize: DesignTypography.fontSm,
              color: DesignColors.primaryTurquoise,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm),
          child: Text(
            '>',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.textSecondary,
            ),
          ),
        ),
        Text(
          'Catálogos',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textSecondary,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm),
          child: Text(
            '>',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.textSecondary,
            ),
          ),
        ),
        Text(
          'Tipos de Documento',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textSecondary,
            fontWeight: DesignTypography.semibold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: DesignColors.border),
      ),
      child: CheckboxListTile(
        value: _mostrarInactivos,
        onChanged: (value) {
          setState(() {
            _mostrarInactivos = value ?? false;
          });
          context.read<TipoDocumentoBloc>().add(
            ListarTiposDocumentoEvent(incluirInactivos: _mostrarInactivos),
          );
        },
        title: const Text('Mostrar tipos inactivos'),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: DesignColors.primaryTurquoise,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContent(BuildContext context, TipoDocumentoState state, bool isDesktop) {
    if (state is TipoDocumentoLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is TipoDocumentoListLoaded) {
      final tipos = state.tipos;

      if (tipos.isEmpty) {
        return _buildEmptyState();
      }

      if (isDesktop) {
        return _buildDesktopTable(context, tipos);
      } else {
        return _buildMobileList(context, tipos);
      }
    }

    return const Center(
      child: Text('Cargando tipos de documento...'),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<dynamic> tipos) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: DesignColors.surface,
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(color: DesignColors.border),
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(2.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(1.5),
            5: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: DesignColors.primaryTurquoise.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignRadius.sm),
                  topRight: Radius.circular(DesignRadius.sm),
                ),
              ),
              children: [
                _buildTableHeader('Código'),
                _buildTableHeader('Nombre'),
                _buildTableHeader('Formato'),
                _buildTableHeader('Longitud'),
                _buildTableHeader('Estado'),
                _buildTableHeader('Acciones'),
              ],
            ),
            ...tipos.map((tipo) => _buildTableRow(context, tipo)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: DesignTypography.semibold,
          fontSize: DesignTypography.fontSm,
          color: DesignColors.textPrimary,
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, dynamic tipo) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DesignColors.border),
        ),
      ),
      children: [
        _buildTableCell(tipo.codigo),
        _buildTableCell(tipo.nombre),
        _buildTableCell(_formatoDisplay(tipo.formato.toBackendString())),
        _buildTableCell('${tipo.longitudMinima} - ${tipo.longitudMaxima}'),
        Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: _buildEstadoBadge(tipo.activo),
        ),
        Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                iconSize: 20,
                color: DesignColors.primaryTurquoise,
                onPressed: () => _handleEdit(context, tipo),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                iconSize: 20,
                color: DesignColors.error,
                onPressed: () => _handleDelete(context, tipo.id, tipo.nombre),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Text(
        text,
        style: TextStyle(
          fontSize: DesignTypography.fontSm,
          color: DesignColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<dynamic> tipos) {
    return ListView.separated(
      itemCount: tipos.length,
      separatorBuilder: (context, index) => SizedBox(height: DesignSpacing.md),
      itemBuilder: (context, index) {
        final tipo = tipos[index];
        return TipoDocumentoCard(
          codigo: tipo.codigo,
          nombre: tipo.nombre,
          formato: _formatoDisplay(tipo.formato.toBackendString()),
          longitudMinima: tipo.longitudMinima,
          longitudMaxima: tipo.longitudMaxima,
          activo: tipo.activo,
          onEdit: () => _handleEdit(context, tipo),
          onDelete: () => _handleDelete(context, tipo.id, tipo.nombre),
        );
      },
    );
  }

  Widget _buildEstadoBadge(bool activo) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: activo ? DesignColors.success : DesignColors.disabled,
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: DesignColors.surface,
          fontSize: DesignTypography.fontXs,
          fontWeight: DesignTypography.medium,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 64,
            color: DesignColors.disabled,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'No se encontraron tipos de documento',
            style: TextStyle(
              fontSize: DesignTypography.fontLg,
              fontWeight: DesignTypography.semibold,
              color: DesignColors.textSecondary,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          const Text(
            'Comienza agregando un nuevo tipo',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.disabled,
            ),
          ),
        ],
      ),
    );
  }

  String _formatoDisplay(String formato) {
    switch (formato.toUpperCase()) {
      case 'NUMERICO':
        return 'Numérico';
      case 'ALFANUMERICO':
        return 'Alfanumérico';
      default:
        return formato;
    }
  }

  void _handleEdit(BuildContext context, dynamic tipo) {
    context.push('/tipo-documento-form', extra: {
      'mode': 'edit',
      'tipo': tipo,
    });
  }

  void _handleDelete(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
        ),
        title: const Text('¿Eliminar tipo de documento?'),
        content: Text(
          '¿Estás seguro de eliminar el tipo "$nombre"?\n\nSi existen personas asociadas, no se podrá eliminar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TipoDocumentoBloc>().add(
                EliminarTipoDocumentoEvent(id: id),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: DesignColors.error,
            ),
            child: const Text('Eliminar'),
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
              color: DesignColors.surface,
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: DesignColors.surface),
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
