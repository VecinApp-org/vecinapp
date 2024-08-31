import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';
import 'package:vecinapp/utilities/show_notification_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateResettingPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            showNotificationDialog(
              context: context,
              title: 'Revisa tu correo',
              content: 'Enviamos un correo para restablecer tu contraseña.',
            );
          }
          if (state.email != null) {
            _controller = TextEditingController(text: state.email);
          }
          if (state.exception != null) {
            if (state.exception is NetworkRequestFailedAuthException) {
              showErrorDialog(context: context, text: 'No hay internet');
            } else if (state.exception is ChannelErrorAuthException) {
              showErrorDialog(context: context, text: 'Dejaste algo vacío');
            } else {
              showErrorDialog(context: context, text: 'Algo salio mal');
            }
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Title
              const Text('Reestablecer contraseña',
                  style: TextStyle(fontSize: 28)),
              const SizedBox(height: 55),
              //email textfield
              TextField(
                controller: _controller,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  constraints: BoxConstraints(maxWidth: 360),
                  icon: Icon(Icons.email),
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 55),
              //Reset password button
              FilledButton(
                onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventSendPasswordResetEmail(email));
                },
                child: const Text('Reestablecer contraseña'),
              ),
              const SizedBox(height: 13),
              //cancel button
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
