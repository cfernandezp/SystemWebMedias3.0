import 'package:flutter/material.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';

class PersonaTipoChip extends StatelessWidget {
  final TipoPersona tipo;

  const PersonaTipoChip({
    super.key,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final isNatural = tipo == TipoPersona.natural;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isNatural
            ? DesignColors.info.withValues(alpha: 0.1)
            : DesignColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNatural ? Icons.person : Icons.business,
            size: 14,
            color: isNatural ? DesignColors.info : DesignColors.accent,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            isNatural ? 'Natural' : 'Jurídica',
            style: TextStyle(
              fontSize: 12,
              color: isNatural ? DesignColors.info : DesignColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
