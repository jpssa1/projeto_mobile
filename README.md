# Maragames — base Flutter

Home responsiva, questionário sobre criação de jogos e jogo da cobrinha. O quiz oferece feedback, progresso, 20 XP por acerto, resultado e reinício. Identidade visual inspirada em https://maragames.app: roxo, vermelho, fundo claro e cartões arredondados. Mascote obtido do site de referência e mantido localmente em `assets/images/mascot.png`.

## Executar

```sh
flutter pub get
flutter run
```

## Organização e responsabilidades

### Acesso demonstrativo

Depois da splash, o app abre o login (`/login`). As telas de cadastro
(`/cadastro`) e recuperação de senha (`/recuperar-senha`) estão disponíveis pelos
links do formulário. Todas mantêm a identidade visual e permitem rolagem com o
teclado aberto ou em telas pequenas.

Este fluxo é um protótipo: use dados fictícios. O login aceita qualquer e-mail
válido e senha com pelo menos 6 caracteres; também é possível explorar sem
entrar. O cadastro valida nome, e-mail, senha e confirmação. A recuperação exibe
uma confirmação de simulação. Não há autenticação real, persistência de credenciais, criação
de conta ou envio de e-mail. A home oferece um botão para voltar ao login.

### Estrutura

O padrão de pastas existente foi preservado, incluindo o nome `view model`.

- `lib/core`: composição do app, rotas GoRouter e tema.
- `lib/utils/widgets`: cartões e mascote compartilhados.
- `lib/features/auth`: telas e widgets do acesso demonstrativo.
- `lib/features/home/{model,view,view model}`: conteúdo e apresentação da home. O provider expõe conteúdo imutável porque a home ainda não tem operações assíncronas.
- `lib/features/quiz/model`: modelos imutáveis e contrato `QuizRepository`.
- `lib/features/quiz/repository`: implementação local do contrato.
- `lib/features/quiz/view model`: `AsyncNotifier` Riverpod; seleção, confirmação, pontuação e transições.
- `lib/features/quiz/view`: interface que observa o estado e chama comandos do ViewModel.
- `lib/features/snake/model`: posições, direções, estado imutável e contrato `SnakeRepository`.
- `lib/features/snake/repository`: sorteio de comida somente nas casas livres.
- `lib/features/snake/view model`: `Notifier` Riverpod com movimento, colisões, pontuação, pausa e temporizador descartável.
- `lib/features/snake/{view,widgets}`: tela, tabuleiro desenhado com `CustomPainter` e controles.
- `lib/features/progress`: métricas agregadas, armazenamento local, sessões de tempo ativo, providers e tela de progresso.

As views não fazem requisições nem calculam pontuação. Os ViewModels dependem de abstrações de repositório, substituíveis via provider. Isso mantém responsabilidades separadas e permite extensão e testes sem modificar a interface. Os jogos funcionam localmente, sem backend. As métricas usam `shared_preferences` para persistência no dispositivo.

## Jogo da cobrinha

Na home, selecione **Jogar cobrinha** para abrir `/cobrinha`. O tabuleiro tem 16 × 16 casas. Use os botões direcionais, as setas do teclado ou WASD para coletar o losango vermelho. Cada comida soma 10 pontos e aumenta o corpo. Encostar nas paredes ou no próprio corpo encerra a partida; preencher o tabuleiro gera vitória. Inverter diretamente a direção não é permitido.

Antes de começar, é possível ativar **Jogar no meu ritmo**: cada direção move uma casa e o botão **Avançar um passo** mantém a direção atual, sem temporizador. Esse modo também anuncia as coordenadas da cabeça e da comida para leitores de tela. O tabuleiro usa formas diferentes para comida e corpo, e os controles têm rótulos e áreas de toque amplas.

**Pausar jogo**, **Continuar jogo** ou a tecla P controlam a pausa. Ao sair do app, a partida pausa e exige continuação explícita. **Reiniciar jogo** e **Jogar novamente** zeram a pontuação e retornam à preparação, preservando o modo escolhido. Sair da rota descarta o tabuleiro e cancela o temporizador, preservando as métricas. Os pontos da cobrinha são independentes do XP do quiz.

O XP apresentado no quiz é por tentativa; sair descarta as respostas da partida, mas preserva os totais e o melhor resultado em **Meu progresso**. Autenticação real e ranking não fazem parte desta base.

## Métricas de aprendizagem

Abra **Meu progresso** pelo ícone na home, pelo cartão **Ver meu progresso** ou pelo resultado da missão. A tela apresenta:

- Tempo ativo, tentativas e conclusões por atividade (quiz e cobrinha).
- XP acumulado e melhor tentativa do quiz; recorde da cobrinha.
- Respostas enviadas, acertos, erros e percentual de acerto no quiz.
- Assuntos ordenados pela quantidade de erros, incluindo empates no destaque de revisão.

Uma tentativa do quiz começa após carregar as perguntas; na cobrinha, somente ao pressionar **Começar jogo**. Reiniciar ou sair encerra a tentativa sem marcar conclusão. O quiz conta conclusão ao abrir o resultado; a cobrinha conta a partida encerrada na colisão ou vitória. Abrir o progresso não inicia tentativas.

Cada confirmação no quiz e cada toque na pergunta com imagem contam como uma resposta enviada. Portanto, dois toques errados seguidos de um acerto somam três respostas, dois erros e um acerto para o assunto, mas concedem somente 20 XP. As trocas de alternativa antes da confirmação não contam como respostas. A cobrinha não produz estatísticas de acerto ou erro por assunto.

O cronômetro exclui segundo plano, pausas da cobrinha e tempo no resultado. Há checkpoints a cada 5 segundos e registros ao responder, pausar, sair ou reiniciar. Um fechamento abrupto pode perder o tempo desde o último checkpoint. As gravações são serializadas para preservar sua ordem.

Os totais são restaurados ao reabrir o app. O histórico é agregado por dispositivo (por origem/navegador na web), compartilhado entre acesso demonstrativo e visitante. Não é vinculado a contas e não sincroniza entre dispositivos. Falhas no armazenamento exibem um aviso na tela de progresso e permitem continuar jogando.

## Abertura animada

A splash exibe a marca Maragames, composta pelo mascote local e pelo nome, com entrada por opacidade, deslocamento e escala durante 1 segundo. Após 1,8 segundo, há uma transição suave para a rota inicial. A apresentação acontece uma vez por abertura do app e respeita a preferência de movimento reduzido, exibindo a marca estática nesse caso.

## Validação

```sh
flutter analyze
flutter test
flutter build web --release
```

Os testes cobrem acesso demonstrativo, quiz, navegação e regras da cobrinha: comida, crescimento, pontuação, inversão de direção, colisões, vitória, pausa, reinício e descarte do temporizador. Também verificam teclado, toque, semântica do tabuleiro, texto ampliado e alvos de toque em viewport de celular.

As métricas têm cobertura de restauração do armazenamento, pausas e segundo plano, reinícios, descarte de rotas, prevenção de duplicações, erros intermediários na imagem e falhas de gravação. A splash tem verificação de animação e movimento reduzido. A tela de progresso é exercitada em celular com texto ampliado.
