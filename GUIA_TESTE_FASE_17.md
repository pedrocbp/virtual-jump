# Fase 17 — visual, interface e game feel

Abra `project.godot` no Godot e pressione **F5**. Se já estiver rodando, pare com F8 e execute novamente. Não é necessário reinstalar dependências. A mudança visual aparece ao executar as cenas; os componentes da interface são montados por scripts.

## O que mudou

- Identidade noturna com menta, azul, âmbar e coral; fundo leve e desenho vetorial, sem texturas externas.
- Bolinha com brilho, rosto e deformação visual no salto/pouso. O raio da colisão continua 16 px; gravidade, impulso e controle horizontal foram preservados.
- Plataformas com contorno e símbolos: setas para móveis, rachadura para quebráveis, relógio e duração para temporárias. Perigos usam coral.
- Partículas leves no pouso, morte e chegada; reinício após 0,2 s e transições curtas entre telas.
- Sons de pouso, morte, vitória e botões; música ambiente sintetizada. O botão de som silencia música e efeitos durante a sessão.
- Seleção agrupada em seis capítulos, progresso e recordes; resultados exibem a medalha desta tentativa e avisam quando há novo recorde.
- Botão de pausa, reinício e acesso ao menu durante a partida; pausa automática ao perder foco.
- Pequena vibração na morte/chegada no Android. A permissão de vibração foi ativada no preset; precisa exportar um APK novo para receber a mudança.

## Teste pelo computador

1. F5: confira o menu, o botão de som e **Explorar as 30 fases**. As fases bloqueadas devem continuar bloqueadas.
2. Use **Jogar** ou selecione uma fase. A/D ou setas movem a bolinha; o salto continua automático.
3. Observe a deformação da bolinha e as pequenas partículas no pouso. A trajetória deve continuar igual à anterior.
4. Pressione **Esc** ou o botão **Ⅱ**. A bolinha, as plataformas, os perigos e o cronômetro devem parar. **Continuar** retoma a tentativa.
5. Caia ou encoste num perigo: há partículas, som e um breve realce; a fase reinicia com o tempo zerado e os objetos restaurados. R reinicia diretamente.
6. Termine a fase: o tempo para, a medalha corresponde à tentativa atual e o recorde anterior permanece se for melhor. Teste **Tentar novamente**, **Próxima fase** e **Seleção de fases**.
7. Abra `scenes/levels/Level30.tscn` e pressione F6 para conferir a composição final. Na conclusão, **Ver minha jornada** retorna à seleção; não tenta abrir uma Fase 31.
8. Para conferir cada mecanismo: Fase 3 (móvel), 4 (quebrável), 5 (temporária), 8 (serra), 9 (barra), 10 (perigo temporário).
9. Mude o foco para outra janela: a partida deve pausar. Volte e pressione **Continuar**.

## Teste no Android quando for conveniente

Exporte e instale um APK atualizado pelo preset existente. O APK antigo em `build` não foi reconstruído nesta etapa. Confira toque esquerdo/direito, dois dedos, liberação dos dedos, pausa, retorno do segundo plano, som e vibração. Tocar nos botões da interface não deve movimentar a bolinha.

## Arquivos e ajustes

- `scripts/ui/design.gd`: cores, estilos, botões e tipografia compartilhados.
- `scripts/ui/main_menu.gd`, `level_select.gd`, `game_hud.gd`: menu, seleção, HUD, pausa e resultados.
- `scripts/ui/sky_backdrop.gd`: fundo e ilustração animada do menu.
- `scripts/effects/object_skin.gd`, `burst.gd`: aparência dos objetos e partículas.
- `scripts/systems/feedback.gd`: áudio gerado localmente, transições e vibração; volumes em `_ready()`.
- `scripts/player/player.gd`: animação visual e entrada touch respeitando os botões.
- `scripts/levels/level_controller.gd`: ligação dos efeitos, morte, pausa e resultados.
- `scripts/platforms/moving_platform.gd`: retorno imediato à origem no restart.
- `scenes/main/Main.tscn`, `scenes/ui/MainMenu.tscn`, `scenes/ui/LevelSelect.tscn`: remoção da interface antiga.
- `project.godot`: serviço compartilhado Feedback; `export_presets.cfg`: vibração e exclusão dos testes/build da exportação.

## Verificação automatizada

`tests/phase17_smoke.gd` abre as 30 fases e verifica física básica preservada, toque, pausa, morte, reset, conclusão, áudio e transição. Usa salvamento em memória: não altera seu progresso. Em execução gráfica, grava capturas em `build/qa17`.

```powershell
& 'C:\Ferramentas\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --log-file 'build/phase17-test.log' --script res://tests/phase17_smoke.gd
```

O teste automático não substitui jogar os percursos nem ouvir o resultado em seu aparelho. Vibração e desempenho no Android ainda precisam de validação física. O botão de som é temporário nesta sessão; configurações persistentes e volumes separados pertencem à Fase 18.
