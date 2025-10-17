import 'package:flutter/material.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';

class ConfirmDesactivarDialog extends StatefulWidget {
  final bool hasRolesActivos;
  final Function(bool desactivar, bool desactivarRoles) onConfirm;

  const ConfirmDesactivarDialog({
    super.key,
    required this.hasRolesActivos,
    required this.onConfirm,
  });

  @override
  State<ConfirmDesactivarDialog> createState() => _ConfirmDesactivarDialogState();
}

class _ConfirmDesactivarDialogState extends State<ConfirmDesactivarDialog> {
  bool _desactivarRoles = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      title: Row(
        children: [
          Icon(Icons.warning, color: DesignColors.warning),
          SizedBox(width: DesignSpacing.sm),
          const Expanded(
            child: Text('Confirmar Desactivación'),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.hasRolesActivos
                    ? 'Esta persona tiene roles activos. ¿Cómo deseas proceder?'
                    : '¿Estás seguro de desactivar esta persona?',
                style: TextStyle(fontSize: DesignTypography.fontMd),
              ),
              if (widget.hasRolesActivos) ...[
                SizedBox(height: DesignSpacing.md),
                Container(
                  padding: EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: DesignColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                    border: Border.all(color: DesignColors.warning),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opciones:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: DesignTypography.fontSm,
                        ),
                      ),
                      SizedBox(height: DesignSpacing.sm),
                      RadioListTile<bool>(
                        title: const Text('Desactivar solo la persona'),
                        subtitle: const Text('Los roles quedan activos'),
                        value: false,
                        groupValue: _desactivarRoles,
                        onChanged: (value) {
                          setState(() {
                            _desactivarRoles = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<bool>(
                        title: const Text('Desactivar persona y roles'),
                        subtitle: const Text('Desactivación en cascada'),
                        value: true,
                        groupValue: _desactivarRoles,
                        onChanged: (value) {
                          setState(() {
                            _desactivarRoles = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(false, false);
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(true, _desactivarRoles);
          },
          style: FilledButton.styleFrom(
            backgroundColor: DesignColors.warning,
          ),
          child: const Text('Desactivar'),
        ),
      ],
    );
  }
}
