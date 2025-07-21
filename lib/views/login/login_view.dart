import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/extensions/string_extension.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';
import 'package:vecinapp/utilities/widgets/custom_form_field.dart';
import 'package:vecinapp/views/login/forgot_password_view.dart';
import 'package:vecinapp/views/login/register_view.dart';

class LoginView extends HookWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isShowingPassword = useState(false);
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (!state.isLoading && state is AppStateUnInitalized) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Iniciar sesión'),
        ),
        body: CenteredView(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomFormField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Email requerido';
                      }
                      if (!val.isValidEmail()) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      emailController.text = val ?? '';
                    },
                  ),
                  CustomFormField(
                    obscureText: !isShowingPassword.value,
                    autocorrect: false,
                    enableSuggestions: false,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          isShowingPassword.value = !isShowingPassword.value,
                      icon: Builder(
                          builder: (context) => isShowingPassword.value
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off)),
                    ),
                    hintText: 'Contraseña',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Contraseña requerida';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      passwordController.text = val ?? '';
                    },
                  ),
                  FilledButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      formKey.currentState!.save();
                      if (formKey.currentState!.validate()) {
                        context
                            .read<AppBloc>()
                            .add(AppEventLogInWithEmailAndPassword(
                              emailController.text,
                              passwordController.text,
                            ));
                      }
                    },
                    child: const Text('Entrar'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const RegisterView(),
                      ),
                    ),
                child: const Text('Aún no tengo una cuenta')),
            TextButton(
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordView(),
                      ),
                    ),
                child: const Text('Olvidé mi contraseña'))
          ],
        ),
      ),
    );
  }
}
