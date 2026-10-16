import 'package:flutter/material.dart';

class Mascote extends StatelessWidget {
  const Mascote({super.key});
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mascote roxo segurando um controle de videogame',
      image: true,
      child: Image.asset(
        'assets/images/mascot.png',
        height: 260,
        excludeFromSemantics: true,
      ),
    );
  }
}
