# PROJETO: Jogo Mobile de Plataforma Vertical

Quero que você atue como desenvolvedor de jogos sênior especializado em Godot, GDScript, jogos 2D e desenvolvimento mobile.

Seu objetivo será me ajudar a desenvolver este jogo completo utilizando **Godot 4.x + GDScript**, com foco inicialmente em **Android e publicação futura na Google Play Store**.

O desenvolvimento deve acontecer de maneira incremental.

NÃO implemente o jogo inteiro de uma vez.

O projeto deverá ser dividido em fases de implementação pequenas, funcionais e testáveis.

Ao final de cada fase, o projeto deve estar executável para que eu possa abrir no Godot, jogar, testar e verificar se tudo está funcionando antes de prosseguirmos.

---

# 1. TECNOLOGIAS

Utilize:

* Godot 4.x
* GDScript
* sistema de cenas do Godot
* sistema de Input Actions do Godot
* CharacterBody2D, Area2D, StaticBody2D e demais nodes adequados
* sistema de sinais do Godot quando apropriado
* arquivos Resource quando fizer sentido
* salvamento local utilizando APIs do Godot
* arquitetura preparada para Android
* orientação de tela vertical (portrait)

Evite dependências externas desnecessárias.

O projeto deve permanecer simples, organizado e fácil de manter.

---

# 2. PLATAFORMA

Plataforma principal:

Android.

Objetivo futuro:

publicação na Google Play Store.

O jogo deverá ser projetado desde o início considerando:

* diferentes resoluções de celular;
* diferentes proporções de tela;
* controles touchscreen;
* desempenho em aparelhos intermediários;
* orientação vertical;
* interface responsiva.

Durante o desenvolvimento também deve ser possível testar pelo computador.

Para isso, os controles deverão possuir equivalentes:

PC:

A / seta esquerda = esquerda.

D / seta direita = direita.

Mobile:

pressionar lado esquerdo da tela = esquerda.

pressionar lado direito da tela = direita.

---

# 3. CONCEITO

O jogo será um jogo casual 2D de plataforma vertical.

O jogador controla uma bolinha.

A bolinha pula automaticamente.

O jogador NÃO controla o salto.

O jogador controla somente o movimento horizontal.

O objetivo é subir pelas plataformas até alcançar o final da fase.

Cada fase será curta.

A experiência deverá incentivar repetição e speedrun.

Fluxo principal:

Selecionar fase
→ iniciar
→ subir
→ evitar perigos
→ chegar ao final
→ registrar tempo
→ visualizar resultado
→ tentar novamente ou avançar.

---

# 4. MOVIMENTAÇÃO

A bolinha deverá possuir física consistente e previsível.

Ela pula automaticamente ao tocar corretamente na parte superior de uma plataforma enquanto estiver caindo.

O jogador controla horizontalmente:

* aceleração;
* velocidade;
* mudança de direção;
* desaceleração.

O movimento deverá funcionar também enquanto a bolinha estiver no ar.

Ao soltar o controle horizontal, sua influência deverá diminuir suavemente.

Não utilizar física aleatória.

O jogador precisa conseguir aprender intuitivamente:

* altura do salto;
* distância máxima;
* velocidade horizontal;
* mudança de direção;
* momento correto para aterrissar.

Esses valores deverão ficar centralizados em variáveis configuráveis para facilitar o balanceamento.

Exemplos:

jump_force
gravity
horizontal_acceleration
max_horizontal_speed
horizontal_deceleration
air_control

Não espalhe números mágicos pelo código.

---

# 5. PLATAFORMAS

Inicialmente implementar apenas:

Plataforma normal.

Ela permanece parada.

Quando a bolinha estiver DESCENDO e tocar corretamente sua superfície superior, deverá receber automaticamente um novo impulso vertical.

Não permitir que colisões laterais provoquem saltos indevidos.

Posteriormente serão adicionadas:

* plataforma móvel;
* plataforma quebrável;
* plataforma temporária;
* plataforma pequena.

Cada tipo deverá possuir sua própria cena/componente quando necessário.

---

# 6. CÂMERA

O jogo possui progressão vertical.

A câmera acompanha a subida da bolinha.

Porém ela NÃO deverá acompanhar cada pequeno movimento vertical.

Utilize um sistema semelhante a uma zona de acompanhamento.

Enquanto a bolinha estiver abaixo de determinado ponto da tela:

a câmera permanece parada.

Quando ultrapassar determinada altura:

a câmera começa a subir.

Preferencialmente a câmera nunca deverá descer durante uma tentativa.

O jogador precisa conseguir visualizar as próximas plataformas antes de alcançá-las.

O movimento da câmera deverá ser suave.

---

# 7. MORTE

Existem inicialmente duas formas de morrer:

1. cair abaixo da área válida da fase;
2. tocar em um obstáculo.

Regra:

tocou no perigo = morreu.

Não existe:

* barra de vida;
* HP;
* dano parcial.

Ao morrer:

Morreu
→ pequeno feedback visual
→ reiniciar rapidamente.

Evitar telas intermediárias desnecessárias.

O objetivo é permitir várias tentativas consecutivas.

Ao reiniciar:

* posição inicial restaurada;
* estado da fase restaurado;
* cronômetro zerado;
* obstáculos restaurados.

---

# 8. OBSTÁCULOS

Primeiro obstáculo:

espinho.

Utilizar Area2D ou estrutura equivalente apropriada.

Contato com a bolinha provoca morte imediata.

Depois poderão existir:

* blocos perigosos;
* serras;
* barras;
* obstáculos móveis;
* obstáculos temporários.

Todos os perigos deverão utilizar uma arquitetura comum quando possível.

---

# 9. FINAL DA FASE

Cada fase terá uma área de chegada.

Utilizar:

Goal / FinishArea.

Quando a bolinha entrar nessa área:

* bloquear imediatamente o cronômetro;
* impedir controles;
* registrar conclusão;
* verificar melhor tempo;
* desbloquear próxima fase;
* abrir tela de resultado.

---

# 10. CRONÔMETRO

Cada fase possui cronômetro independente.

Começa quando a tentativa realmente começa.

Para quando o jogador chega ao final.

Formato:

00:18.42

Precisão mínima:

centésimos de segundo.

O cronômetro não deverá continuar durante:

* pausa;
* tela de resultado;
* morte;
* carregamento.

---

# 11. MELHOR TEMPO

Cada fase terá seu próprio recorde local.

Exemplo:

Fase 3

Tempo atual:
18.42

Melhor tempo:
16.81

Se:

tempo_atual < melhor_tempo

atualizar recorde.

O recorde deverá permanecer salvo depois de fechar o jogo.

---

# 12. MEDALHAS

Posteriormente cada fase possuirá:

Bronze
Prata
Ouro.

Bronze:

concluir a fase.

Prata:

atingir determinado tempo.

Ouro:

atingir um tempo ainda menor.

Os valores deverão ser configuráveis individualmente por fase.

Exemplo:

silver_time = 30.0
gold_time = 22.0

Não colocar esses valores diretamente na lógica global.

---

# 13. PROGRESSÃO

Inicialmente somente:

Fase 1

estará disponível.

Completar:

Fase 1 → desbloqueia Fase 2.

Fase 2 → desbloqueia Fase 3.

E assim sucessivamente.

Uma fase desbloqueada nunca deverá voltar a ficar bloqueada.

O jogador poderá jogar novamente qualquer fase já desbloqueada.

---

# 14. SALVAMENTO

Salvar localmente:

* maior fase desbloqueada;
* fases concluídas;
* melhor tempo;
* medalhas;
* configurações.

Posteriormente:

* moedas;
* skins;
* cosméticos.

Criar um SaveManager centralizado.

Não espalhar lógica de salvamento pelos scripts das fases.

O sistema deverá conseguir lidar com save inexistente ou corrompido sem impedir que o jogo abra.

---

# 15. ESTRUTURA DAS FASES

Planejamento inicial:

30 fases.

Fases 1–5:
aprendizado.

Fases 6–10:
obstáculos simples.

Fases 11–15:
plataformas menores e precisão.

Fases 16–20:
plataformas móveis.

Fases 21–25:
obstáculos móveis.

Fases 26–30:
combinação das mecânicas.

As primeiras fases deverão durar aproximadamente:

15–40 segundos.

Cada nova mecânica deverá primeiro aparecer isoladamente em uma situação fácil.

Somente depois poderá ser combinada com outras mecânicas.

---

# 16. FASE 1

A Fase 1 funcionará como tutorial jogável.

Não deverá existir tutorial textual grande.

Ela possuirá:

* ponto inicial;
* bolinha;
* plataformas grandes;
* distâncias pequenas;
* caminho simples;
* nenhuma armadilha;
* chegada.

Ela deverá ensinar naturalmente:

* salto automático;
* esquerda;
* direita;
* funcionamento das plataformas.

---

# 17. INTERFACE

Durante a fase mostrar apenas informações importantes.

Inicialmente:

FASE 1

TEMPO
00:12.38

Interface minimalista.

Não ocupar área importante da gameplay.

---

# 18. RESULTADO

Ao terminar:

FASE CONCLUÍDA

Tempo:
18.42 s

Melhor:
16.81 s

Medalha:
OURO

Botões:

Tentar novamente
Próxima fase

Posteriormente poderá existir botão para seleção de fases.

---

# 19. SELEÇÃO DE FASES

Criar tela com todas as fases.

Exemplo:

1 ✓
Melhor: 18.42

2 ✓
Melhor: 25.17

3
Melhor: —

4 🔒

5 🔒

Fases bloqueadas não podem ser abertas.

---

# 20. VISUAL

Estilo:

minimalista.

Fundo:

cor sólida.

Personagem:

bolinha geométrica simples.

Plataformas:

formas geométricas.

Perigos:

visualmente diferentes das plataformas.

Não utilizar inicialmente:

* cenários complexos;
* partículas pesadas;
* shaders complexos;
* modelos 3D.

Durante o protótipo, utilize formas e assets temporários simples.

A prioridade é gameplay.

---

# 21. ARQUITETURA

Quero código organizado.

Sugestão inicial de estrutura:

res://

scenes/
main/
levels/
player/
platforms/
obstacles/
ui/

scripts/
player/
levels/
systems/
ui/

resources/

assets/
sprites/
audio/
fonts/

Autoloads possíveis:

GameManager
SaveManager
LevelManager
AudioManager

Porém:

NÃO crie managers desnecessários.

Só utilize Autoload quando existir justificativa arquitetural.

Prefira composição e sinais a dependências globais excessivas.

---

# 22. PRINCÍPIOS DE DESENVOLVIMENTO

Prioridade:

1. gameplay;
2. controles;
3. física;
4. sensação do salto;
5. câmera;
6. level design;
7. progressão;
8. interface;
9. visual;
10. monetização.

Não desenvolver sistemas futuros antes do núcleo estar validado.

Não implementar antecipadamente:

* anúncios;
* compras;
* login;
* servidor;
* ranking online;
* multiplayer;
* moedas;
* skins;
* conquistas;
* analytics.

---

# 23. DESENVOLVIMENTO POR FASES

O desenvolvimento deverá seguir EXATAMENTE uma abordagem incremental.

## FASE DE IMPLEMENTAÇÃO 0 — Projeto

Objetivo:

criar estrutura inicial.

Implementar:

* projeto Godot;
* configuração portrait;
* resolução base;
* Input Map;
* estrutura de diretórios;
* cena principal mínima.

Resultado esperado:

o projeto abre e executa corretamente.

PARAR.

Eu testarei.

---

## FASE DE IMPLEMENTAÇÃO 1 — Protótipo da bolinha

Implementar somente:

* bolinha;
* gravidade;
* salto automático;
* movimento horizontal;
* plataforma normal;
* chão/plataforma inicial;
* controles teclado.

Criar uma pequena área de teste.

NÃO implementar câmera.

NÃO implementar obstáculos.

NÃO implementar fases.

Objetivo:

validar a física.

Permitir alterar facilmente:

* gravidade;
* força do salto;
* aceleração;
* velocidade;
* desaceleração.

Resultado esperado:

eu consigo controlar a bolinha e pular repetidamente entre algumas plataformas.

PARAR.

Eu testarei.

---

## FASE DE IMPLEMENTAÇÃO 2 — Touchscreen

Adicionar:

* toque lado esquerdo;
* toque lado direito;
* suporte multitouch se necessário;
* manter teclado funcionando.

Resultado:

mesma gameplay funcionando em PC e celular.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 3 — Câmera vertical

Implementar:

* Camera2D;
* zona vertical;
* acompanhamento suave;
* câmera sobe;
* câmera não fica oscilando com cada salto;
* preferencialmente não desce.

Criar uma torre simples de plataformas para testar.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 4 — Primeira fase completa

Transformar o protótipo em:

Level01.

Adicionar:

* spawn;
* plataformas;
* chegada;
* início;
* conclusão.

Ainda sem obstáculos.

Fase deverá levar aproximadamente:

15–30 segundos.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 5 — Cronômetro

Adicionar:

* timer;
* início da tentativa;
* parada ao concluir;
* exibição na HUD;
* centésimos.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 6 — Morte e restart

Adicionar:

* detecção de queda;
* reinício rápido;
* reset do timer;
* tecla de restart para desenvolvimento.

Objetivo:

Morrer → reiniciar → jogar

deve acontecer quase instantaneamente.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 7 — Obstáculos

Criar:

Hazard base.

Primeiro tipo:

Spike.

Contato:

morte imediata.

Criar Level02/Level03 ou área específica para testar.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 8 — Sistema de fases

Criar estrutura reutilizável para:

Level01
Level02
Level03...

Cada fase deverá possuir configurações próprias.

Evitar duplicar scripts desnecessariamente.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 9 — Save

Criar:

SaveManager.

Salvar:

* fase desbloqueada;
* conclusão;
* melhor tempo.

Testar:

fechar jogo
→ abrir
→ progresso continua.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 10 — Tela de resultado

Adicionar:

FASE CONCLUÍDA

Tempo
Melhor tempo

Tentar novamente
Próxima fase

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 11 — Seleção de fases

Criar tela Level Select.

Mostrar:

* número;
* bloqueio;
* conclusão;
* melhor tempo.

Implementar desbloqueio progressivo.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 12 — Menu

Criar:

Jogar
Selecionar fase
Configurações

Jogar:

abre a próxima fase ainda não concluída.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 13 — Medalhas

Adicionar:

Bronze
Prata
Ouro.

Tempos configuráveis individualmente.

Salvar melhor medalha.

Mostrar na seleção de fases.

PARAR.

---

## FASE DE IMPLEMENTAÇÃO 14 — Novas plataformas

Implementar individualmente.

14A:
plataforma móvel.

TESTAR.

14B:
plataforma quebrável.

TESTAR.

14C:
plataforma temporária.

TESTAR.

Nunca implementar todas simultaneamente sem testes intermediários.

---

## FASE DE IMPLEMENTAÇÃO 15 — Novos obstáculos

Adicionar individualmente:

15A:
bloco perigoso.

15B:
serra móvel.

15C:
barra móvel.

15D:
obstáculo temporário.

Testar individualmente.

---

## FASE DE IMPLEMENTAÇÃO 16 — Level design

Somente depois das mecânicas estarem validadas:

construir as 30 fases.

Não gerar automaticamente as 30 fases de uma vez.

Criar em lotes:

1–5
TESTAR

6–10
TESTAR

11–15
TESTAR

16–20
TESTAR

21–25
TESTAR

26–30
TESTAR.

---

## FASE DE IMPLEMENTAÇÃO 17 — Game Feel

Depois do gameplay validado:

adicionar cuidadosamente:

* partículas;
* squash/stretch;
* animação da bolinha;
* feedback de pouso;
* feedback de morte;
* transições;
* sons;
* música;
* pequenas vibrações mobile.

Esses efeitos não deverão alterar a física real.

PARAR para avaliação.

---

## FASE DE IMPLEMENTAÇÃO 18 — Configurações

Adicionar:

* música;
* efeitos sonoros;
* vibração;
* volume;
* opção de reiniciar progresso, com confirmação.

Salvar configurações.

---

## FASE DE IMPLEMENTAÇÃO 19 — Android

Preparar:

* exportação Android;
* ícone;
* package/application ID;
* portrait;
* permissões mínimas;
* build de teste;
* AAB quando apropriado;
* testes em aparelho físico.

Não solicitar permissões que o jogo não utiliza.

---

## FASE DE IMPLEMENTAÇÃO 20 — QA

Testar:

* resoluções diferentes;
* proporções diferentes;
* FPS;
* touch;
* reinício;
* save;
* fases;
* timers;
* desbloqueios;
* pausa;
* áudio;
* background/resume do Android.

Procurar:

* softlocks;
* colisões incorretas;
* exploits;
* timer continuando indevidamente;
* save corrompido;
* fases impossíveis;
* plataformas fora da tela.

---

## FASE DE IMPLEMENTAÇÃO 21 — Publicação

Somente depois do jogo estar estável:

preparar versão para Google Play.

Verificar requisitos atuais da Google Play antes da publicação.

Preparar:

* AAB;
* assinatura;
* package ID definitivo;
* versionamento;
* ícone;
* screenshots;
* descrição;
* classificação indicativa;
* política de privacidade quando necessária;
* Data Safety;
* testes exigidos pela Google Play;
* compatibilidade Android exigida naquele momento.

Não assumir requisitos antigos da Google Play.

Consultar documentação atual antes desta etapa.

---

# 24. REGRA FUNDAMENTAL PARA VOCÊ, IA

NUNCA avance automaticamente para a próxima fase de implementação.

Quando eu disser:

"Implemente a Fase 1"

implemente SOMENTE a Fase 1.

Ao terminar:

1. informe resumidamente o que foi criado;
2. liste arquivos criados/modificados;
3. informe exatamente como testar;
4. informe o comportamento esperado;
5. informe problemas conhecidos, se existirem;
6. PARE.

Espere meu feedback.

Se eu encontrar um bug:

corrija o bug antes de avançar.

Somente avance quando eu explicitamente disser algo como:

"Está funcionando. Vamos para a próxima fase."

---

# 25. ALTERAÇÕES NO PROJETO

Antes de modificar código existente:

* analise os arquivos relevantes;
* entenda a implementação atual;
* preserve funcionalidades existentes;
* evite reescrever sistemas que já funcionam sem necessidade.

Ao corrigir bugs:

procure a causa raiz.

Não aplique soluções improvisadas apenas para esconder o problema.

---

# 26. QUALIDADE DO CÓDIGO

O código deve:

* utilizar tipagem em GDScript quando apropriado;
* possuir nomes claros;
* evitar duplicação;
* possuir responsabilidades bem definidas;
* evitar scripts gigantes;
* evitar acoplamento desnecessário;
* usar sinais quando fizer sentido;
* manter parâmetros de gameplay configuráveis.

Comentários devem explicar decisões importantes.

Não comentar linhas óbvias.

---

# 27. REGRA SOBRE COMPLEXIDADE

Não faça overengineering.

Este é inicialmente um jogo indie mobile pequeno.

Prefira:

solução simples + confiável + fácil de testar

em vez de:

arquitetura complexa + abstrata + difícil de manter.

Porém organize o projeto de maneira que seja possível adicionar novas fases, plataformas e obstáculos sem reconstruir todo o jogo.

---

# 28. PRIORIDADE ABSOLUTA

Antes de criar 30 fases, menus bonitos, skins ou monetização, precisamos responder:

"A movimentação da bolinha é divertida?"

A Fase de Implementação 1 é uma das etapas mais importantes do projeto.

Ajustaremos repetidamente:

* gravidade;
* salto;
* aceleração;
* velocidade;
* controle aéreo;
* tamanho da bolinha;
* tamanho das plataformas.

Somente depois que a movimentação estiver satisfatória devemos investir no restante do jogo.

---

# PRIMEIRA TAREFA

Comece analisando este plano.

Não implemente todas as fases.

Primeiro verifique se o ambiente possui o Godot necessário e examine o estado atual do projeto.

Se o diretório ainda não possuir um projeto Godot, prepare somente a:

FASE DE IMPLEMENTAÇÃO 0.

Quando terminar, pare e me forneça as instruções para teste.
