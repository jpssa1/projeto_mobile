import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.child, this.color = Colors.white});
  final Widget child;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFDCD3E8), width: 2),
      boxShadow: const [
        BoxShadow(color: Color(0xFFDCD3E8), offset: Offset(0, 4)),
      ],
    ),
    child: child,
  );
}
