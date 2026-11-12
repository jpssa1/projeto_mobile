import 'package:flutter/material.dart';

import '../model/snake_position_model.dart';

class SnakeControls extends StatelessWidget {
  const SnakeControls({
    super.key,
    required this.enabled,
    required this.onDirection,
  });

  final bool enabled;
  final ValueChanged<SnakeDirection> onDirection;

  @override
  Widget build(BuildContext context) {
    Widget directionButton(
      SnakeDirection direction,
      IconData icon,
      String label,
    ) {
      return SizedBox(
        width: 64,
        height: 56,
        child: IconButton.filledTonal(
          onPressed: enabled ? () => onDirection(direction) : null,
          tooltip: label,
          icon: Icon(icon, size: 30),
        ),
      );
    }

    return Column(
      children: [
        directionButton(
          SnakeDirection.up,
          Icons.arrow_upward_rounded,
          'Mover para cima',
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            directionButton(
              SnakeDirection.left,
              Icons.arrow_back_rounded,
              'Mover para a esquerda',
            ),
            const SizedBox(width: 8),
            directionButton(
              SnakeDirection.down,
              Icons.arrow_downward_rounded,
              'Mover para baixo',
            ),
            const SizedBox(width: 8),
            directionButton(
              SnakeDirection.right,
              Icons.arrow_forward_rounded,
              'Mover para a direita',
            ),
          ],
        ),
      ],
    );
  }
}
