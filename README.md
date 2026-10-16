# Maragames — base Flutter

Home responsiva e questionário de cinco perguntas sobre criação de jogos, com feedback, progresso, 20 XP por acerto, resultado e reinício. Identidade visual inspirada em https://maragames.app: roxo, vermelho, fundo claro e cartões arredondados. Mascote obtido do site de referência e mantido localmente em `assets/images/mascot.png`.

## Executar

```sh
flutter pub get
flutter run
```

## Organização e responsabilidades

O padrão de pastas existente foi preservado, incluindo o nome `view model`.

- `lib/core`: composição do app, rotas GoRouter, tema, cliente Dio e widgets compartilhados.
- `lib/features/home/{model,view,view model}`: conteúdo e apresentação da home. O provider expõe conteúdo imutável porque a home ainda não tem operações assíncronas.
- `lib/features/questionario/model`: modelos imutáveis e contrato `QuizRepository`.
- `lib/features/questionario/data`: implementações local e remota do contrato.
- `lib/features/questionario/view model`: `AsyncNotifier` Riverpod; seleção, confirmação, pontuação e transições.
- `lib/features/questionario/view`: interface que observa o estado e chama comandos do ViewModel.

As views não fazem requisições nem calculam pontuação. O ViewModel depende de uma abstração de repositório, substituível via provider. Dio fica restrito à implementação remota. Isso mantém responsabilidades separadas e permite extensão e testes sem modificar a interface.

## API com Dio

Sem configuração, usa perguntas locais, sem depender de rede. Para habilitar o repositório remoto:

```sh
flutter run --dart-define=API_BASE_URL=https://sua-api.example
```

Contrato proposto (ainda sem backend conectado): `GET /questions`, com um array JSON:

```json
[
  {
    "id": "design",
    "title": "Qual é o papel do game design?",
    "options": ["Criar apenas os desenhos", "Definir regras e experiências"],
    "correctIndex": 1,
    "explanation": "Game design define regras e experiências do jogo."
  }
]
```

`correctIndex` começa em zero. O cliente tem timeout de conexão e leitura. Há estados de carregamento, erro e nova tentativa. No navegador, a API deve permitir CORS. Android já tem permissão de internet no manifesto principal. Use HTTPS.

O XP é por tentativa e fica apenas em memória; sair do quiz descarta a tentativa. Persistência, login e ranking não fazem parte desta base. A correção local é apropriada para demonstração; recompensas competitivas exigiriam validação no servidor.

## Validação

```sh
flutter analyze
flutter test
flutter build web --release
```

Os testes cobrem fluxo completo com erro e acertos, proteção contra pontuação duplicada, reinício, falha de repositório e navegação da home ao quiz em viewport de celular.
