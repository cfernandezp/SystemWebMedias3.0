import 'package:flutter/material.dart';

/// Form field corporativo que sigue el Design System Turquesa Moderno Retail
///
/// Especificaciones:
/// - Border radius: 28px (pill-shaped)
/// - Fill color: Blanco
/// - Padding: 16px horizontal/vertical
/// - Animación focus: 200ms con scale(1.02)
/// - Icon color cambia de gris a turquesa en focus
class CorporateFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;
  final TextCapitalization textCapitalization;

  const CorporateFormField({
    Key? key,
    this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  State<CorporateFormField> createState() => _CorporateFormFieldState();
}

class _CorporateFormFieldState extends State<CorporateFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: _obscureText,
        validator: widget.validator,
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        textCapitalization: widget.textCapitalization,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          filled: true,
          fillColor: widget.enabled ? Colors.white : const Color(0xFFF3F4F6),

          // Prefix Icon con animación de color
          prefixIcon: widget.prefixIcon != null
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? primaryColor
                        : const Color(0xFF9CA3AF),
                  ),
                )
              : null,

          // Suffix Icon (toggle password visibility)
          suffixIcon: _buildSuffixIcon(primaryColor),

          // Border normal (sin focus)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),

          // Border focus
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: const Color(0xFF6366F1),
              width: 2.5,
            ),
          ),

          // Border error
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: Color(0xFFF44336),
              width: 2.5,
            ),
          ),

          // Border error con focus
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: Color(0xFFF44336),
              width: 2.5,
            ),
          ),

          // Border disabled
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),

          // Padding interno
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          // Label style
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _isFocused
                ? const Color(0xFF6366F1)
                : const Color(0xFF6B7280),
          ),

          // Error style
          errorStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFFF44336),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(Color primaryColor) {
    // Si es campo de contraseña, mostrar toggle visibility
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: _isFocused ? primaryColor : const Color(0xFF9CA3AF),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    // Si se proporciona suffixIcon personalizado
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _isFocused ? primaryColor : const Color(0xFF9CA3AF),
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }
}
