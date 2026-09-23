# Configurações e fases 31–40

Foram concluídas a Fase 18 e a expansão solicitada para 40 níveis, com vento, laser intermitente e plataforma que cai. A Fase 19 (preparação/publicação Android) não foi iniciada e o APK antigo não foi reconstruído.

## Abrir e testar

Pare a execução com **F8** e inicie com **F5**. Se o editor ainda mostrar o erro antigo de `GameDesign`, feche e abra o projeto novamente. Os scripts agora carregam `scripts/ui/design.gd` explicitamente.

No menu, abra **Configurações**. Durante uma fase, use **Esc** ou **Ⅱ**, depois **Configurações**. Voltar desta tela retorna à pausa, sem perder sua tentativa.

- Música e efeitos podem ser ligados/desligados independentemente.
- Ajuste os volumes geral, da música e dos efeitos. O volume geral multiplica os outros volumes; em zero, nenhum áudio toca.
- **Silenciar tudo** suspende o áudio sem apagar os níveis de volume escolhidos.
- **Ouvir efeito de teste** respeita o volume geral, o volume dos efeitos e as opções de silenciar/desativar.
- Role a tela para encontrar **Vibração** e **Reiniciar meu progresso**.
- As mudanças são salvas automaticamente. Feche o jogo e abra novamente para verificar.
- O botão de reset abre uma confirmação com **Cancelar** selecionado. Cancelar ou apertar Esc mantém o progresso. Confirmar apaga fases concluídas, medalhas e recordes, libera somente a fase 1 e retorna ao menu; as configurações são mantidas.

O seu progresso real não foi apagado durante o desenvolvimento. Os testes usaram dados fictícios e um arquivo separado em `build/qa18/test_save.json`.

## As novas fases

Abra `scenes/levels/Level31.tscn` no Sistema de Arquivos e pressione **F6**. Faça o mesmo até `Level40.tscn`. F6 permite testar diretamente sem desbloquear as anteriores. No fluxo normal, concluir a fase 30 libera a 31, seguindo até a 40.

| Fase | Percurso | Mecânicas principais |
| --- | --- | --- |
| 31 | Primeira corrente | Vento para a direita, isolado |
| 32 | Sinal de alerta | Laser com aviso amarelo, isolado |
| 33 | O chão vai cair | Plataforma que treme e cai, isolada |
| 34 | Contra a corrente | Vento para a esquerda e plataforma temporária |
| 35 | Passagem luminosa | Laser, plataforma móvel e pequena |
| 36 | Precisão em queda | Plataformas pequenas e plataforma que cai |
| 37 | O ritmo do vento | Vento e plataformas temporárias |
| 38 | Apoios em fuga | Plataforma móvel, plataformas que caem e serra |
| 39 | Luzes e serras | Laser, serra e precisão |
| 40 | Domínio dos elementos | Vento, laser, queda e plataformas especiais |

## Comportamento esperado

**Vento:** dentro do retângulo azul, a corrente empurra na direção das setas. Segure a direção contrária para compensar. Fora da área, o empurrão termina. Força, sentido e tamanho ficam no Inspector do nó `WindField`. A força é uma velocidade lateral adicional em px/s, limitada para permitir compensação.

**Laser:** tracejado discreto = desligado e seguro; tracejado amarelo destacado = aviso antes de ligar; feixe vermelho com centro claro = ativo e fatal. Começa desligado a cada tentativa. Pode matar também se ativar enquanto a bolinha já estiver dentro do feixe. Os emissores indicam a extensão do feixe; ajuste `beam_length`, `inactive_duration`, `warning_duration` e `active_duration`.

**Plataforma que cai:** tem setas para baixo. Pousar por cima dispara a tremida visual, preservando o salto automático. Após `fall_delay` (0,4 s por padrão), ela cai com aceleração. Contato lateral não dispara a queda. Após sair muito abaixo da origem, desaparece até o reinício. Reiniciar restaura posição, colisão e estado.

Todos os ciclos param durante a pausa e voltam ao estado inicial ao reiniciar. As posições das plataformas antigas das fases 1–30 foram preservadas.

## Arquivos principais

- `scripts/systems/save_manager.gd`: preferências persistentes, leitura compatível com saves antigos e reset de progresso; gravação por arquivo temporário.
- `scripts/systems/feedback.gd`: volumes, opções de áudio/vibração e abertura das configurações.
- `scripts/ui/settings_panel.gd`: controles, rolagem e confirmação de reset.
- `scripts/systems/level_catalog.gd`: total de 40 níveis e oito capítulos.
- `scenes/levels/Level31.tscn` até `Level40.tscn` e seus arquivos em `resources/levels`.
- `scenes/obstacles/WindField.tscn` e `IntermittentLaser.tscn`, com scripts em `scripts/obstacles`.
- `scenes/platforms/FallingPlatform.tscn` e `scripts/platforms/falling_platform.gd`.
- `scripts/player/player.gd`: empurrão de vento separado do controle horizontal e aviso de pouso à plataforma.
- Scripts de menu, seleção, HUD, controlador e estilos: adaptação para 40 fases e carregamento explícito do design.
- `tests/phase18_and_levels.gd`: regressão das 40 cenas, configurações e novas mecânicas.

## Validação automática e limites

O teste verifica gravação/leitura de configurações em arquivo isolado, migração, reset confirmado/cancelado, áudio, pausa e retorno, carregamento das 40 fases, vento compensável, ciclo e contato do laser, pouso real na plataforma e reinício. A execução gráfica também salva capturas em `build/qa18`.

```powershell
& 'C:\Ferramentas\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --log-file 'build/phase18-mechanics.log' --script res://tests/phase18_and_levels.gd
```

Os tempos de medalhas e a dificuldade dos novos percursos ainda precisam do seu teste jogando. Vibração, volume percebido e desempenho precisam ser conferidos no Android após exportar um APK atualizado.

## Temas visuais e game feel

Abra **Configurações > Aparência** para escolher um dos três temas:

- **Original:** mantém a identidade colorida atual.
- **Minimalista escuro:** fundo preto e elementos brancos.
- **Minimalista claro:** fundo branco e elementos pretos.

A troca é imediata, vale para menus, HUD, bolinha, plataformas e obstáculos, e permanece salva depois de fechar o jogo. Teste principalmente a visibilidade do laser, dos espinhos e das plataformas temporárias nos dois temas minimalistas.

Durante uma fase, confira também os novos retornos de movimento: a bolinha estica durante o salto, comprime no pouso, deixa um rastro discreto em alta velocidade e solta partículas ao tocar a plataforma. A morte mantém a bolinha visível por uma animação curta, produz partículas, vibração e um pequeno tremor de câmera antes do reinício. Esses efeitos não alteram gravidade, velocidade, força do salto ou colisão.

A Fase 35 foi reposicionada em zigue-zague. Teste a sequência completa, incluindo a plataforma móvel, a plataforma pequena e a passagem pelo laser, para confirmar o equilíbrio no controle por toque.
