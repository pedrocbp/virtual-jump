# Guia de instalação e teste — Fase de Implementação 0

Este guia explica como instalar o Godot, abrir o projeto e verificar a Fase de Implementação 0.

Nesta fase existe apenas a estrutura inicial do projeto e uma cena visual mínima. Ainda não existem bolinha, física, plataformas, câmera, obstáculos, fases jogáveis ou controles de gameplay.

## 1. Requisitos

- Windows 10 ou 11.
- Godot 4.x na edição padrão, com suporte a GDScript.
- Aproximadamente 200 MB livres para o editor e os arquivos do projeto.

Não é necessário instalar Android Studio, configurar exportação Android ou instalar dependências externas nesta fase.

## 2. Instalar o Godot

1. Acesse a página oficial: [Download do Godot para Windows](https://godotengine.org/download/windows/).
2. Baixe a versão estável mais recente do Godot 4.x.
3. Para este projeto, escolha a versão padrão para Windows x86_64. Não é necessário baixar a versão `.NET`, pois o projeto usa GDScript.
4. Extraia o arquivo ZIP para uma pasta de sua preferência, por exemplo:

   ```text
   C:\Ferramentas\Godot
   ```

5. Execute o arquivo `Godot.exe`.

O Godot para Windows é portátil: normalmente não há instalador tradicional. Se o sistema perguntar sobre export templates, eles não são necessários para executar o projeto no computador, mas podem ser instalados depois.

## 3. Importar o projeto

No Project Manager do Godot:

1. Clique em **Import**.
2. Selecione o arquivo:

   ```text
   C:\Users\Pedro Miguel\Desktop\jogo\project.godot
   ```

3. Confirme o caminho do projeto.
4. Clique em **Import & Edit**.

O projeto deve abrir no editor sem solicitar a criação de uma nova cena.

## 4. Executar a Fase 0

Com o projeto aberto:

1. Pressione **F6** para executar a cena atual, ou **F5** para executar o projeto.
2. Se o Godot perguntar qual cena principal deve ser usada, escolha `Main.tscn` e confirme.
3. A janela do jogo deverá abrir em formato vertical, com aproximadamente 360×640 pixels.

Também é possível executar diretamente pelo terminal, caso o Godot esteja no PATH do Windows:

```powershell
cd "C:\Users\Pedro Miguel\Desktop\jogo"
godot --path . --editor
```

Para executar o projeto sem abrir o editor:

```powershell
cd "C:\Users\Pedro Miguel\Desktop\jogo"
godot --path .
```

## 5. Resultado esperado

A janela do jogo deve mostrar:

- uma tela vertical com fundo escuro;
- o texto `Jogo de Plataforma`;
- o texto `Fase 0 - projeto inicial`;
- nenhuma mensagem de erro no painel **Debugger** ou **Output**.

O fechamento da janela deve retornar normalmente ao editor.

## 6. Checklist de validação

- [ ] O Godot 4.x abre normalmente.
- [ ] O projeto é importado pelo arquivo `project.godot`.
- [ ] A cena principal é reconhecida automaticamente.
- [ ] O projeto executa com F5.
- [ ] A janela aparece em orientação vertical.
- [ ] O fundo e os dois textos são exibidos.
- [ ] Não há jogador, plataformas ou física — isso é esperado nesta fase.
- [ ] Não há erros no painel **Output**.

## 7. Estrutura criada

```text
jogo/
├── project.godot
├── plano.md
├── GUIA_TESTE_FASE_0.md
├── scenes/
│   ├── main/Main.tscn
│   ├── levels/
│   ├── player/
│   ├── platforms/
│   ├── obstacles/
│   └── ui/
├── scripts/
│   ├── player/
│   ├── levels/
│   ├── systems/
│   └── ui/
├── resources/
└── assets/
    ├── sprites/
    ├── audio/
    └── fonts/
```

## 8. Problemas comuns

### O projeto não aparece no Project Manager

Use **Import** e selecione diretamente o arquivo `project.godot`. Não selecione apenas a pasta pai `Desktop`.

### O Godot mostra uma tela vazia

Confirme que está executando o projeto com **F5** e que `scenes/main/Main.tscn` está definido como cena principal em **Project > Project Settings > Application > Run > Main Scene**.

### O comando `godot` não é reconhecido no PowerShell

Abra o projeto pelo `Godot.exe` ou execute o binário usando o caminho completo, por exemplo:

```powershell
& "C:\Ferramentas\Godot\Godot.exe" --path "C:\Users\Pedro Miguel\Desktop\jogo"
```

### O editor informa que a versão do projeto é incompatível

Use Godot 4.x. Não abra este projeto com Godot 3.x.

## 9. Depois do teste

Quando confirmar que a Fase 0 está funcionando, informe:

```text
Fase 0 funcionando. Vamos para a próxima fase.
```

O desenvolvimento deve parar aqui até essa confirmação. A Fase 1 só deve ser implementada após autorização explícita.

## Referências oficiais

- [Download oficial do Godot para Windows](https://godotengine.org/download/windows/)
- [Project Manager do Godot](https://docs.godotengine.org/en/stable/tutorials/editor/project_manager.html)
- [Execução pela linha de comando](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
