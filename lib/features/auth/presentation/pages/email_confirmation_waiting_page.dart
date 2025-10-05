import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/injection/injection_container.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/email_confirmation_waiting.dart';

/// Página de espera de confirmación de email
///
/// Características:
/// - Recibe email desde argumentos de navegación
/// - Muestra widget EmailConfirmationWaiting
/// - Incluye BlocProvider para AuthBloc
class EmailConfirmationWaitingPage extends StatelessWidget {
  final String? email;

  const EmailConfirmationWaitingPage({
    Key? key,
    this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener email desde argumentos de ruta si no se proporcionó
    final String emailToUse = email ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        '';

    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB), // backgroundLight
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Color(0xFF26A69A), // primaryDark
          ),
        ),
        body: EmailConfirmationWaiting(email: emailToUse),
      ),
    );
  }
}
