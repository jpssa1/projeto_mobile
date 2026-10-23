import 'package:flutter/material.dart';
import 'package:projeto_mobile/core/theme/app_theme.dart';
import '../model/question_model.dart';

/// Pergunta de "clicar na imagem": a pessoa tem poucas tentativas para tocar
/// na área certa. Cada toque fora da área certa gasta uma tentativa.
class ImageQuestion extends StatefulWidget {
  const ImageQuestion({
    super.key,
    required this.question,
    required this.confirmed,
    required this.onResult,
    this.maxAttempts = 3,
  });
  final Question question;
  final bool confirmed;
  final int maxAttempts;

  /// Chamado uma única vez: true se acertou, false se acabaram as tentativas.
  final void Function(bool isCorrect) onResult;

  @override
  State<ImageQuestion> createState() => _ImageQuestionState();
}

class _ImageQuestionState extends State<ImageQuestion> {
  // Posições dos erros, em fração da imagem (0 a 1), para desenhar o "X".
  final List<Offset> _misses = [];
  String? _hint;

  void _onTap(TapDownDetails details, Size size) {
    if (widget.confirmed) return;
    final point = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );
    final areas = widget.question.areas!;
    final hit = areas.indexWhere((area) => area.contains(point));
    if (hit == widget.question.correctIndex) {
      widget.onResult(true);
      return;
    }
    setState(() {
      _misses.add(point);
      _hint = hit == -1
          ? 'Aí não tem nada importante. Tente outro lugar!'
          : 'Esse é: ${widget.question.options[hit]}. Tente outro!';
    });
    if (_misses.length >= widget.maxAttempts) widget.onResult(false);
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.maxAttempts - _misses.length;
    final correctArea = widget.question.areas![widget.question.correctIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Cenário de jogo. Toque na área correta.',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return GestureDetector(
                    onTapDown: (details) => _onTap(details, size),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            widget.question.imageAsset!,
                            fit: BoxFit.fill,
                          ),
                        ),
                        for (final miss in _misses)
                          Positioned(
                            left: miss.dx * size.width - 14,
                            top: miss.dy * size.height - 14,
                            child: const Icon(
                              Icons.close,
                              size: 28,
                              color: AppTheme.red,
                            ),
                          ),
                        // Depois de responder, mostra onde era a área certa.
                        if (widget.confirmed)
                          Positioned.fromRect(
                            rect: Rect.fromLTWH(
                              correctArea.left * size.width,
                              correctArea.top * size.height,
                              correctArea.width * size.width,
                              correctArea.height * size.height,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF007D19),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.maxAttempts; i++)
              Icon(
                i < left ? Icons.favorite : Icons.favorite_border,
                color: AppTheme.red,
              ),
            const SizedBox(width: 12),
            Text('$left ${left == 1 ? 'tentativa' : 'tentativas'}'),
          ],
        ),
        if (_hint != null && !widget.confirmed) ...[
          const SizedBox(height: 8),
          Text(_hint!, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
