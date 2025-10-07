import 'package:flutter/material.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/status_badge.dart';

/// Tarjeta de marca individual con acciones
///
/// Especificaciones:
/// - Muestra nombre, código y estado (CA-001)
/// - Botones de editar y activar/desactivar (CA-005, CA-008, CA-010)
/// - Responsive: adapta layout mobile/desktop
class MarcaCard extends StatefulWidget {
  final String nombre;
  final String codigo;
  final bool activo;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const MarcaCard({
    Key? key,
    required this.nombre,
    required this.codigo,
    required this.activo,
    required this.onEdit,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  State<MarcaCard> createState() => _MarcaCardState();
}

class _MarcaCardState extends State<MarcaCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) {
        _hoverController.forward();
      },
      onExit: (_) {
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icono de marca
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_offer,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Información de la marca
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Código: ${widget.codigo}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Badge de estado
                    StatusBadge(activo: widget.activo),

                    const SizedBox(width: 12),

                    // Botones de acción
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón Editar
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          color: theme.colorScheme.primary,
                          onPressed: widget.onEdit,
                        ),

                        // Botón Activar/Desactivar
                        IconButton(
                          icon: Icon(
                            widget.activo ? Icons.toggle_on : Icons.toggle_off,
                          ),
                          tooltip: widget.activo ? 'Desactivar' : 'Activar',
                          color: widget.activo
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF9CA3AF),
                          onPressed: widget.onToggleStatus,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}