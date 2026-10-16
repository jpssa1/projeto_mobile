import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/home_content_model.dart';

final homeViewModelProvider = Provider<HomeContent>(
  (ref) => const HomeContent(
    title: 'Seu primeiro passo no mundo dos games.',
    description:
        'Explore ideias, descubra novas habilidades e aprenda a criar jogos. Uma missão de cada vez.',
  ),
);
