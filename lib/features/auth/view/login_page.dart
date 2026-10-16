import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_fields.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.go('/');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Sua aventura começa aqui',
    subtitle: 'Entre para aprender, jogar e evoluir.',
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthEmailField(controller: _email),
          const SizedBox(height: 16),
          AuthPasswordField(
            controller: _password,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Entrar')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Explorar sem entrar'),
          ),
        ],
      ),
    ),
  );
}
