# VERTICAL — Plano de refatoração visual

Data: 23/09/2026. Estado: planejamento; implementação ainda não iniciada.

## 1. Objetivo e resultado esperado

Refinar o visual do VERTICAL para que plataformas, perigos, vento, portais, personagem e interface pareçam partes de um mesmo jogo acabado. Manter o caráter geométrico, a leitura rápida no celular e a identidade já reconhecível.

A direção proposta é **geometria limpa com acabamento suave**: superfícies sólidas, luz discreta, contornos controlados e animações curtas que explicam o funcionamento dos objetos. A personalidade vem das proporções e dos movimentos, sem exigir texturas realistas ou muitos efeitos.

O resultado deve permitir reconhecer rapidamente onde pousar, o que mata, o que está prestes a mudar e qual objeto dá impulso. A melhoria precisa ser perceptível no tamanho real da tela, inclusive nos dois temas minimalistas.

### Escopo

- Nove cenas de plataforma existentes, incluindo a pequena, as quebráveis e a mola.
- Onze cenas de obstáculos e áreas existentes, incluindo serras, ventos e portais.
- Chegada, personagem, skins, partículas e fundo.
- Ajustes de coerência visual no HUD, tutorial e menus.
- Os três temas, modo de fases e modo infinito.
- Capturas e materiais da loja após a implementação.

Não faz parte desta refatoração criar novas mecânicas, novos níveis, anúncios ou sistemas de progressão. Problemas de jogabilidade encontrados durante os testes devem ser registrados e corrigidos em alterações específicas, com validação própria.

## 2. Diagnóstico do projeto atual

O plano foi elaborado a partir dos scripts e cenas locais e da inspeção das capturas `store/screenshots/04-fase-portal.png` e `05-modo-infinito.png`. As capturas existentes servem como referência, mas não comprovam o estado visual mais recente de todas as cenas.

| Área | Evidência atual | Direção de melhoria |
| --- | --- | --- |
| Plataformas básicas | `object_skin.gd` aplica contorno, linha superior e sombra escura deslocada | Reduzir a sombra e dar mais presença à superfície de pouso |
| Estilos distribuídos | Alguns objetos usam `WorldSkin`; outros desenham diretamente em `_draw()` | Compartilhar medidas, paleta e funções de desenho |
| Cores | Vários scripts definem suas próprias cores hexadecimais | Centralizar cores por função e por tema |
| Vento | Retângulo translúcido, moldura completa e muitas setas | Criar fluxo visual mais leve, mantendo a área de atuação legível |
| Serra móvel/orbital | Desenhos separados com tamanhos e acabamentos distintos | Criar uma família de lâminas proporcional à colisão real |
| Portal | Anéis e pontos giratórios; entrada intermitente no infinito | Tornar entrada, saída, abertura e indisponibilidade visualmente distintas |
| Temas minimalistas | `visual_theme.gd` converte a tela inteira por limiar de luminância | Migrar gradualmente para cores e símbolos próprios por tema |
| Desempenho | Alguns desenhos recriam `StyleBoxFlat`; objetos animados redesenham continuamente | Cachear estilos e reduzir trabalho de decoração fora da tela |
| Fundo e HUD | Partículas decorativas e painel superior grande nas capturas | Diminuir competição com a área de salto |

O filtro atual pode transformar tons diferentes na mesma cor, remover linhas discretas e alterar avisos. Esse é um risco técnico observado no método de renderização; cada ocorrência deverá ser confirmada visualmente durante a migração.

## 3. Regras que a implementação deve preservar

1. Manter posições, dimensões físicas, máscaras de colisão, velocidades, órbitas e trajetórias existentes.
2. Manter o salto normal e o impulso especial da mola. O visual nunca deve limitar a velocidade do personagem.
3. Preservar a quebra por quicadas: a plataforma do infinito cai na quarta quicada por padrão; respeitar configurações existentes de quatro ou cinco quando aplicáveis.
4. Distinguir plataforma que cai após pouso, plataforma que quebra após contato e plataforma que se desgasta em várias quicadas. São comportamentos diferentes.
5. Preservar os ciclos dos lasers, espinhos retráteis, plataformas temporárias e perigos temporários.
6. Preservar a entrada do portal do infinito: 2,6 s disponível, 1,8 s indisponível, aviso nos últimos 0,45 s. A saída fica estável e os portais das fases permanecem permanentes.
7. Não reintroduzir correntes ascendentes no infinito. As correntes verticais já existentes nas fases podem receber o novo desenho.
8. Aplicar a mesma linguagem visual ao tutorial, às fases e ao infinito.
9. Preservar progresso, desbloqueios, skins, recordes e preferências salvas.
10. Manter controle por toque e ícones discretos de pausa/reinício, com áreas de toque confortáveis.

Animações de compressão, vibração e expansão devem ocorrer em um filho visual. Escalar ou deslocar o corpo físico para produzir um efeito pode modificar a colisão e invalidar os saltos.

## 4. Direção de arte

### 4.1 Formas e acabamento

- Plataformas: placas compactas com topo claramente definido e cantos moderadamente arredondados.
- Perigos: pontas, serrilhas e chanfros que indiquem dano mesmo sem cor.
- Áreas de influência: fluxo e limites leves, sem parecer paredes ou plataformas sólidas.
- Portais: anéis abertos e movimento radial; nunca usar dentes que os confundam com serras.
- Chegada: marca vertical ou pequeno arco, visualmente distinto de um portal.
- Personagem: esfera expressiva, com olhos legíveis e destaque suficiente sobre todos os fundos.

Preferir no máximo três níveis de acabamento por objeto: corpo, borda funcional e detalhe identificador. Remover pequenos detalhes que não sejam visíveis durante a partida.

### 4.2 Paleta do tema original

Manter a família atual e organizar seu uso por função. Valores abaixo são a base proposta, sujeitos à comparação visual:

| Função | Cor base | Uso |
| --- | --- | --- |
| Fundo | `#0B1423` | Área de jogo |
| Superfície | `#17273B` | Painéis e faces escuras |
| Borda neutra | `#30465D` | Divisões secundárias |
| Texto principal | `#EDF5FA` | Informação prioritária |
| Texto secundário | `#A0B5C9` | Legendas |
| Apoio estável | `#80EFC0` | Plataforma normal e personagem clássico |
| Movimento/fluxo | `#69C9FF` | Plataforma móvel, impulso lateral e vento horizontal |
| Fragilidade | `#FFAD83` | Plataforma que cai ou se desgasta |
| Mola | `#FFD18A` | Impulso vertical e mecanismo de mola |
| Perigo | `#FF7D87` | Espinhos, blocos letais, serras e laser ativo |
| Ciclo/teleporte | `#B59AFF` | Plataforma temporária e portal de entrada |

Cor nunca será a única diferença entre duas funções. Mola e chegada podem compartilhar dourado porque suas silhuetas são distintas; portal e plataforma temporária devem manter símbolos e formas próprios.

### 4.3 Medidas de referência

Todas as medidas abaixo são unidades lógicas da base 360 × 640, não pixels físicos de um aparelho específico.

| Elemento | Referência inicial |
| --- | --- |
| Plataforma comum | Respeitar a colisão atual de 100 × 20 |
| Raio visual dos cantos da plataforma | 4–5 |
| Contorno principal | 1,5–2 |
| Destaque do topo | Até 2, dentro da superfície |
| Sombra do tema original | Deslocamento de 1–2, opacidade baixa |
| Ícone de mecânica dentro da plataforma | 10–14 de altura |
| Ícones pausa/reinício | Caixa visual de 20–22; ajustar peso óptico |
| Alvo de toque desses ícones | Pelo menos 44 × 44 lógicos, a conferir no aparelho |

Medidas são ponto de partida. Não alterar a colisão para acomodar ornamentos. Nenhuma parte com aparência sólida deve sugerir um apoio que não existe.

### 4.4 Prioridade visual durante a partida

1. Personagem, superfície de pouso e perigo ativo.
2. Aviso de ativação, direção de impulso e entrada de portal disponível.
3. Placar e ações de pausa/reinício.
4. Decoração de fundo e trajetórias auxiliares.

## 5. Plano por plataforma

### 5.1 Plataforma normal e plataforma pequena

**Proposta:** placa de superfície sólida, face frontal discreta e topo iluminado. Remover a sensação de caixa oca com sombra preta pesada.

- Manter o topo no limite superior da colisão.
- Usar sombra curta apenas no tema original.
- A pequena deve ser uma variante da mesma família; reduzir decoração para preservar a largura útil aparente.
- No pouso, um brilho local curto ou pequena onda sobre o topo; sem afundar o apoio físico.
- Aceite: largura e altura percebidas correspondem à área sólida, inclusive nas pontas.

### 5.2 Plataforma móvel

**Proposta:** placa da mesma família, com pequenos encaixes laterais e símbolo de deslocamento.

- Usar azul claro no tema original.
- Orientar o símbolo pelo eixo real de movimento, inclusive movimento vertical.
- Indicar direção atual com um detalhe deslizante suave, sem sugerir que ela impulsiona o jogador.
- Experimentar marcas discretas nos extremos do percurso; exibir só quando ajudarem a leitura.
- Manter a animação visual acompanhando a posição real, sem atrasos ou balanço artificial.
- Aceite: distinguir em preto e branco a plataforma móvel da plataforma de impulso horizontal e da barra móvel que mata.

### 5.3 Plataforma quebrável por contato — `BreakablePlatform`

**Proposta:** placa dividida em duas peças com uma junta central visível.

- Estado estável: junta discreta.
- Após contato: separação visual progressiva, sincronizada ao `break_delay` atual.
- Quebrada: nenhum desenho com aparência sólida onde a colisão foi desativada.
- Retorno: composição das peças sem indicar apoio antes de a colisão voltar.
- Aceite: efeitos seguem `_state` e `_state_time`, sem reiniciar ou alongar o temporizador.

### 5.4 Plataforma que se desgasta por quicadas — `CrumblingPlatform`

**Proposta:** placa de cerâmica técnica, com rachaduras organizadas e pequenos segmentos de resistência.

- Sem desgaste: face íntegra, com juntas características.
- Primeira quicada: primeira rachadura localizada.
- Segunda: rachadura mais longa e uma conexão perdida.
- Terceira: fragmentos visualmente separados e aviso claro da próxima quebra.
- Quarta: ruptura e queda, conforme a configuração atual.
- Se configurada para cinco, distribuir os estados pelo número real de quicadas restantes.
- Representar a recuperação existente sem prometer resistência antes da restauração lógica.
- Aceite: o jogador percebe que ela aguenta várias quicadas; rachaduras e segmentos continuam visíveis nos temas minimalistas.

### 5.5 Plataforma que cai — `FallingPlatform`

**Proposta:** placa suspensa por duas travas curtas e símbolo de queda na face.

- Pouso: as travas mostram soltura e a placa treme visualmente.
- A queda começa no instante definido pelo atraso atual, normalmente 0,4 s.
- A animação não deve parecer um desaparecimento cíclico nem desgaste por várias quicadas.
- Restaurar desenho, posição visual, opacidade e travas ao reiniciar.
- Aceite: primeira tentativa e tentativas seguintes têm aparência e comportamento equivalentes.

### 5.6 Plataforma temporária

**Proposta:** placa segmentada que comunica uma janela de existência.

- Sólida: topo contínuo e segmentos acesos.
- Fim da janela: segmentos se apagam em sequência, acompanhando o temporizador real.
- Ausente: apenas um vestígio tracejado, se ele melhorar a leitura; jamais uma face sólida translúcida.
- Reaparecimento: indicação curta dentro do intervalo inativo já existente.
- Aceite: sólido e atravessável são reconhecíveis por forma, mesmo sem animação ou cor.

### 5.7 Plataforma de mola / boost

**Proposta:** pequeno mecanismo de mola visível no interior da plataforma, com uma marca ascendente central.

- Combinar face neutra, detalhe dourado e mola em zigue-zague.
- Comprimir e estender o mecanismo visual por cerca de 0,15–0,22 s após o pouso.
- Produzir um rastro curto ascendente, diferente das partículas comuns de pouso.
- Manter o topo de contato no lugar e indicar salto forte sem desenhar uma plataforma adicional acima.
- Aceite: a mola é identificável antes do pouso e o teste de impulso continua atravessando o vão real de 300 unidades.

### 5.8 Plataforma de impulso horizontal

**Proposta:** placa com duas setas grandes e faixa interna semelhante a uma esteira.

- Setas apontam para a direção configurada, sem alternar.
- A faixa interna move-se discretamente para a direção do impulso.
- Pulso curto lateral após o pouso.
- Aceite: sua leitura não se confunde com a plataforma que percorre um trajeto.

## 6. Plano por obstáculo e área

### 6.1 Espinho fixo

**Proposta:** lâminas simples e bem proporcionadas, com uma base compacta. Reduzir linhas microscópicas, rebites e excesso de facetas.

- Uma lâmina central dominante e duas laterais menores, se couberem no perigo real.
- Coral no tema original, com uma única face de sombra.
- O desenho deve comunicar toda a região perigosa; verificar especialmente espaços entre lâminas quando a colisão for retangular.
- Se houver divergência entre silhueta e colisão, ajustar a arte para explicar a área perigosa. Alterar a hitbox exige uma tarefa de jogabilidade separada.
- Aceite: leitura de perigo imediata, sem uma base com aparência segura dentro da área letal.

### 6.2 Bloco de dano

**Proposta:** núcleo quadrado chanfrado com face sólida e marca central angular.

- Manter a silhueta de bloco e reduzir o aspecto de vários pequenos detalhes desconectados.
- Dar às bordas externas a mesma leitura de dano do centro.
- Usar um pulso lento e discreto no núcleo, sem sugerir uma janela em que é seguro tocar.
- Evitar anéis e abertura central semelhante a portal.
- Aceite: entende-se que toda a carcaça mata, em qualquer tema.

### 6.3 Barra móvel perigosa

**Proposta:** peça alongada chanfrada com faixas diagonais e terminais agressivos.

- Perfil visual distinto da plataforma móvel, mesmo que ambos se desloquem horizontalmente.
- Não desenhar um topo verde/azul de apoio.
- Pequenas marcações de percurso somente se não poluírem os saltos próximos.
- Aceite: imagem estática em preto e branco permite distinguir apoio móvel de perigo móvel.

### 6.4 Perigo temporário

**Proposta:** mesma família do bloco de dano, com segmentos periféricos que indicam a ativação.

- Inativo: marcador de posição vazado, discreto e reconhecível como aviso.
- Aproximação da ativação: segmentos fecham progressivamente.
- Ativo: corpo preenchido e contorno de perigo integral.
- Derivar tudo do ciclo atual; não adicionar tempo extra em que a arte e o dano discordem.

### 6.5 Serra móvel e serra orbital

**Proposta:** lâmina de desenho compartilhado, com dentes regulares, corpo simples e miolo de eixo.

- Usar entre 10 e 12 dentes como estudo inicial; privilegiar silhueta legível.
- Dimensionar a lâmina a partir da colisão de cada cena; não assumir que os dois modelos têm o mesmo raio.
- Evitar que os dentes pareçam ameaçar regiões muito além da área de dano ou que o dano alcance uma região visualmente vazia.
- Separar visualmente rotação da lâmina e deslocamento do conjunto.
- Na orbital, indicar pivô e um pequeno trecho da órbita quando isso ajudar a prever o caminho; evitar círculos brilhantes completos competindo com portais.
- Aceite: eixo, dentes e direção de movimento são legíveis nos três temas e perto de plataformas.

### 6.6 Espinhos retráteis

**Proposta:** base com encaixes; as lâminas usam a mesma família dos espinhos fixos.

- Recolhido: encaixes vazios e perfil baixo.
- Aviso: pequenas pontas surgem e um marcador progride até a ativação.
- Ativo: lâminas completas, forma e contraste fortes.
- A aparência letal plena coincide com o estado que causa dano.
- Aceite: é possível antecipar a ativação sem precisar de uma piscada rápida de cor.

### 6.7 Laser intermitente

**Proposta:** dois emissores compactos com uma linha de energia bem definida.

- Desligado: emissores visíveis e guia descontínua fraca.
- Aviso: guia descontínua mais clara e carga progressiva dos emissores.
- Ligado: faixa letal sólida com núcleo fino claro; halo apenas no tema original.
- Manter a faixa sólida coerente com a espessura real de dano de 8 unidades, quando essa configuração estiver em uso.
- Halo externo não deve esconder a plataforma nem sugerir um feixe letal mais largo.
- Aceite: os três estados são distintos em uma captura estática; nenhuma piscada de tela inteira.

### 6.8 Vento horizontal

**Proposta:** linhas curtas de fluxo e um ventilador compacto, com limites suaves mas perceptíveis.

- Reduzir o retângulo preenchido e substituir a moldura pesada por limites discretos e marcas de canto.
- Usar poucas linhas distribuídas, movendo-se na direção real, com pequenas pontas direcionais.
- Tornar o ventilador um disco com três pás simples; ele é um indicador, não um obstáculo sólido.
- Manter os efeitos atrás do personagem e das plataformas.
- Representar intensidade pela velocidade/densidade do fluxo dentro de limites legíveis.
- Restringir as linhas à área real de influência; ornamentos fora dela não devem sugerir força aplicada.
- Aceite: início, fim e direção da corrente são reconhecíveis sem cobrir os pontos de pouso.

### 6.9 Correntes verticais

**Proposta:** reaproveitar a linguagem do vento horizontal com orientação vertical e marca direcional própria.

- Diferenciar visualmente fluxo para cima e para baixo onde essas variantes já existem nas fases.
- Manter descendentes fracas do infinito com fluxo proporcional à intensidade, sem aparência de barreira intransponível.
- Preservar a remoção do fluxo ascendente no infinito.
- Evitar grandes retângulos roxos sobrepondo áreas de salto.
- Aceite: o redesenho não modifica força, área, direção ou combinação de correntes.

### 6.10 Portal de entrada e saída

**Proposta:** anel de geometria limpa com abertura central e dois ou três segmentos orbitais.

- Entrada: marcas orientadas para dentro e cor violeta no tema original.
- Saída: marcas para fora e azul suave, sem parecer uma segunda entrada utilizável.
- A distinção depende do desenho, além da cor.
- Disponível: anel completo e movimento suave.
- Oculto: desaparecimento real; não manter uma silhueta com aparência de portal utilizável durante todo o intervalo.
- Aviso antes de abrir: reconstrução gradual de um arco vazado nos 0,45 s finais já previstos.
- Transição de teleporte: anel de expansão curto na origem e chegada, sem flash na tela inteira.
- Se houver indicador de tempo restante, desenhá-lo apenas durante a janela visível.
- Aceite: entrada oculta não transporta; saída permanece estável; reabertura detecta corretamente o personagem conforme as regras do portal.

## 7. Personagem, chegada e efeitos

### Personagem e skins

- Preservar a esfera e os olhos que acompanham a direção do movimento.
- Usar iluminação coerente com as plataformas: um brilho principal e uma sombra inferior discreta no tema original.
- Manter squash/stretch, mas sem deformações que atrapalhem a percepção da colisão circular.
- Garantir distinção das seis skins por padrões e marcas, além da cor.
- Nos temas preto/branco, usar olhos e marcas em cor oposta ao corpo; evitar que todas as skins virem a mesma bolinha lisa.
- Manter os nomes, IDs, desbloqueios e seleção salva.

### Chegada

- Propor um pequeno arco ou marco vertical com símbolo ascendente e base claramente identificável.
- Usar dourado no original, silhueta de bandeira/arco nos minimalistas.
- Não desenhar um aro circular semelhante a portal.
- Conservar a área de detecção e manter rótulos fora da trajetória da bolinha.
- No tutorial, preservar a chegada e exibir o botão de começar somente após alcançá-la.

### Partículas e movimento

| Evento | Tratamento proposto | Faixa inicial para protótipo |
| --- | --- | --- |
| Pouso | Poucos fragmentos junto ao topo | 4–6 partículas, 0,12–0,22 s |
| Mola | Traços ascendentes e compressão do mecanismo | 0,15–0,22 s |
| Quebra | Pequenos fragmentos que dissipam rapidamente | 6–8 partículas, até 0,35 s |
| Teleporte | Arco curto em origem/destino | 0,15–0,25 s |
| Morte | Fragmentos da cor da skin e efeito já existente refinado | Até 0,28 s |
| Chegada/recorde | Pulso localizado e poucos detalhes | Até 0,45 s |

Esses tempos são propostas visuais, não alterações dos tempos de gameplay. Ajustar o efeito à duração do estado existente. Evitar acúmulo, flashes intensos e partículas sobre os botões.

## 8. Três temas realmente consistentes

### Tema original

Manter azul escuro, menta e cores de função. Permitir sombra curta, brilho local e um gradiente de fundo muito suave.

### Minimalista escuro

- Fundo preto e elementos principais brancos.
- Diferenciar mecânicas por recortes, rachaduras, dentes, segmentos e direção dos símbolos.
- Preservar áreas internas negativas e olhos pretos.
- Reduzir sombras e halos; antialiasing pode gerar tons intermediários nas bordas, sem introduzir cores decorativas.

### Minimalista claro

- Fundo branco e elementos principais pretos.
- Usar as mesmas diferenças de forma do tema escuro.
- Reavaliar peso dos traços: o contorno preto pode parecer mais pesado no fundo branco.
- Evitar grandes manchas pretas que escondam o trajeto ou a leitura de um estado inativo.

### Migração do filtro atual

1. Criar uma paleta por tema com papéis explícitos: fundo, apoio, perigo, aviso, fluxo e texto.
2. Fazer os novos desenhos consumirem esses papéis diretamente.
3. Preparar uma galeria que possa visualizar os novos temas sem o filtro de tela.
4. Migrar também UI, fundo, skins, partículas e chegada antes de desligar o filtro no jogo completo.
5. Comparar os três temas e corrigir perdas de leitura.
6. Remover a dependência do limiar global quando todos os consumidores tiverem representação própria.

Durante a migração, preservar uma forma de comparar o visual anterior. Não aplicar simultaneamente o novo preto/branco e o filtro global, pois isso pode apagar ou inverter detalhes novamente.

## 9. Arquitetura proposta

Priorizar os desenhos vetoriais/procedurais que o projeto já utiliza. Eles combinam com a estética, permitem ajustar proporções e evitam um conjunto grande de texturas. Imagens raster só serão justificadas por uma necessidade visual específica.

### Responsabilidades

| Componente | Responsabilidade proposta |
| --- | --- |
| `scripts/ui/design.gd` | Tipografia, espaçamento e componentes da interface |
| `scripts/systems/visual_theme.gd` | Seleção do tema e notificação de mudança |
| Novo `scripts/visuals/world_style.gd` | Paleta semântica e medidas dos objetos do mundo |
| Novo `scripts/visuals/world_shapes.gd` | Funções compartilhadas para placas, lâminas, anéis e símbolos |
| Filhos `Visual` dos objetos | Desenho e animação local sem transformar a colisão |
| Scripts das plataformas/obstáculos | Estados, física, dano e parâmetros da mecânica |
| `object_skin.gd` | Adaptador temporário dos objetos antigos durante a migração |

Esses novos caminhos são propostas, não arquivos já implementados. Evitar criar um framework genérico maior que o necessário.

### Contrato entre lógica e desenho

- O desenho recebe tipo, dimensões, estado, progresso do estado e direção quando necessário.
- O estado visual deriva do temporizador real; não criar um segundo relógio para prever dano ou colisão.
- Usar dados explícitos ou sinais para mudanças de estado, evitando dependência de `get_parent().get_parent()` e de nomes privados espalhados.
- Animações cosméticas podem ter relógio próprio, desde que não controlem disponibilidade ou dano.
- Compartilhar o renderer da serra, preservando a lógica móvel/orbital separada.
- Cachear estilos e geometrias estáticas. Recriar apenas após mudança de tema, dimensão ou estado relevante.
- `reset_attempt()` deve restaurar também visibilidade, opacidade, transformação, efeitos ativos e fase visual.

### Migração gradual

Migrar uma família por vez. Antes de remover `WorldSkin` de uma cena, verificar quem utiliza `Visual`, `modulate`, `visible` e os antigos ornamentos. Manter temporariamente esses contratos evita regressões em plataformas temporárias e quebráveis.

## 10. Fundo, HUD e telas

Estes ajustes entram depois dos objetos, para sustentar a nova direção visual.

- Fundo original: reduzir partículas e contraste de decoração nas regiões de salto.
- Fundos minimalistas: sólidos, com decoração mínima ou ausente.
- HUD: estudar um painel mais leve e compacto, preservando área segura do Android e legibilidade dos números.
- Pausa/reinício: ícones vetoriais com o mesmo tamanho óptico, sem caixas grandes; área de toque maior que o desenho.
- Evitar depender de glifos de fonte para ícones cujo tamanho varia entre aparelhos.
- Infinito: manter contador de blocos, recorde e ausência de barra de progresso.
- Tutorial: chegada visível, instrução fora das plataformas, setas de exemplo bem posicionadas e botão final na parte inferior.
- Menu: composição decorativa separada do título e botões; progresso sem corte horizontal.
- Skins, configurações, seleção de fases e estatísticas: reutilizar os mesmos contornos, espaços e estados dos botões.
- Não reintroduzir instruções de teclado nas telas voltadas ao jogador.

## 11. Etapas de implementação, por prioridade

As etapas abaixo são exclusivas desta refatoração visual; não substituem a numeração das fases do plano original.

### V0 — Referência e inventário visual

**Prioridade:** essencial. **Esforço relativo:** pequeno.

- [ ] Capturar telas atuais, com resolução nativa, nos três temas.
- [ ] Inventariar dimensões físicas, desenho e estados de cada cena.
- [ ] Criar uma galeria de desenvolvimento com todos os objetos lado a lado.
- [ ] Exibir controles de tema, estado, escala e sobreposição de colisões na galeria.
- [ ] Salvar referências de visual, física, temporizadores e desempenho.

**Entrega:** galeria e imagens de comparação. **Aceite:** todos os objetos existentes podem ser inspecionados sem jogar dezenas de fases.

### V1 — Linguagem visual e amostra representativa

**Prioridade:** essencial. **Dependência:** V0. **Esforço:** médio.

- [ ] Consolidar paleta e medidas compartilhadas.
- [ ] Prototipar plataforma normal, espinho, serra, vento e portal.
- [ ] Preparar as cinco amostras nos três temas.
- [ ] Comparar no tamanho real do celular e com colisões visíveis.
- [ ] Registrar escolhas aprovadas e ajustes necessários.

**Entrega:** primeira amostra coerente do novo visual. **Aceite:** apoio, perigo e interação se distinguem por forma, e a aparência é satisfatória antes da migração completa.

### V2 — Plataformas completas

**Prioridade:** alta. **Dependência:** V1. **Esforço:** médio/grande.

- [ ] Migrar normal, pequena e móvel.
- [ ] Migrar quebrável por contato, queda e desgaste por quicadas.
- [ ] Migrar temporária, mola e impulso horizontal.
- [ ] Implementar estados e efeitos usando a lógica atual.
- [ ] Testar reinícios e contagem de quicadas.

**Entrega:** nove cenas com acabamento consistente. **Aceite:** nenhum pouso, impulso ou apoio muda por causa da arte.

### V3 — Perigos completos

**Prioridade:** alta. **Dependência:** V1; integrar após V2. **Esforço:** médio.

- [ ] Migrar espinho, bloco, barra e perigo temporário.
- [ ] Unificar serra móvel e orbital.
- [ ] Refinar estados do laser e dos espinhos retráteis.
- [ ] Comparar estado desenhado com dano/colisão em cada transição.

**Entrega:** família de perigos legível nos três temas. **Aceite:** não há aviso visual enganoso nem perigo invisível durante um estado ativo.

### V4 — Vento, portais e chegada

**Prioridade:** alta. **Dependência:** V2 e V3. **Esforço:** médio.

- [ ] Redesenhar fluxo horizontal e vertical.
- [ ] Redesenhar entrada, saída e ciclo intermitente dos portais.
- [ ] Refinar chegada do tutorial e das fases.
- [ ] Conferir leitura perto de plataformas e quando os objetos ficam parcialmente fora da tela.

**Entrega:** áreas de influência e transporte integradas ao cenário. **Aceite:** o vento não esconde pousos e o portal comunica disponibilidade sem mudar seus ciclos.

### V5 — Personagem, efeitos e integração da interface

**Prioridade:** média. **Dependência:** V2–V4. **Esforço:** médio.

- [ ] Refinar esfera, olhos e seis skins.
- [ ] Harmonizar partículas e trail.
- [ ] Ajustar fundo, chegada/recorde, HUD e tutorial.
- [ ] Harmonizar menu e telas secundárias.
- [ ] Concluir migração dos temas e retirar o filtro global quando houver cobertura completa.

**Entrega:** todas as telas com a mesma direção visual. **Aceite:** nenhuma tela ou tema mantém um estilo conflitante ou perde legibilidade.

### V6 — Validação no Android e acabamento final

**Prioridade:** obrigatória antes da publicação. **Dependência:** V5. **Esforço:** médio, variável conforme defeitos encontrados.

- [ ] Executar regressões automatizadas relevantes.
- [ ] Revisar visualmente as 70 fases e sequências representativas do infinito.
- [ ] Testar no Samsung e no Moto G35 quando estiverem disponíveis.
- [ ] Medir desempenho em partida longa, com som e efeitos.
- [ ] Corrigir problemas visuais e repetir apenas verificações afetadas.
- [ ] Gerar novas capturas reais, APK de teste e depois AAB atualizado.

**Entrega:** relatório visual, comparações antes/depois e pacote para teste. **Aceite:** critérios da seção seguinte atendidos; pendências físicas de aparelho registradas sem declará-las testadas.

## 12. Validação e critérios de aceite

### Matriz visual

| Dimensão | Cobertura |
| --- | --- |
| Temas | Original, preto com branco, branco com preto |
| Proporções | 360 × 640, 360 × 780, 360 × 800 e uma tela mais larga |
| Cenários | Galeria, tutorial, fases, infinito, pausa, derrota e conclusão |
| Estados | Estável, aviso, ativo, inativo, quebrando, caindo, reaparecendo e reset |
| Sobreposição | Personagem sobre objeto, perigo junto a apoio, vento atrás de plataformas e portal próximo ao HUD |
| Aparelhos | Samsung usado nos testes; Moto G35/Android 15 quando disponível |

Gerar capturas diretamente na resolução de saída planejada. Ampliar uma captura de 360 × 640 para 1080 × 1920 não recupera detalhe e não serve para avaliar a nitidez nativa do novo desenho.

### Casos de regressão prioritários

- Fases 6, 7, 22, 26, 27 e 30: leitura da passagem junto a espinhos e blocos, devido ao histórico de posicionamento.
- Fases 32–35: laser, plataforma que cai e espaços apertados.
- Fases 41–60: serras, movimentos e combinações de mecânicas.
- Fases 61–70: portais, correntes e impulsos.
- Infinito: primeira mola e o pouso seguinte, quarta quicada da plataforma desgastável, portal oculto/aberto e combinação de fluxos.
- Tutorial: distância entre os últimos apoios, chegada descoberta e posição final do botão.
- Reinício repetido: conferir reaparecimento, rachaduras, sombras, animações e fases de ciclo.

### Testes existentes a reutilizar

- `tests/phase20_qa.gd`: cenas, interface, câmera, reinício e resoluções.
- `tests/phase17_smoke.gd` e `phase18_and_levels.gd`: comportamento geral e mecânicas.
- `tests/levels41_50.gd`, `levels51_60.gd` e `levels61_70.gd`: alcance e mecânicas específicas.
- `tests/endless_generation_validation.gd`: estrutura de geração do infinito.
- `tests/spring_boost_integration.gd`: impulso real e transição da mola.
- `tests/intermittent_portal.gd`: ciclo do portal.
- `tests/crumbling_platform_integration.gd`: contagem e quebra por quicadas.

Expandir testes apenas onde a refatoração cria um risco: sincronização visual/colisão, troca de tema em execução ou reset de uma animação. Não criar testes que apenas repitam as constantes de cor.

Os validadores não equivalem a completar todas as fases jogando nem garantem ausência de toda sequência impossível. Relatar separadamente testes estruturais, simulações físicas, inspeção visual e playtest humano.

### Desempenho

- Medir antes/depois nas mesmas cenas, no mesmo aparelho e com as mesmas configurações.
- Buscar 60 FPS onde a versão de referência já os sustenta; 16,7 ms por quadro é a referência de orçamento.
- Investigar regressão persistente superior a 10% no tempo por quadro; não aceitar queda recorrente mascarada pela média.
- Não criar partículas ilimitadas, luzes dinâmicas numerosas ou blur de tela inteira.
- Suspender animação puramente decorativa fora da tela, preservando física e relógios de gameplay.
- Conferir uma sessão de pelo menos 10 minutos no infinito para crescimento de nós, memória e custo de desenho. O gerador mantém histórico e objetos, portanto esse custo precisa ser medido.
- Se houver acúmulo, tratar descarte/reutilização de objetos em alteração própria, respeitando destinos de portal, reinício e referências do histórico.

### Checklist final

- [ ] Apoio sólido coincide visualmente com o apoio físico.
- [ ] Perigo ativo é legível nos três temas.
- [ ] Plataforma móvel e barra perigosa não se confundem.
- [ ] Mola e impulso lateral são distinguíveis.
- [ ] Quebra por contato, por quicadas e queda após pouso são distinguíveis.
- [ ] Portal e serra têm silhuetas distintas.
- [ ] Vento mantém área/direção claras sem esconder plataformas.
- [ ] Avisos coincidem com os estados reais.
- [ ] Troca de tema atualiza objetos já criados e recém-gerados.
- [ ] Tutorial, fases e infinito usam a mesma família de desenhos.
- [ ] Texto, personagem e controles não são cobertos por decoração.
- [ ] Partículas e animações não degradam a fluidez nos aparelhos testados.
- [ ] Reiniciar restaura todos os estados visuais.
- [ ] Saves, recordes e desbloqueios permanecem compatíveis.
- [ ] Capturas da loja correspondem ao visual final.

## 13. Entrega e controle das alterações

Ao concluir cada etapa, registrar arquivos alterados, capturas comparativas, verificações realizadas e pendências. Guardar a referência anterior para facilitar comparação e reversão de uma família visual que não funcione bem.

Manter os APKs de teste com nomes identificáveis por etapa visual e atualizar a documentação quando uma decisão mudar. O AAB já exportado não incorpora edições posteriores: gerar e validar outro release com a chave existente ao concluir o trabalho.

Não enviar materiais de loja antigos junto de uma versão com visual novo. Revisar ícone e abertura somente se o acabamento final do personagem e das plataformas justificar a atualização.

## 14. Primeiro trabalho recomendado

Começar por **V0 e V1**: montar a galeria e produzir plataforma normal, espinho, serra, vento e portal nos três temas. Esses cinco exemplos cobrem apoio, dano, movimento, área de influência e interação. Com essa amostra avaliada no celular, implementar as famílias restantes na ordem definida.

O ganho esperado vem principalmente de proporções consistentes, símbolos claros, menos sombras pesadas e melhor distinção entre estados. Cada detalhe novo precisa contribuir para essa leitura.
