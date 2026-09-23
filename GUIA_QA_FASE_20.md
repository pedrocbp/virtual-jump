# Fase 20 — QA e validação

## Teste automático

No PowerShell, dentro da pasta do projeto:

```powershell
& "C:\Ferramentas\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --script res://tests/phase20_qa.gd
```

Resultado esperado:

```text
FASE20 QA: 40 fases, 3 resoluções, menu, HUD, câmera, restart e inputs. Falhas: 0
```

## Teste manual no computador

1. Abra o projeto no Godot.
2. Use `F6` para testar uma fase individual.
3. Teste as fases 8, 9, 21, 23, 24, 32, 33, 34, 35, 38, 39 e 40.
4. Pressione `R` durante a fase e confirme que plataformas móveis, lasers e plataformas que caem retornam ao estado inicial.
5. Abra e feche a pausa; o cronômetro e a bolinha devem ficar congelados.
6. Redimensione a janela e confirme que a fase continua centralizada e que a HUD permanece visível.

## Teste manual no Android

- Toque no lado esquerdo e direito para mover a bolinha.
- Gire ou redimensione a tela: o jogo deve permanecer em portrait.
- Teste reinício rápido, pausa, áudio e vibração.
- Bloqueie e desbloqueie o aparelho durante uma fase; confirme que o jogo não perde o estado nem deixa o cronômetro avançar indevidamente.
- Feche e reabra o jogo; confirme que configurações e progresso continuam salvos.
- Teste pelo menos uma fase com cada mecânica: espinho, quadrado de dano, plataforma móvel, laser, vento e plataforma que cai.

## Critérios para encerrar a Fase 20

- Teste automático com 0 falhas.
- Nenhuma fase impossível ou com rota bloqueada.
- Nenhum softlock depois de morrer ou reiniciar.
- Nenhuma plataforma importante fora da tela.
- Controles, pausa, save e timer funcionando no Android.

Enquanto o desenvolvimento continuar, `DEVELOPMENT_MODE` permanece ativo para liberar as 40 fases. Antes da publicação, altere-o para `false` em `scripts/systems/save_manager.gd`.
