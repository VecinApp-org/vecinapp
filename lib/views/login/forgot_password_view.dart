import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/dialogs/show_error_dialog.dart';
import 'package:vecinapp/utilities/dialogs/show_notification_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key, this.email});

  final String? email;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    if (widget.email != null) {
      _controller = TextEditingController(text: widget.email);
    } else {
      _controller = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppStateResettingPassword) {
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
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Title
                  Text('Cambiar contraseña',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 55),
                  //email textfield
                  TextField(
                    controller: _controller,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      constraints: BoxConstraints(maxWidth: 377),
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
                          .read<AppBloc>()
                          .add(AppEventSendPasswordResetEmail(email));
                    },
                    child: const Text('Enviar correo'),
                  ),
                  const SizedBox(height: 13),
                  //cancel button
                  TextButton(
                    onPressed: () {
                      context.read<AppBloc>().add(const AppEventLogOut());
                    },
                    child: const Text('Regresar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
