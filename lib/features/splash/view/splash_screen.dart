import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/widgets/mascote_icon.dart';

/// Apresentação inicial, fora do histórico de navegação do aplicativo.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.child});

  static const duration = Duration(milliseconds: 1800);

  final Widget child;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.duration, () {
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 250),
      child: _showSplash
          ? Scaffold(
              key: const ValueKey('splash'),
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 600),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.94 + value * 0.06,
                          child: child,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: const Mascote(),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Maragames',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: AppTheme.purple),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aprenda jogando',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 36),
                          SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(
                              value: reduceMotion ? 1 : null,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(4),
                              color: AppTheme.purple,
                              backgroundColor: const Color(0xFFECE4F6),
                              semanticsLabel: 'Abrindo Maragames',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : widget.child,
    );
  }
}
