import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/injection/injection_container.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/email_confirmation_error.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/email_confirmation_success.dart';

/// Página de confirmación de email
///
/// Características:
/// - Recibe token desde query params (?token=XXX)
/// - Llama a AuthBloc para confirmar email
/// - Muestra estado: loading, success, error
class ConfirmEmailPage extends StatefulWidget {
  final String? token;

  const ConfirmEmailPage({
    Key? key,
    this.token,
  }) : super(key: key);

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  @override
  void initState() {
    super.initState();
    // Confirmar email automáticamente al cargar la página
    if (widget.token != null && widget.token!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthBloc>().add(
              ConfirmEmailRequested(token: widget.token!),
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB), // backgroundLight
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Loading state
            if (state is AuthLoading) {
              return _buildLoadingState();
            }

            // Success state
            if (state is AuthEmailConfirmed) {
              return const EmailConfirmationSuccess();
            }

            // Error state
            if (state is AuthError) {
              return EmailConfirmationError(email: null);
            }

            // Token inválido (no se proporcionó token)
            if (widget.token == null || widget.token!.isEmpty) {
              return const EmailConfirmationError(email: null);
            }

            // Initial state (confirmando)
            return _buildLoadingState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF4ECDC4), // primaryTurquoise
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Confirmando tu email...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF26A69A), // primaryDark
            ),
          ),
        ],
      ),
    );
  }
}
