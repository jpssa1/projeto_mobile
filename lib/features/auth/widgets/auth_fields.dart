import 'package:flutter/material.dart';

abstract final class AuthValidators {
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha.';
    if (value.length < 6) return 'Use pelo menos 6 caracteres.';
    return null;
  }
}

InputDecoration authDecoration(String label, IconData icon) => InputDecoration(
  labelText: label,
  prefixIcon: Icon(icon),
  filled: true,
  fillColor: const Color(0xFFF7F3FC),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  errorMaxLines: 2,
);

class AuthEmailField extends StatelessWidget {
  const AuthEmailField({super.key, required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.emailAddress,
    textInputAction: onSubmitted == null
        ? TextInputAction.next
        : TextInputAction.done,
    autocorrect: false,
    decoration: authDecoration('E-mail', Icons.mail_outline_rounded),
    validator: AuthValidators.email,
    onFieldSubmitted: onSubmitted,
  );
}

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.label = 'Senha',
    this.validator = AuthValidators.password,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _obscure,
    autocorrect: false,
    enableSuggestions: false,
    textInputAction: widget.onSubmitted == null
        ? TextInputAction.next
        : TextInputAction.done,
    decoration: authDecoration(widget.label, Icons.lock_outline_rounded)
        .copyWith(
          suffixIcon: IconButton(
            tooltip: _obscure
                ? 'Mostrar ${widget.label.toLowerCase()}'
                : 'Ocultar ${widget.label.toLowerCase()}',
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
    validator: widget.validator,
    onFieldSubmitted: widget.onSubmitted,
  );
}
