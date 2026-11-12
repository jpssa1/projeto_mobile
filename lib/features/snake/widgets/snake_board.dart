import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../model/snake_position_model.dart';
import '../model/snake_state_model.dart';

class SnakeBoard extends StatelessWidget {
  const SnakeBoard({super.key, required this.state});

  final SnakeState state;

  @override
  Widget build(BuildContext context) {
    final food = state.food;
    final direction = switch (state.direction) {
      SnakeDirection.up => 'cima',
      SnakeDirection.right => 'direita',
      SnakeDirection.down => 'baixo',
      SnakeDirection.left => 'esquerda',
    };
    return Semantics(
      label: 'Tabuleiro de ${SnakeState.boardSize} linhas e colunas',
      value:
          'Cabeça na coluna ${state.head.x + 1}, linha ${state.head.y + 1}. '
          'Direção: $direction. '
          '${food == null ? 'Tabuleiro completo.' : 'Comida na coluna ${food.x + 1}, linha ${food.y + 1}.'}',
      liveRegion: state.stepMode && state.status == SnakeStatus.playing,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCD3E8), width: 2),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(painter: _SnakePainter(state)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  const _SnakePainter(this.state);

  final SnakeState state;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / SnakeState.boardSize;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF0EAF7),
    );
    final gridPaint = Paint()
      ..color = const Color(0xFFDFD3EC)
      ..strokeWidth = 0.6;
    for (var i = 1; i < SnakeState.boardSize; i++) {
      canvas.drawLine(
        Offset(i * cell, 0),
        Offset(i * cell, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * cell),
        Offset(size.width, i * cell),
        gridPaint,
      );
    }
    final food = state.food;
    if (food != null) {
      final center = Offset((food.x + 0.5) * cell, (food.y + 0.5) * cell);
      final radius = cell * 0.43;
      final diamond = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius, center.dy)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius, center.dy)
        ..close();
      canvas.drawPath(diamond, Paint()..color = const Color(0xFFBE123C));
      canvas.drawCircle(center, cell * 0.09, Paint()..color = Colors.white);
    }
    for (var i = state.snake.length - 1; i >= 0; i--) {
      final part = state.snake[i];
      final rect = Rect.fromLTWH(
        part.x * cell + 1,
        part.y * cell + 1,
        cell - 2,
        cell - 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.25)),
        Paint()..color = i == 0 ? const Color(0xFF32115A) : AppTheme.purple,
      );
    }
    final center = Offset(
      (state.head.x + 0.5) * cell,
      (state.head.y + 0.5) * cell,
    );
    final direction = Offset(
      state.direction.dx.toDouble(),
      state.direction.dy.toDouble(),
    );
    final side = Offset(-direction.dy, direction.dx);
    for (final sign in [-1, 1]) {
      final eye =
          center + direction * (cell * 0.2) + side * (sign * cell * 0.22);
      canvas.drawCircle(eye, cell * 0.1, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_SnakePainter oldDelegate) => oldDelegate.state != state;
}
