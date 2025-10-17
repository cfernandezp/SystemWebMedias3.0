import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_bloc.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_event.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_state.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/confirm_desactivar_dialog.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/confirm_eliminar_dialog.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/persona_tipo_chip.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/roles_badges_widget.dart';

class PersonaDetailPage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const PersonaDetailPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final personaId = arguments?['personaId'];

    if (personaId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: DesignColors.error),
              const SizedBox(height: 16),
              const Text('ID de persona no proporcionado'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/personas'),
                child: const Text('Volver a lista'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<PersonaBloc>()
        ..add(ObtenerPersonaEvent(personaId: personaId)),
      child: _PersonaDetailView(personaId: personaId),
    );
  }
}

class _PersonaDetailView extends StatelessWidget {
  final String personaId;

  const _PersonaDetailView({required this.personaId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = DesignBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: DesignColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Detalle de Persona',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<PersonaBloc, PersonaState>(
            builder: (context, state) {
              if (state is PersonaSuccess) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.push('/personas-form', extra: {
                      'mode': 'edit',
                      'personaId': personaId,
                    });
                  },
                  tooltip: 'Editar',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<PersonaBloc, PersonaState>(
        listener: (context, state) {
          if (state is PersonaDeleteSuccess) {
            _showSnackbar(context, state.message, isError: false);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                context.go('/personas');
              }
            });
          }

          if (state is PersonaError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is PersonaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PersonaSuccess) {
            final persona = state.persona;

            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 900 : double.infinity,
                  ),
                  padding: EdgeInsets.all(isDesktop ? DesignSpacing.xl : DesignSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(context, persona, isDesktop),
                      SizedBox(height: DesignSpacing.lg),
                      _buildAccionesCard(context, persona),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is PersonaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: DesignColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/personas'),
                    child: const Text('Volver a lista'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic persona, bool isDesktop) {
    return Card(
      elevation: DesignElevation.md,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isDesktop ? 48 : 36,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    persona.tipoPersona.toString().contains('natural')
                        ? Icons.person
                        : Icons.business,
                    size: isDesktop ? 48 : 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.nombreCompleto ?? persona.razonSocial ?? '',
                        style: TextStyle(
                          fontSize: isDesktop ? DesignTypography.font2xl : DesignTypography.fontXl,
                          fontWeight: DesignTypography.bold,
                        ),
                      ),
                      SizedBox(height: DesignSpacing.xs),
                      Row(
                        children: [
                          PersonaTipoChip(tipo: persona.tipoPersona),
                          SizedBox(width: DesignSpacing.sm),
                          _buildEstadoChip(persona.activo),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: DesignSpacing.xl),
            _buildInfoRow(
              context,
              icon: Icons.badge,
              label: 'Tipo de Documento',
              value: persona.tipoDocumentoId,
            ),
            SizedBox(height: DesignSpacing.md),
            _buildInfoRow(
              context,
              icon: Icons.numbers,
              label: 'Número de Documento',
              value: persona.numeroDocumento,
            ),
            if (persona.email != null && persona.email!.isNotEmpty) ...[
              SizedBox(height: DesignSpacing.md),
              _buildInfoRow(
                context,
                icon: Icons.email,
                label: 'Email',
                value: persona.email!,
              ),
            ],
            if (persona.celular != null && persona.celular!.isNotEmpty) ...[
              SizedBox(height: DesignSpacing.md),
              _buildInfoRow(
                context,
                icon: Icons.phone_android,
                label: 'Celular',
                value: persona.celular!,
              ),
            ],
            if (persona.telefono != null && persona.telefono!.isNotEmpty) ...[
              SizedBox(height: DesignSpacing.md),
              _buildInfoRow(
                context,
                icon: Icons.phone,
                label: 'Teléfono',
                value: persona.telefono!,
              ),
            ],
            if (persona.direccion != null && persona.direccion!.isNotEmpty) ...[
              SizedBox(height: DesignSpacing.md),
              _buildInfoRow(
                context,
                icon: Icons.location_on,
                label: 'Dirección',
                value: persona.direccion!,
              ),
            ],
            Divider(height: DesignSpacing.xl),
            Text(
              'Roles Asignados',
              style: TextStyle(
                fontSize: DesignTypography.fontMd,
                fontWeight: DesignTypography.semibold,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            RolesBadgesWidget(roles: persona.roles),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Registrado: ${_formatearFecha(persona.createdAt)}',
              style: TextStyle(
                fontSize: DesignTypography.fontXs,
                color: DesignColors.textSecondary,
              ),
            ),
            Text(
              'Última actualización: ${_formatearFecha(persona.updatedAt)}',
              style: TextStyle(
                fontSize: DesignTypography.fontXs,
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: DesignTypography.fontXs,
                  color: DesignColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: DesignTypography.fontMd,
                  fontWeight: DesignTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activo ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: activo ? DesignColors.success : DesignColors.disabled,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            activo ? 'Activo' : 'Inactivo',
            style: TextStyle(
              fontSize: 12,
              color: activo ? DesignColors.success : DesignColors.disabled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesCard(BuildContext context, dynamic persona) {
    return Card(
      elevation: DesignElevation.md,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones',
              style: TextStyle(
                fontSize: DesignTypography.fontLg,
                fontWeight: DesignTypography.bold,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            ListTile(
              leading: const Icon(Icons.edit, color: DesignColors.info),
              title: const Text('Editar Datos de Contacto'),
              subtitle: const Text('Email, celular, teléfono, dirección'),
              onTap: () {
                context.push('/personas-form', extra: {
                  'mode': 'edit',
                  'personaId': personaId,
                });
              },
            ),
            if (persona.activo) ...[
              Divider(),
              ListTile(
                leading: const Icon(Icons.block, color: DesignColors.warning),
                title: const Text('Desactivar Persona'),
                subtitle: const Text('La persona no podrá realizar transacciones'),
                onTap: () => _handleDesactivar(context, persona),
              ),
            ] else ...[
              Divider(),
              ListTile(
                leading: const Icon(Icons.refresh, color: DesignColors.success),
                title: const Text('Reactivar Persona'),
                subtitle: const Text('La persona podrá realizar transacciones nuevamente'),
                onTap: () {
                  context.read<PersonaBloc>().add(ReactivarPersonaEvent(
                    personaId: personaId,
                  ));
                },
              ),
            ],
            Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: DesignColors.error),
              title: const Text('Eliminar Persona'),
              subtitle: const Text('Acción permanente si no tiene transacciones'),
              onTap: () => _handleEliminar(context, persona),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _handleDesactivar(BuildContext context, dynamic persona) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDesactivarDialog(
        hasRolesActivos: persona.roles.any((r) => r['activo'] == true),
        onConfirm: (desactivar, desactivarRoles) {
          if (desactivar) {
            context.read<PersonaBloc>().add(DesactivarPersonaEvent(
              personaId: personaId,
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
            personaId: personaId,
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
