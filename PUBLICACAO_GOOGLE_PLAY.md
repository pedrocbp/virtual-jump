# Publicação do VERTICAL na Google Play

Estado preparado em 23/09/2026 para a versão `1.0.0` (`versionCode 1`).

## O que já está pronto

- Nome: **VERTICAL**.
- Pacote definitivo proposto: `com.verticaljump.arcade`.
- Versão: `1.0.0`; código: `1`.
- Android 7.0 ou superior (`minSdk 24`).
- Android 16 / API 36 como alvo, exigência vigente para novos envios.
- Preset **Android** para APK de teste.
- Preset **Android AAB (Play Store)** para o bundle de publicação.
- ARM64 e ARMv7 no AAB.
- Ícones normal, adaptativo e monocromático.
- Abertura Android nas cores e com o ícone do jogo.
- Builds de teste liberam as fases; o AAB release usa a progressão normal automaticamente.
- Sem internet, anúncios, login, compras ou coleta de dados.
- Política de privacidade visível em **Configurações > Privacidade e dados**.
- Materiais da ficha em `store/`.

> O identificador do pacote não pode ser alterado depois da primeira publicação. Confirme `com.verticaljump.arcade` antes de enviar o primeiro AAB.

## 1. Antes de gerar a chave

E-mail público de suporte definido: `pedrobonini.dev@gmail.com`.

- já inserido em `store/privacy_policy_pt_BR.md`;
- já inserido em `store/privacy_policy.html`;
- usar o mesmo endereço na ficha da loja.

Publique o HTML em uma URL pública HTTPS, sem login e não editável por visitantes. A Google Play não aceita um arquivo local como URL da política.

## 2. Criar a chave definitiva

Faça isso uma única vez. No PowerShell, usando o `keytool.exe` do JDK 17:

```powershell
& "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\keytool.exe" -v -genkeypair -keystore "C:\CAMINHO_SEGURO\vertical-release.keystore" -alias vertical -keyalg RSA -keysize 2048 -validity 10000
```

Use a mesma senha para o arquivo e para a chave. Prefira letras e números. Não coloque a chave dentro do projeto, não envie por mensagem e não a perca. Guarde duas cópias criptografadas em locais diferentes e registre a senha em um gerenciador de senhas.

## 3. Configurar assinatura sem salvar senha no projeto

No Godot, abra **Editor > Configurações do Editor > Exportar > Android** e confirme JDK 17 e Android SDK. Depois abra **Projeto > Exportar > Android AAB (Play Store)** e informe:

- Chave de lançamento: caminho do `vertical-release.keystore`;
- Usuário/alias: `vertical`;
- Senha: a senha escolhida.

Alternativa mais segura para automação: definir temporariamente as variáveis abaixo no PowerShell antes de abrir o Godot:

```powershell
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH="C:\CAMINHO_SEGURO\vertical-release.keystore"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER="vertical"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="SUA_SENHA"
```

Não escreva a senha em um arquivo do projeto.

## 4. Exportar o AAB final

1. Abra **Projeto > Exportar**.
2. Selecione **Android AAB (Play Store)**.
3. Clique em **Exportar Projeto**.
4. Desmarque **Exportar com depuração**.
5. Salve como `build/vertical-1.0.0-play-store.aab`.

O APK continua sendo usado para instalação manual. O `.aab` é enviado à Play Console e não é instalado diretamente no celular.

Em toda atualização futura, aumente obrigatoriamente o código da versão:

| Lançamento | versionName | versionCode |
| --- | --- | ---: |
| Primeiro | 1.0.0 | 1 |
| Correção | 1.0.1 | 2 |
| Recurso novo | 1.1.0 | 3 |

## 5. Criar o aplicativo na Play Console

1. Crie um **Jogo**, gratuito, idioma padrão **Português (Brasil)**.
2. Marque que o jogo não contém anúncios.
3. Preencha a ficha com `store/listing_pt_BR.md`.
4. Envie `store/app_icon_512.png`, `store/feature_graphic_1024x500.png` e as capturas de tela.
5. Informe a URL pública da política de privacidade.
6. Preencha Segurança dos dados conforme `store/data_safety_pt_BR.md`.
7. Responda o questionário de classificação indicativa com base no conteúdo real.
8. Declare o público-alvo real. O plano atual recomenda **13 anos ou mais**; não selecione crianças sem uma revisão específica das políticas para famílias.
9. Envie o AAB primeiro para **Teste interno** e instale pelo link da Play Store.

## 6. Teste fechado

Se a conta pessoal foi criada depois de 13/11/2023, mantenha pelo menos **12 participantes inscritos continuamente durante 14 dias** no teste fechado. Quem sair e entrar novamente reinicia a contagem própria.

Durante o teste, valide em pelo menos um Samsung e um Motorola:

- abertura repetida com som ligado;
- tutorial na primeira execução;
- controles por toque nos dois lados;
- pausa, reinício e retorno ao menu;
- áudio após bloquear/desbloquear o aparelho;
- 70 fases e modo infinito;
- salvamento de recordes e progresso;
- três temas e skins;
- telas 16:9, 19.5:9 e 20:9;
- instalação, atualização e desinstalação pela Play Store.

Registre feedback, aparelhos, versões do Android e correções. Após os 14 dias, solicite acesso à produção na Play Console.

## Checklist final

- [ ] Pacote definitivo confirmado.
- [ ] E-mail público inserido na ficha da Play Console (já inserido nos arquivos da política).
- [ ] Política publicada em URL HTTPS.
- [ ] Chave definitiva criada, testada e guardada em dois locais seguros.
- [ ] AAB **release**, sem depuração, gerado.
- [ ] AAB aceito sem erros pela Play Console.
- [ ] Ícone, feature graphic e screenshots enviados.
- [ ] Segurança dos dados preenchida e coerente com a política.
- [ ] Classificação indicativa e público-alvo concluídos.
- [ ] Teste interno concluído.
- [ ] Teste fechado concluído, quando aplicável.
- [ ] Crash/ANR e relatório de pré-lançamento revisados.
- [ ] Versão de produção revisada e publicada.
