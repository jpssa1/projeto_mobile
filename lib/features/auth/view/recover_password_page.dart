import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_scaffold.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitted = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    showBack: true,
    title: _submitted ? 'Solicitação simulada!' : 'Recuperar senha',
    subtitle: _submitted
        ? 'Nenhum e-mail foi enviado. Esta etapa apenas demonstra a recuperação de senha.'
        : 'Esqueceu sua senha? Informe seu e-mail para simular a recuperação.',
    child: _submitted
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                size: 48,
                color: AppTheme.purple,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Voltar ao login'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _submitted = false),
                child: const Text('Tentar outro e-mail'),
              ),
            ],
          )
        : Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthEmailField(
                  controller: _email,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Simular recuperação'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Voltar ao login'),
                ),
              ],
            ),
          ),
  );
}
