# Plano de melhorias — VERTICAL

Este documento organiza os próximos passos do jogo por prioridade. A regra principal é estabilizar e balancear o que já existe antes de adicionar sistemas grandes.

## 1. Garantir que o modo infinito nunca gere sequências impossíveis

**Prioridade: crítica — primeira implementação concluída; aguardando playtest no celular**

Objetivo: toda sequência criada pelo gerador deve possuir uma rota justa e alcançável.

- Validar a distância vertical usando a força do salto e a gravidade reais da bolinha.
- Validar a distância horizontal usando aceleração, velocidade máxima e tempo disponível no ar.
- Considerar todo o percurso das plataformas móveis, não apenas sua posição inicial.
- Impedir plataformas consecutivas na mesma coluna ou com sobreposição que bloqueie a subida.
- Reservar uma área segura de aterrissagem quando houver espinhos.
- Colocar lasers e barras no lado oposto da aproximação do jogador.
- Remover o perigo daquela plataforma quando não existir uma posição comprovadamente segura.
- Garantir uma aterrissagem acessível depois de cada plataforma com mola.
- Usar uma posição segura de reserva quando a posição preferida não passar na validação.
- Testar automaticamente uma sequência longa, além dos primeiros blocos visíveis.
- Futuro: salvar e exibir uma semente para reproduzir exatamente uma sequência com problema.

Implementado nesta etapa:

- Validador baseado na física real do personagem.
- Seleção automática de uma posição alcançável.
- Margem adicional para todo o percurso das plataformas móveis.
- Validação de espinhos, lasers e barras antes da criação.
- Remoção automática do perigo quando nenhuma posição segura estiver disponível.
- Plataforma normal de reserva quando uma especial não couber com segurança.
- Teste longo com centenas de plataformas geradas.

## 2. Playtest e balanceamento das 70 fases

**Prioridade: alta**

- Concluir cada fase várias vezes em celular.
- Revisar saltos, colunas bloqueadas e áreas de aterrissagem.
- Remover mortes sem informação visual suficiente.
- Organizar uma curva gradual de dificuldade.
- Evitar fases repetitivas.
- Revisar os tempos de bronze, prata e ouro.
- Registrar fase, obstáculo e motivo sempre que um teste falhar.

## 3. Compatibilidade com celulares diferentes

**Prioridade: alta**

- Testar novamente o Moto G35 com o som ativado.
- Testar Android 13, 14 e 15.
- Testar aparelhos Samsung, Motorola e modelos menos potentes.
- Validar telas 16:9, 18:9, 20:9 e telas com recorte.
- Testar minimizar, bloquear a tela, receber uma ligação e retornar ao jogo.
- Confirmar áudio, vibração, pausa, recordes e salvamento após essas interrupções.
- Coletar relatório de erro sempre que o aplicativo fechar sozinho.

## 4. Melhorar o feedback da plataforma quebrável

**Prioridade: média**

- Manter a quebra somente na quarta quicada.
- Intensificar rachaduras, tremor e cor a cada impacto.
- Usar sons diferentes conforme o desgaste.
- Adicionar partículas e pequenos fragmentos na quebra.
- Garantir que a colisão desapareça no instante correto.

## 5. Progressão do modo infinito

**Prioridade: média — implementada; aguardando balanceamento no celular**

- 0–15 blocos: plataformas normais e móveis simples.
- 16–30 blocos: frágeis, temporárias e espinhos.
- 31–50 blocos: lasers e correntes de ar.
- Acima de 50: combinações mais exigentes, sempre validadas.
- Criar marcos visuais em 25, 50, 75 e 100 blocos.
- Aumentar dificuldade gradualmente, sem saltos bruscos.

Implementado nesta etapa:

- Quatro faixas de dificuldade baseadas na altura exibida.
- Primeiros 15 blocos reservados para plataformas normais e móveis simples.
- Plataformas frágeis, temporárias, molas e espinhos introduzidos entre 16 e 30.
- Lasers e correntes de ar introduzidos a partir do bloco 31.
- Barras móveis e frequência maior de desafios acima do bloco 50.
- Força do vento incluída no cálculo de alcançabilidade.
- Marcos visuais em 25, 50, 75 e 100 blocos.
- Substituição automática de perigos laterais por espinhos quando necessário.

## 6. Ghost e comparação com recorde

**Prioridade: média, depois da estabilidade**

- Salvar a trajetória da melhor tentativa de cada fase.
- Exibir uma bolinha transparente representando o recorde.
- Mostrar diferença de tempo em pontos importantes da fase.
- Destacar quando o jogador está adiantado ou atrasado.
- Reforçar visualmente novos recordes e primeiras medalhas de ouro.

## 7. Preparação para publicação

**Prioridade: final**

**Status: preparação técnica e materiais concluídos; faltam e-mail público, chave definitiva e teste fechado**

- [x] Definir nome, ícone e identidade visual finais.
- [x] Criar tela de abertura própria.
- [x] Configurar numeração de versões.
- Criar e guardar com segurança a chave definitiva de assinatura.
- [x] Validar a exportação Android App Bundle (`.aab`) com uma build de teste.
- [x] Preparar screenshots, descrição e materiais da loja.
- [x] Criar política de privacidade no jogo e em formatos Markdown/HTML.
- Fazer teste fechado na Google Play antes do lançamento público.

Instruções completas: `PUBLICACAO_GOOGLE_PLAY.md`.

## Ordem recomendada

1. Validador do modo infinito.
2. Playtest completo das fases.
3. Compatibilidade Android e correções de estabilidade.
4. Feedback visual e sonoro adicional.
5. Progressão do infinito.
6. Ghost e comparação de recordes.
7. Publicação.

## Funcionalidade adicional — skins da bolinha

**Status: implementada; aguardando avaliação visual no celular**

- Tela própria de seleção acessível pelo menu principal.
- Escolha salva entre sessões.
- Alteração apenas visual, sem mudar colisão ou física.
- Skin Clássica disponível desde o início.
- Skin Brasa liberada com 5 fases concluídas.
- Skin Oceano liberada com 15 fases concluídas.
- Skin Campeã liberada com 5 medalhas de ouro.
- Skin Vazio liberada ao alcançar 50 blocos no infinito.
- Skin Lenda liberada ao concluir as 70 fases.
