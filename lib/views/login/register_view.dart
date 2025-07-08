import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/extensions/string_extension.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';
import 'package:vecinapp/utilities/widgets/custom_form_field.dart';

class RegisterView extends HookWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordController2 = useTextEditingController();
    final isShowingPassword = useState(false);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () =>
                context.read<AppBloc>().add(const AppEventGoToWelcomeView())),
      ),
      body: CenteredView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Registro',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormField(
                  hintText: 'Email',
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (!val!.isValidEmail()) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    emailController.text = val!;
                  },
                ),
                CustomFormField(
                  hintText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Builder(
                        builder: (context) => isShowingPassword.value
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off)),
                    onPressed: () =>
                        isShowingPassword.value = !isShowingPassword.value,
                  ),
                  obscureText: !isShowingPassword.value,
                  enableSuggestions: false,
                  autocorrect: false,
                  validator: (val) {
                    if (!val!.isValidPassword()) {
                      return 'Mínimo 8 caracteres, una mayúscula y un número';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    passwordController.text = val!;
                  },
                ),
                CustomFormField(
                  hintText: 'Confirmar Contraseña',
                  suffixIcon: IconButton(
                    icon: Builder(
                        builder: (context) => isShowingPassword.value
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off)),
                    onPressed: () =>
                        isShowingPassword.value = !isShowingPassword.value,
                  ),
                  obscureText: !isShowingPassword.value,
                  enableSuggestions: false,
                  autocorrect: false,
                  validator: (val) {
                    if (val != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    passwordController2.text = val!;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                      onPressed: () {
                        formKey.currentState!.save();
                        if (formKey.currentState!.validate()) {
                          context
                              .read<AppBloc>()
                              .add(AppEventRegisterWithEmailAndPassword(
                                emailController.text,
                                passwordController.text,
                                passwordController2.text,
                              ));
                        }
                      },
                      child: const Text('Crear Cuenta')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
                onPressed: () =>
                    context.read<AppBloc>().add(const AppEventGoToLogin()),
                child: const Text('Ya tengo una cuenta')),
          )
        ],
      ),
    );
  }
}
