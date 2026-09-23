# Fase 19 — Android

Esta fase prepara o projeto para testes Android e para a futura publicação. O aplicativo usa a identidade **VERTICAL** e o pacote anônimo **`com.verticaljump.arcade`**.

Como o pacote mudou em relação aos APKs antigos, esta versão aparece como um novo aplicativo no celular. O progresso da instalação anterior não é compartilhado com ela.

## Binários gerados

- `build/vertical-0.1.0-debug.apk`: versão de desenvolvimento para instalar e testar no celular.
- `build/vertical-0.1.0-debug.aab`: bundle de desenvolvimento usado para validar a compilação Gradle.

O AAB atual **não deve ser enviado à Google Play**. Na fase de publicação será criada uma chave de assinatura privada, com senha escolhida e guardada pelo responsável pelo jogo. Essa chave não deve ser salva dentro do projeto nem enviada para repositórios.

## Instalar o APK

### Pelo cabo USB

Com a depuração USB autorizada:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r "build\vertical-0.1.0-debug.apk"
```

### Pela pasta Downloads

1. Copie `build/vertical-0.1.0-debug.apk` para a pasta **Downloads** do celular.
2. Abra o aplicativo **Meus Arquivos** ou **Arquivos**.
3. Toque no APK e permita a instalação por essa fonte, se o Android solicitar.
4. Em atualizações futuras, toque em **Atualizar**. Não desinstale se quiser preservar o save desse pacote.

## Checklist no aparelho

1. Confirme que o ícone mostra a bolinha, três plataformas e uma seta para cima.
2. Abra **VERTICAL** e confirme que ele permanece em retrato e ocupa a tela corretamente.
3. Jogue uma fase usando somente os lados esquerdo e direito da tela.
4. Teste áudio e vibração em **Configurações**.
5. Teste os temas Original, Minimalista escuro e Minimalista claro.
6. Pause, envie o jogo para segundo plano e retorne; ele deve continuar pausado.
7. Conclua uma fase, feche o aplicativo e abra novamente; o progresso deve permanecer.
8. Teste especialmente as fases 7, 22, 33, 34 e 35, que receberam correções recentes.
9. Observe travamentos, aquecimento anormal, cortes nas bordas ou quedas perceptíveis de desempenho.

## Configuração Android aplicada

- Orientação vertical fixa.
- Renderizador Compatibility/OpenGL para maior compatibilidade.
- Arquitetura `arm64-v8a`.
- `minSdk 24` e `targetSdk 36`, definidos pelo modelo atual do Godot.
- Modo imersivo habilitado.
- Ícone comum, adaptativo e monocromático.
- Somente a permissão `android.permission.VIBRATE`.
- Backup automático de dados desabilitado.
- Testes e arquivos de build excluídos do pacote do jogo.

## Exportar novamente pelo Godot

Abra **Projeto > Exportar**:

- Escolha **Android** para gerar um APK instalável.
- Escolha **Android AAB** para gerar um bundle por Gradle.

Para cada versão futura, aumente `versionCode` e atualize `versionName`. O APK é usado nos testes locais; a Google Play recebe o AAB de release devidamente assinado.

## Arquivos principais

- `project.godot`: nome, versão, ícone, retrato e renderizador.
- `export_presets.cfg`: presets APK e AAB, pacote, versão, arquitetura, ícones e permissões.
- `assets/sprites/app_icon*.svg` e `app_icon*.png`: identidade visual Android.
- `android/build`: modelo Gradle oficial correspondente ao Godot 4.7.2.
- `tests/generate_android_icons.gd`: regeneração dos PNGs a partir dos SVGs.
- `tests/phase19_android.gd`: verificação automática da configuração Android.

## Validação automática

```powershell
& 'C:\Ferramentas\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/phase19_android.gd
```
