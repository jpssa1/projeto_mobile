import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_fields.dart';
import '../widgets/auth_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _submitted = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    showBack: true,
    title: _submitted ? 'Cadastro simulado!' : 'Crie sua conta',
    subtitle: _submitted
        ? 'Nenhuma conta foi criada. Tudo pronto para explorar o protótipo.'
        : 'Dê o primeiro passo na sua próxima aventura.',
    child: _submitted
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Explorar o app'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Voltar ao login'),
              ),
            ],
          )
        : Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: authDecoration(
                    'Nome',
                    Icons.person_outline_rounded,
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? 'Informe um nome com pelo menos 2 caracteres.'
                      : null,
                ),
                const SizedBox(height: 16),
                AuthEmailField(controller: _email),
                const SizedBox(height: 16),
                AuthPasswordField(controller: _password),
                const SizedBox(height: 16),
                AuthPasswordField(
                  controller: _confirmation,
                  label: 'Confirmar senha',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme sua senha.';
                    }
                    return value != _password.text
                        ? 'As senhas precisam ser iguais.'
                        : null;
                  },
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Criar conta'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          ),
  );
}
