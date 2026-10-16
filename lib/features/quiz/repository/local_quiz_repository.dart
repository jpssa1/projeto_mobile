import '../model/question_model.dart';
import '../model/quiz_repository_model.dart';

class LocalQuizRepository implements QuizRepository {
  @override
  Future<List<Question>> loadQuestions() async => [
    Question(
      id: 'design',
      title: 'Qual é o papel do game design?',
      options: [
        'Criar apenas os desenhos',
        'Definir regras e experiências do jogo',
        'Vender computadores',
        'Instalar o jogo',
      ],
      correctIndex: 1,
      explanation:
          'Game design define as regras, os desafios e as experiências que tornam um jogo divertido.',
    ),
    Question(
      id: 'engine',
      title: 'O que é uma engine de jogos?',
      options: [
        'Uma ferramenta para criar jogos',
        'Um tipo de controle',
        'Uma loja de jogos',
        'Uma fase secreta',
      ],
      correctIndex: 0,
      explanation:
          'Engines como Godot e Unity reúnem ferramentas de física, gráficos, áudio e programação.',
    ),
    Question(
      id: 'loop',
      title: 'Qual exemplo representa um game loop?',
      options: [
        'O logotipo do estúdio',
        'A tela de instalação',
        'Explorar, coletar e evoluir',
        'Os créditos finais',
      ],
      correctIndex: 2,
      explanation:
          'O game loop é o ciclo de ações que o jogador repete durante a experiência.',
    ),
    Question(
      id: 'feedback',
      title: 'Por que dar feedback ao jogador?',
      options: [
        'Para esconder as regras',
        'Para impedir novas tentativas',
        'Para substituir os controles',
        'Para mostrar o efeito de suas ações',
      ],
      correctIndex: 3,
      explanation:
          'Sons, animações e pontos ajudam o jogador a entender o que aconteceu e a aprender.',
    ),
    Question(
      id: 'prototype',
      title: 'Qual é o objetivo de um protótipo?',
      options: [
        'Testar uma ideia rapidamente',
        'Ter todos os gráficos finais',
        'Publicar sem testar',
        'Evitar mudanças no jogo',
      ],
      correctIndex: 0,
      explanation:
          'Um protótipo permite testar a mecânica principal antes de investir na produção completa.',
    ),
  ];
}
