import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/extensions/string_extension.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/bloc/loading_messages_constants.dart';
import 'package:vecinapp/utilities/dialogs/show_notification_dialog.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';
import 'package:vecinapp/utilities/widgets/custom_form_field.dart';

class ForgotPasswordView extends HookWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final controller = useTextEditingController();
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) async {
        if (!state.isLoading &&
            state.loadingText == loadingTextPasswordResetEmailSent) {
          controller.clear();
          await showNotificationDialog(
            context: context,
            title: 'Revisa tu correo',
            content:
                'Sigue los pasos para restablecer tu contraseña y vuelve a ingresar.',
          );
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Recuperar contraseña')),
        body: CenteredView(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomFormField(
                    enableSuggestions: false,
                    autocorrect: false,
                    autofocus: true,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => controller.text = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Email requerido';
                      }
                      if (!val.isValidEmail()) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  //Reset password button
                  FilledButton(
                    onPressed: () {
                      formKey.currentState!.save();
                      if (!formKey.currentState!.validate()) return;
                      final email = controller.text;
                      context
                          .read<AppBloc>()
                          .add(AppEventSendPasswordResetEmail(email));
                    },
                    child: const Text('Enviar correo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
