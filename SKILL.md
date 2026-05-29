---
name: nicochat-prompt
description: Gera os campos de "Adicionar agente de IA" e "Adicionar função de IA" do NicoChat (Nome, Personalidade, Habilidades, Restrições + cada função com seus parâmetros) seguindo o ebook interno de engenharia de prompt. Pergunta antes a persona-alvo e o escopo; para CADA dado que o agente precisa coletar do usuário, cria uma função separada com parâmetros. Use quando o usuário pedir "criar agente de IA NicoChat", "gerar prompt de agente", "fazer função do NicoChat", ou colar prints/menções dos formulários "Adicionar agente de IA" / "Adicionar função de IA".
---

# nicochat-prompt — gerador de agentes de IA do NicoChat

Esta skill traduz uma ideia de agente em todos os campos que o NicoChat pede nos formulários **Adicionar agente de IA** e **Adicionar função de IA**, seguindo o ebook interno de engenharia de prompt (delimitadores, separação agente×função, controle de saída, antidelírio).

A regra principal: **o agente deve sempre falar com a persona que o usuário definir**. Por isso a skill primeiro pergunta sobre o escopo e a persona, e só depois elabora os textos — todo o tom, vocabulário, exemplos e restrições são derivados dessas respostas.

## Quando acionar

- Usuário pede para criar/gerar um agente de IA do NicoChat.
- Usuário pede para criar uma função de IA específica.
- Usuário cola os prints dos formulários "Adicionar agente de IA" ou "Adicionar função de IA" pedindo ajuda para preencher.
- Usuário diz "preciso de um prompt para [vendedor/atendente/qualificador/etc] no NicoChat".

---

## 🚨 ENFORCEMENT PROTOCOL — leia antes de gerar qualquer coisa

Estas 4 regras são **bloqueadoras**. Se você violar qualquer uma, sua resposta está errada e o usuário precisa pedir de novo.

### Regra 1 — ORDEM DE GERAÇÃO (essa é a defesa principal contra empurrar regras pra Personalidade)

Você vai **gerar internamente** os campos **NESTA ORDEM**, mesmo que apresente no output em outra ordem:

1. Primeiro Habilidades (com O QUE SABE FAZER + REGRAS DE EXECUÇÃO + QUANDO ACIONAR + COMO REAGIR aos retornos).
2. Depois Restrições (com bloco 1 + bloco 2 + bloco 3).
3. Depois Informações Sobre Produtos e Serviços.
4. **Por último**, Personalidade e Objetivo da IA — neste ponto, todas as regras, gatilhos e restrições JÁ TÊM CASA. Sobra só OBJETIVO + PERSONA + TOM + NATURALIDADE + EXEMPLOS DE FALA.

Por que: se você gerar Personalidade primeiro (como o modelo tende a fazer porque é o primeiro campo do form), você "derrama" REGRAS GERAIS e EXECUÇÃO DE FUNCTIONS lá, estoura o limite de 2.000 caracteres e duplica conteúdo. Inverter a ordem força cada coisa pra seu lugar.

### Regra 2 — TABELA "WHAT GOES WHERE" (consulte ANTES de escrever cada linha)

Para cada linha que você for escrever no prompt do agente, classifique o conteúdo e mande pra coluna certa. Se a linha não se encaixa em nenhuma, NÃO a escreva.

| Tipo de linha | Vai para | Exemplo |
|---|---|---|
| "Você é X da empresa Y" | Personalidade > OBJETIVO | "Você é Camila, atendente da Clínica X." |
| "Sua missão é ..." | Personalidade > OBJETIVO | "Sua missão é qualificar lead e agendar." |
| "Você fala com [persona]" | Personalidade > PERSONA DO USUÁRIO | "Pessoas 25-55 anos com dor odontológica." |
| "Tom é [formal/informal]" | Personalidade > TOM E ESTILO | "Estilo: Descontraído, leve." |
| "Nunca use travessão / não diga 'claro!' / emoji até 2" | Personalidade > NATURALIDADE HUMANA | (já dado pela skill) |
| Frase literal que o agente fala | Personalidade > EXEMPLOS DE FALA | Saudação: "Oi, tudo bem?" |
| "Habilidade: tirar dúvida sobre X" | **Habilidades** > O QUE SABE FAZER | (lista bulletada) |
| "Nunca invente preço/prazo/política" | **Habilidades** > REGRAS DE EXECUÇÃO | (operacional, não proibição dura) |
| "Se ambíguo, faça 1 pergunta antes de agir" | **Habilidades** > REGRAS DE EXECUÇÃO | (operacional) |
| "**Quando** o usuário X, **execute** ``funcao_Y``" | **Habilidades** > QUANDO ACIONAR | (gatilhos de função) |
| "Quando ``funcao_X`` retornar `sucesso`, responda com 'frase'" | **Habilidades** > COMO REAGIR AOS RETORNOS | (mapeamento) |
| "**Não** dar desconto" / "**Não** prometer fluência" | **Restrições** | (proibição dura) |
| Lista de produtos, horários, FAQ | **Informações Sobre Produtos e Serviços** | (catálogo) |

**Sinais óbvios de classificação errada:**
- Linha começa com "Quando o usuário ..." em Personalidade → MOVA pra Habilidades.
- Linha começa com "Quando ``funcao_X`` retornar" em Personalidade → MOVA pra Habilidades.
- Linha começa com "Nunca invente" / "Não X" em Personalidade ou Habilidades → MOVA pra Restrições.
- Aparecem palavras `REGRAS GERAIS`, `EXECUÇÃO DE FUNCTIONS`, `REGRAS DE EXECUÇÃO`, `MAPEAMENTO`, `QUANDO ACIONAR` em Personalidade → MOVA o bloco inteiro pra Habilidades.

### Regra 3 — SILÊNCIO sobre o processo interno

A ordem de geração invertida (Regra 1) e o auto-check são processos **internos**. NÃO mostre nada disso no output ao usuário. Não escreva:

- ❌ "Vou gerar internamente na ordem Habilidades → Restrições → Produtos → Personalidade…"
- ❌ "Geração interna (rascunho não exibido)…"
- ❌ "Auto-check Personalidade: 1. Todas as linhas descrevem… ✅"
- ❌ "Aplicando a tabela WHAT GOES WHERE…"
- ❌ "Validação pré-output: Personalidade tem APENAS os 5 blocos? Sim."
- ❌ Qualquer narração do processo de pensamento ou de validação.

O output começa diretamente em `# Agente: {{Nome}}` (ou na confirmação curta do briefing se você ainda precisa fazer perguntas). Faça o processo silenciosamente; só o resultado final aparece pro usuário.

O **checklist final** no fim do output é a única exceção — esse é entregável, com OK/AJUSTAR por item.

### Regra 4 — CONTAGEM DE CARACTERES é STOP rígido

Para cada bloco copiável você vai:

1. Escrever o conteúdo.
2. **Contar os caracteres** (incluindo quebras de linha).
3. Se passou do limite, **PARE**, refaça mais enxuto, conte de novo, repita até passar.
4. Só **depois** de estar dentro do limite, devolver o bloco.
5. Escrever a linha `*X / Y caracteres*` fora do bloco, com a contagem real.

Limites estritos a memorizar:
- Nome: **50** | Descrição: **1.000** | Personalidade: **2.000** | Habilidades: **20.000** | Produtos: **20.000** | Restrições: **2.000** | Prompt da Função: **2.000** | Descrição do parâmetro: **500**.

Se você está chegando perto do limite na Personalidade (>1.800 caracteres), é sinal quase certo de que você derramou algo que pertence a Habilidades. Volte a aplicar a tabela WHAT GOES WHERE.

---

## Passo 1 — Briefing (perguntas obrigatórias antes de gerar)

Faça as perguntas abaixo usando `AskUserQuestion` (uma chamada com 3-5 perguntas). NÃO gere nada antes de obter respostas para 1, 2, 3 e 4. Se o usuário já tiver respondido alguma no pedido inicial, pule essa.

1. **Escopo do agente** — "O que esse agente precisa fazer? (atender, vender, qualificar lead, agendar, dar suporte, fazer follow-up, etc) Resuma em uma frase."
2. **Persona-alvo** — "Quem é a pessoa do outro lado da conversa? Inclua: nicho/segmento, faixa de idade ou perfil profissional, nível de familiaridade com o produto."
3. **Estilo de comunicação do agente** — pergunta de escolha única com as opções:
   - **Formal** — vocabulário cuidado, frases completas, sem gírias. Bom para advocacia, saúde, finanças, B2B corporativo.
   - **Informal** — natural, próximo, "você" o tempo todo, contrações comuns ("tá", "pra", "tô"), zero pompa. Bom para serviços ao consumidor final, e-commerce, infoprodutos.
   - **Descontraído** — informal + leveza, bom humor sutil, emojis pontuais quando fizer sentido, pode brincar com a situação sem perder objetividade. Bom para marcas jovens, lifestyle, food, beleza.
   - **Descrever do meu jeito** — usuário escreve em texto livre como quer o tom (ex.: "fala como um amigo nerd que entende muito do assunto" ou "carinhoso e maternal, sem ser meloso").
   
   Independente da escolha, pergunte também: **"Pode usar abreviações típicas de digitação humana e errinhos ocasionais (tipo 'vc', 'tbm', 'ngm', algumas trocas de letra)? (sim / não)"** — só ofereça "sim" se o estilo for Informal ou Descontraído; em Formal force "não".
4. **Dados que o agente precisa coletar** — "O agente vai precisar coletar QUAIS informações do usuário durante a conversa? Liste cada uma (ex.: nome, e-mail, produto desejado, data preferida, orçamento)." → cada item vira uma **função**.
5. **Restrições e proibições adicionais** — "Tem algo específico que o agente NUNCA pode fazer/dizer? (ex.: prometer prazos, dar desconto, falar de concorrente, opinar sobre política). Pode responder 'nenhuma específica' — eu vou gerar restrições padrão baseadas no escopo de qualquer jeito." O campo Restrições **sempre é preenchido** com defaults universais + restrições inferidas do tipo de agente. Esta pergunta só **acrescenta** restrições particulares do usuário; nunca substitui as obrigatórias.
6. **Contexto operacional** (pergunte numa pergunta só, mas espere os 4 dados) — "Pra eu não inventar nada: (a) nome da empresa/marca, (b) idioma do público (pt-BR é o default), (c) canal principal (WhatsApp, Instagram, web chat), (d) se você tem preferência de nome humano pro agente (ou deixo eu sugerir)." Use as respostas literalmente em OBJETIVO, PERSONA DO USUÁRIO e TOM E ESTILO. Se faltar (a) ou (c), **pare e pergunte de novo** — não invente nome de empresa nem suponha canal.

Se o usuário disser que tem produtos/serviços específicos a oferecer, pergunte se quer colar a lista (vai para o campo **Informações Sobre Produtos e Serviços**). Se a lista for dinâmica/atualizável, registre que isso deveria virar **variável de bot** (não embutir no prompt).

## Passo 2 — Geração dos campos do AGENTE

> ⚠️ Releia agora o **ENFORCEMENT PROTOCOL** no topo da skill (4 regras: ordem de geração, tabela WHAT GOES WHERE, silêncio sobre o processo interno, contagem de caracteres). Tudo abaixo presume que você está seguindo essas 4 regras.

**Ordem interna de geração** (mesmo que você apresente no output em outra ordem, gere o conteúdo nesta ordem):

1. **Habilidades** primeiro — todo gatilho de função, toda regra de execução, todo mapeamento de retorno vai aqui antes de qualquer outro campo ser pensado.
2. **Restrições** segundo — bloco 1 + bloco 2 + bloco 3.
3. **Informações Sobre Produtos e Serviços** terceiro.
4. **Personalidade e Objetivo da IA por ÚLTIMO** — neste momento as regras já têm casa em Habilidades, as proibições em Restrições. Sobra só persona/tom/exemplos.

**Ordem de apresentação no output**: pode seguir a ordem do formulário (Nome → Descrição → Personalidade → Habilidades → Produtos → Restrições → Ajustes). A ordem interna é só pra o conteúdo cair no lugar certo.

Devolva em markdown, um bloco por campo, exatamente nos nomes que o formulário usa. Cada bloco deve estar em ` ```text ` para o usuário copiar limpo. Ordem e regras:

#### REGRA DE OURO DE FORMATAÇÃO (não violar)

Dentro do bloco ` ```text ` vai **APENAS o conteúdo literal que o usuário cola no campo do NicoChat**. Nada mais.

Tudo que for **recomendação, instrução, comentário, lembrete, sugestão de variável, "criar isso no NicoChat", "lembre-se de…", "este campo serve para…"** fica **FORA** do bloco copiável, em texto normal acima ou abaixo do bloco.

Por quê: o usuário copia o bloco inteiro de uma vez. Se houver instrução misturada com conteúdo, ela vai parar no prompt em produção e o agente vai tratar isso como contexto — viola o cap. 9 do ebook (antidelírio).

Padrão sempre:

```
### Campo: <Nome do Campo>

<recomendações, observações, "lembre de criar variável X", etc — em texto normal>

```text
<APENAS o que vai ser colado no campo, sem meta-comentário>
```

<eventuais notas adicionais — também em texto normal, FORA do bloco>
```

Exemplos do que **nunca** entra no bloco ` ```text `:
- `VARIÁVEIS DE BOT RECOMENDADAS (criar no NicoChat)`
- `Lembrar de criar o sub-fluxo…`
- `Este campo pode ficar vazio se…`
- `Sugestão: usar tipo:json porque…`
- Qualquer rótulo de seção tipo `RECOMENDAÇÕES`, `OBSERVAÇÕES`, `DICAS`.

Essas linhas existem para orientar o usuário, **não** para o agente em produção. Mantenha-as em markdown comum, antes ou depois do bloco copiável.

#### LIMITES DE CARACTERES (validação obrigatória antes de devolver)

Os campos do NicoChat têm limites fixos. **Conte os caracteres de cada bloco copiável antes de enviar a resposta.** Se algum estourar, corte conforme as regras de cada campo abaixo. Nunca devolva um bloco acima do limite — o NicoChat rejeita ou trunca.

| Campo | Limite | Onde aparece |
|---|---|---|
| Nome (agente) | **50** | abaixo |
| Descrição (agente) | **1.000** | abaixo |
| Personalidade e Objetivo da IA | **2.000** | abaixo |
| Habilidades | **20.000** | abaixo |
| Informações Sobre Produtos e Serviços | **20.000** | abaixo |
| Restrições | **2.000** | abaixo |
| Nome (função) | **50** | Passo 3 |
| Descrição (função) | **1.000** | Passo 3 |
| Prompt da Função | **2.000** | Passo 3 |
| Descrição do parâmetro | **500** | Passo 3 |

Logo abaixo de cada bloco ` ```text `, adicione uma linha em markdown comum no formato: `*X / Y caracteres*` (ex.: `*1.847 / 2.000 caracteres*`) para o usuário ver de relance que está dentro do limite. Essa linha fica **fora** do bloco copiável.

### Nome
- Sempre **nome humano** (ex.: Camila, Rafael, Bruno, Helena). Curto, fácil de pronunciar, coerente com o público-alvo. Sem sobrenome a não ser que o usuário peça.
- **LIMITE ESTRITO: 50 caracteres.**

### Descrição
- 1-2 frases internas, em português, descrevendo o que o agente faz e para quem. NÃO é o que o agente diz — é descrição administrativa.
- **LIMITE ESTRITO: 1.000 caracteres** (mire em 200).

### Personalidade e Objetivo da IA (campo "Principal" — limite ESTRITO 2000 caracteres)

#### 🚫 BLACKLIST — NUNCA inclua estas seções neste campo

As seções abaixo aparecem no ebook cap. 10 como parte do prompt do agente, **mas no NicoChat elas pertencem ao campo Habilidades, NÃO a este**. Se você se pegar gerando qualquer uma delas aqui, **PARE e mova para Habilidades**:

- ❌ `REGRAS GERAIS` / `REGRAS DE EXECUÇÃO` / `REGRAS DO AGENTE`
- ❌ `EXECUÇÃO DE FUNCTIONS` / `QUANDO ACIONAR` / `GATILHOS DE FUNÇÃO`
- ❌ `MAPEAMENTO DE RETORNOS` / `RESPOSTA POR STATUS` / `COMO REAGIR AOS RETORNOS`
- ❌ `O QUE VOCÊ SABE FAZER` / `HABILIDADES`
- ❌ Qualquer linha do tipo "Quando o usuário X, execute ``funcao_Y``"
- ❌ Qualquer linha do tipo "Nunca invente preço/prazo/política" (vai em Restrições)
- ❌ Qualquer linha de validação ou regra de execução operacional

#### ✅ Apenas estas 5 seções podem aparecer neste campo (nesta ordem exata)

1. `OBJETIVO`
2. `PERSONA DO USUÁRIO`
3. `TOM E ESTILO`
4. `NATURALIDADE HUMANA`
5. `EXEMPLOS DE FALA`

Pense neste campo como **"como o agente SOA"**. Habilidades é **"como o agente AGE"**. Tudo que é lógica, regra, gatilho ou execução vai em Habilidades, sem exceção.

#### Estrutura fixa (use estes cabeçalhos exatos)

```
OBJETIVO
- Você é {{Nome}}, [papel curto] da [empresa/contexto].
- Sua missão em uma frase: [resultado esperado].

PERSONA DO USUÁRIO
- [Descrição da persona em 1 frase — nicho, perfil, familiaridade com o produto].
- Adapte vocabulário, exemplos e tom a essa pessoa o tempo todo.

TOM E ESTILO
- Estilo: [Formal | Informal | Descontraído | descrição livre].
- Você soa como uma pessoa de verdade, NÃO como IA.
- Respostas curtas. No máximo [N] linhas, exceto se pedirem detalhe.
- Idioma: [idioma do público].

NATURALIDADE HUMANA (anti-robô — obrigatório)
- Nunca use travessão "—" ou "–". Use ponto, vírgula ou quebra de linha.
- Nunca use: "claro!", "com certeza!", "fico feliz em ajudar", "espero ter ajudado", "vale lembrar que", "como posso te ajudar hoje?".
- Não feche mensagens resumindo o que acabou de dizer.
- Não use bullets nem numeração em conversa curta. Frases corridas.
- Emoji: [Formal: 0 | Informal: até 1 | Descontraído: até 2].
- Varie como começa as mensagens.
- Contrações: "tá", "pra", "tô", "cê", "né" [quando estilo permitir].
- [SE liberou abreviações:] Use ocasionais ("vc", "tbm", "blz") e raramente 1 erro de digitação. Máx 1 a cada 3-4 msgs. NUNCA em nome, valor, data, endereço.
- [SE NÃO liberou:] Ortografia sempre correta.

EXEMPLOS DE FALA
- Saudação: "[exemplo curto]"
- Quando não sabe responder: "[exemplo]"
- Pedindo 1 dado: "[exemplo natural]"
```

Regras de delimitador (cap. 2 do ebook):
- ` ``nome_funcao`` ` (crase duplo) só para nomes de função/parâmetros.
- `"frase literal"` (aspas duplas) para frases que o agente fala.
- `'resposta curta'` (aspas simples) para respostas exatas.

#### ⚠️ AUTO-CHECK obrigatório antes de devolver este campo

Releia o bloco que você gerou para Personalidade e Objetivo. Para cada linha, pergunte:

1. Essa linha descreve **como o agente soa** (persona, tom, naturalidade, exemplo de fala)? → fica aqui ✅
2. Essa linha descreve **o que o agente faz / quando faz / como reage** (regra, gatilho de função, mapeamento de retorno, validação)? → **mova para Habilidades** ❌
3. Essa linha começa com "Quando o usuário..." ou "Quando ``funcao_X`` retornar..."? → **mova para Habilidades** ❌
4. Essa linha começa com "Nunca invente / não prometa / não opine"? → **mova para Restrições** ❌

Só devolva quando todas as linhas restantes responderem "soa". Se mover algo, **conte os caracteres de novo** — o bloco ficou menor.

#### Contagem de caracteres

**LIMITE ESTRITO: 2.000 caracteres.** Conte antes de devolver e mostre a contagem fora do bloco (`*X / 2.000 caracteres*`). Se passar:
1. Primeiro confira se você não tem entulho da blacklist — se tiver, mover já resolve.
2. Se ainda passar, corte na ordem: exemplos de fala extras → contrações listadas → vícios de IA listados (mantenha pelo menos 3-4).
3. Nunca corte OBJETIVO, PERSONA DO USUÁRIO, TOM, ou a proibição de travessão.

### Habilidades (limite ESTRITO 20.000 caracteres)

#### ✅ É AQUI que vão as seções banidas do Personalidade

Tudo que o ebook cap. 10 coloca no "prompt do agente" como `REGRAS GERAIS`, `EXECUÇÃO DE FUNCTIONS (QUANDO)`, `O QUE VOCÊ SABE FAZER` ou mapeamento de retorno **vai NESTE campo**, NÃO em Personalidade. Se você está vendo regras operacionais ou gatilhos de função no campo Personalidade que você gerou, **mova tudo pra cá agora**.

Pense neste campo como **"como o agente AGE"**. Personalidade é **"como o agente SOA"**.

#### Estrutura fixa

```
O QUE VOCÊ SABE FAZER
- [Habilidade 1 — derivada do escopo + persona]
- [Habilidade 2]
- [Habilidade 3]
- [4-8 itens no total]

REGRAS DE EXECUÇÃO
- Nunca invente dado, preço, prazo, política ou condição comercial.
- Se não souber, diga que vai verificar e siga para [encaminhar/registrar].
- Se a intenção do usuário estiver ambígua, faça 1 pergunta curta antes de agir.
- Antes de confirmar pedido/agendamento/cadastro, sempre dispare a função correspondente.
- [demais regras operacionais do escopo do agente]

QUANDO ACIONAR CADA FUNÇÃO
- Quando o usuário [gatilho 1 — intenção, dado solicitado, etapa], execute ``nome_funcao_1``.
- Quando o usuário [gatilho 2], execute ``nome_funcao_2``.
- ... (uma linha por função criada no Passo 3, com gatilho específico)
- Se houver ambiguidade entre 2 funções, faça 1 pergunta antes de escolher.

COMO REAGIR AOS RETORNOS DAS FUNÇÕES
- Quando ``nome_funcao_1`` retornar `sucesso`, responda com: 'frase curta'.
- Quando ``nome_funcao_1`` retornar `erro_validacao`, responda com: 'frase curta de correção'.
- ... (uma linha por par função × status do mapeamento de cada função)
- Não adicione explicações extras nesses retornos.
```

#### ⚠️ AUTO-CHECK obrigatório antes de devolver Habilidades

Releia o bloco e confira:

1. Existe **uma linha** em QUANDO ACIONAR CADA FUNÇÃO para cada função que você criou no Passo 3? (Se gerou 3 funções, tem que ter 3 linhas — nem mais, nem menos.)
2. Existe **pelo menos `sucesso` e `erro_validacao`** em COMO REAGIR para cada função? Os nomes dos status batem exatamente com o RETORNOS (MAPEAMENTO) do prompt da função correspondente?
3. Você está repetindo aqui frases do TOM E ESTILO ou da NATURALIDADE HUMANA? Se sim, **remova**: aquilo é do Personalidade.
4. Você está repetindo aqui itens do bloco Restrições? Se sim, **mantenha aqui apenas como orientação operacional** ("antes de confirmar, dispare X") e deixe a proibição dura em Restrições.

Notas:
- A seção **QUANDO ACIONAR CADA FUNÇÃO** descreve só o gatilho/intenção. O **COMO** (validar parâmetros, formato de saída) fica no prompt da própria função — cap. 3 do ebook.
- A seção **COMO REAGIR AOS RETORNOS** espelha exatamente o bloco RETORNOS de cada função. As chaves de status (`sucesso`, `erro_validacao`, etc) precisam bater exatamente com o que está no prompt da função E com as saídas configuradas no bloco "Resultado da função AI" do sub-fluxo.

**LIMITE ESTRITO: 20.000 caracteres.** Folga grande, mas se passar (caso raro com muitas funções), priorize cortar habilidades repetidas, depois exemplos. Mantenha sempre todas as funções listadas em QUANDO ACIONAR e em COMO REAGIR.

### Funções de IA
Apenas listar os nomes das funções (em inglês, snake_case) que serão criadas no Passo 3. Esse campo é um seletor — o conteúdo real vai no formulário separado.

### Informações Sobre Produtos e Serviços
Escolha o formato pela complexidade do conteúdo:

- **Informação simples** (lista de planos por nome, FAQ curta, lista de serviços só com nome): texto puro com bullets ou linhas separadas por vírgula. Não suba para JSON/YAML sem motivo.
- **Informação complexa** (cardápio com categorias e preços, tabela de procedimentos com duração e valor, horário de atendimento por dia da semana, catálogo com especificações por item): **YAML** dentro do campo (cap. 4 do ebook — YAML rende melhor para recuperação por chave). Se for alimentar via banco/planilha, recomende **JSON** numa variável de bot dedicada.
- **Conteúdo dinâmico/atualizável** (muda fora do prompt): deixe o campo vazio e recomende criar **variável de bot** — tipo de variável de acordo com a tabela acima (texto para lista simples separada por vírgula; JSON só se for estrutura complexa). Ex.: `cardapio_json` (tipo:json) para cardápio estruturado; `lista_servicos` (tipo:texto) com valor `corte, barba, sobrancelha` (uma linha, itens separados por vírgula).
- **Sem produtos/serviços**: deixe vazio explicitamente.

**LIMITE ESTRITO: 20.000 caracteres.**

**Atenção (regra de ouro de formatação aplicada aqui):** se você for sugerir variáveis de bot a criar, ou avisos como "o cronograma completo fica fora do prompt", **isso vai em texto normal antes/depois do bloco copiável**, não dentro. O conteúdo dentro do ` ```text ` é só o que cola no campo do NicoChat. Use uma seção em markdown logo abaixo do bloco com o rótulo "**Variáveis de bot a criar:**" ou "**Observações:**" — fora do bloco.

### Restrições (campo OBRIGATÓRIO — nunca devolver vazio)

⚠️ Este campo é **sempre gerado**, sem exceção. Mesmo que o usuário tenha dito "não tenho restrição específica" na pergunta 5 do briefing, você ainda preenche este campo com os defaults universais + as restrições inferidas do escopo do agente. Restrições é a principal defesa contra delírio (cap. 9 do ebook).

#### Composição obrigatória do campo

**Bloco 1 — Defaults universais (SEMPRE inclua os 6):**

- Não inventar preço, prazo, condição comercial, política ou disponibilidade.
- Não opinar sobre política, religião, concorrentes ou temas controversos.
- Não prometer resultado, garantia, retorno ou prazo que não esteja explicitamente nas suas informações.
- Não responder fora do escopo de [domínio do agente] — redirecionar educadamente.
- Não confirmar pedido, agendamento, cadastro ou ação executável sem antes disparar a função correspondente.
- Não pedir dados sensíveis sem necessidade clara (CPF, cartão, senha, documento) — e quando pedir, explicar por quê.

**Bloco 2 — Restrições por tipo de agente (inclua TODAS as que se aplicam ao escopo):**

| Tipo de agente | Restrições obrigatórias a adicionar |
|---|---|
| Vendas / qualificação de lead | Não dar desconto, prazo ou condição não autorizada. Não fechar venda sem disparar a função de registro. Não negociar valor por iniciativa própria. |
| Atendimento / suporte | Não diagnosticar problema técnico complexo sem encaminhar ao humano. Não prometer prazo de resolução. Não acessar dados de outro cliente. |
| Agendamento | Não confirmar horário sem disparar a função de agendamento. Não marcar fora do horário comercial declarado. Não remarcar cancelamento sem confirmar com o usuário. |
| Saúde / clínica / estética | Não dar diagnóstico, prescrever, sugerir tratamento ou indicar medicamento. Não opinar sobre procedimentos. Sempre encaminhar dúvida clínica ao profissional. |
| Jurídico / financeiro | Não dar parecer jurídico, sugerir estratégia processual ou recomendar decisão financeira. Sempre indicar que a orientação final é do profissional habilitado. |
| Educacional / infoproduto | Não garantir resultado, "transformação", retorno financeiro ou prazo de aprendizado. Não comparar com concorrente. |
| Cobrança / financeiro recebíveis | Não ameaçar, não usar tom coercitivo, não revelar valor para terceiros. Cumprir CDC. |

**Bloco 3 — Restrições explícitas do usuário (do briefing):**

- Tudo que o usuário citou na pergunta 5 entra aqui textualmente, sem reinterpretar.

**Bloco 4 — Restrições inferidas do contexto** (opcional, só se houver sinal claro no briefing):

- Ex.: se o agente vende algo regulado (suplemento, financiamento, plano de saúde), adicionar restrição sobre afirmações controladas pelo órgão regulador.

#### Regras de geração

- **Mínimo absoluto: 8 itens.** Conta: bloco 1 = 6 itens fixos. Você precisa adicionar **pelo menos 2 itens** do bloco 2 (escolha as restrições do tipo de agente correspondente ao escopo) para chegar a 8. Se o escopo encaixa em vários tipos (ex.: agendamento + saúde), use itens dos dois.
- Frases curtas, no infinitivo ("Não fazer X"). Uma linha por item.
- Sem repetir o que já está no campo Personalidade (NATURALIDADE HUMANA) ou em Habilidades (REGRAS DE EXECUÇÃO). Se houver sobreposição, mantenha aqui o que é proibição dura (NÃO), e lá o que é orientação de execução.
- Se o usuário disse "não tenho restrição", você ainda assim preenche com bloco 1 + bloco 2 inferido do escopo, e avisa **fora do bloco copiável**: "Gerei restrições padrão baseadas no escopo. Revise se alguma não se aplica ao seu caso."

**LIMITE ESTRITO: 2.000 caracteres.** Se passar, corte na ordem: bloco 4 → itens duplicados do bloco 1 vs bloco 2. Nunca corte o bloco 3 (restrições do usuário).

### Ajustes (seção "2. Ajustes" do formulário)

Recomende valores concretos para os campos abaixo, sempre justificando em 1 linha cada um. **Não recomende** "Número de mensagens de bate-papo antes do resumo automático" — deixe explícito que o usuário decide e pule esse campo.

#### Modelo
- Fornecedor: **sempre OpenAI - Chat Completions**.
- Campo "Modelo": escolha entre `gpt-4.1-mini` e `gpt-4.1`, de acordo com a complexidade do agente:

| Complexidade do agente | Modelo recomendado | Quando |
|---|---|---|
| Baixa/Média | `gpt-4.1-mini` | Atendimento direto, FAQ, qualificação simples, coleta de 1-3 dados, poucas funções (≤ 3), respostas curtas e padronizadas, regras de negócio simples. **Default — comece por aqui.** |
| Alta | `gpt-4.1` | Vendas consultivas, raciocínio sobre catálogo grande, múltiplas funções encadeadas (4+), saída JSON estruturada complexa, decisões com várias condições, interpretação de mensagens longas/ambíguas, múltiplos idiomas. |

Critério prático: se o briefing tem **≥ 4 funções**, **lista de produtos/serviços não-trivial**, ou exige **raciocínio em cadeia** (ex.: "se A e B, mas não C, então oferecer D"), suba para `gpt-4.1`. Caso contrário, fique no `gpt-4.1-mini`.

#### Parâmetros — Temperatura
Recomende 1 valor entre 0.2 e 0.8, baseado no tipo de agente:

| Tipo de agente | Temperatura | Por quê |
|---|---|---|
| Operacional / coleta de dado / status / confirmação | **0.2 – 0.3** | Saída previsível, pouca variação. Reduz risco de "fugir" do formato em funções. |
| Atendimento padrão / suporte / qualificação | **0.4 – 0.5** | Equilíbrio: segue regras mas soa natural. Default da maioria dos agentes. |
| Vendas consultivas / copy persuasivo / criativo controlado | **0.6 – 0.8** | Mais variação no texto, melhor para argumentação. Combine com restrições fortes para não delirar (cap. 9 do ebook). |

Regra do ebook: quanto **mais solto** o modelo (temperatura alta), **mais restritivo** o prompt precisa ser. Se subir temperatura, reforce o bloco REGRAS GERAIS e RESTRIÇÕES.

#### Parâmetros — Penalidade de frequência
Recomende 1 valor entre 0.0 e 0.6:

| Cenário | Penalidade de frequência |
|---|---|
| Default geral | **0.3** |
| Agente que repete muito (descrições de produto similares, follow-ups) | **0.4 – 0.6** |
| Agente que precisa repetir termos técnicos/nomes de produto sem variar | **0.0 – 0.2** |

#### Parâmetros — Penalidade de presença
Recomende 1 valor entre 0.0 e 0.5:

| Cenário | Penalidade de presença |
|---|---|
| Default geral | **0.2** |
| Agente que deve introduzir tópicos novos / explorar (vendas consultivas, descoberta) | **0.3 – 0.5** |
| Agente que deve ficar no mesmo trilho temático (suporte focado, coleta) | **0.0 – 0.1** |

#### Número de mensagens de bate-papo antes do resumo automático
**Não recomendar.** Escreva apenas: "Defina conforme a duração média da sua conversa — a skill não opina aqui." Pule o campo.

#### Máximo de Tokens
Sempre **≥ 2000**. Recomende um valor concreto:

| Tipo de agente | Máximo de tokens |
|---|---|
| Coleta curta / confirmações / status | **2000** |
| Atendimento padrão / suporte | **2000 – 3000** |
| Vendas consultivas / explicações longas / agente que monta JSON grande | **3000 – 4000** |

Nunca recomende abaixo de 2000. Se o agente precisa devolver JSON estruturado em alguma função, suba para 3000+ por segurança.

#### Formato de saída desta seção
Devolva como um bloco enxuto no fim do agente, antes das funções:

```text
Modelo: OpenAI - Chat Completions / gpt-4.1-mini
  Por quê: 3 funções, coleta simples, sem catálogo dinâmico.
Temperatura: 0.4
  Por quê: atendimento padrão — equilíbrio entre previsibilidade e naturalidade.
Penalidade de frequência: 0.3
Penalidade de presença: 0.2
Máximo de Tokens: 2000
Número de mensagens antes do resumo automático: (não recomendado pela skill — defina conforme sua operação)
```

## Passo 3 — Geração de cada FUNÇÃO

### 🎯 Princípio central: 1 função = 1 ETAPA da conversa, NÃO 1 dado coletado

Cada função do NicoChat aceita **N parâmetros**. Isso significa que você deve **agrupar dados relacionados na mesma função**, em vez de criar uma função por dado. Gerar `collect_name`, `collect_email`, `collect_phone` como 3 funções separadas é **erro de design** — o correto é uma única `collect_contact_info` com 3 parâmetros (`name`, `email`, `phone`).

#### Como agrupar dados em funções

Use estes critérios. Dados que satisfaçam o **mesmo** critério vão juntos na **mesma** função:

1. **Mesma etapa do funil/conversa** — dados que sempre são pedidos no mesmo momento. Ex.: nome + telefone (contato inicial), data + horário (slot de agendamento), produto + tamanho + cor (item do pedido).
2. **Mesma intenção** — dados que respondem à mesma pergunta de negócio. Ex.: orçamento + tipo de imóvel + quartos + bairros + prazo (qualificação imobiliária).
3. **Mesma ação** — dados que vão para o mesmo registro final. Ex.: CPF + nome confirmado (identificação do devedor); produto + tamanho + cor + CEP (registro do pedido).
4. **Mesma fonte de validação** — dados que dependem do mesmo backend ou regra. Ex.: CEP + endereço completo (mesma consulta de CEP).

#### Quando SEPARAR em funções diferentes

Crie funções distintas quando houver mudança em **qualquer um** destes:

- **Ação diferente:** coletar é diferente de registrar, diferente de agendar, diferente de encaminhar.
- **Momento muito diferente da conversa:** dado pedido na saudação inicial vs dado pedido só após confirmação de interesse.
- **Validação muito mais cara/complexa:** ex.: CPF precisa consultar base de cadastro, e isso pode falhar — separar de uma coleta simples.
- **Dependência condicional forte:** ex.: `plano_saude` só vale se `tipo_atendimento == plano` — pode ficar como param opcional na mesma função, mas se a lógica do sub-fluxo for muito diferente, separar.

#### Exemplos práticos (refazendo agentes que estavam errados)

**Antes (errado — 5 funções para barbearia):**
- `collect_customer_name`, `collect_service_type`, `collect_appointment_date`, `collect_appointment_time`, `collect_phone` + `schedule_appointment`

**Depois (certo — 3 funções para barbearia):**
- `collect_contact_info` (parâmetros: `name`, `phone`)
- `collect_appointment_slot` (parâmetros: `service`, `date`, `time`)
- `schedule_appointment` (executora final)

**Antes (errado — 6 funções para clínica odontológica):**
- `collect_full_name`, `collect_phone`, `collect_urgency`, `collect_payment_type`, `collect_treatment_interest` + `schedule_initial_evaluation`

**Depois (certo — 3 funções para clínica):**
- `collect_patient_contact` (parâmetros: `full_name`, `phone`)
- `collect_qualification` (parâmetros: `urgency_level`, `payment_type`, `health_plan_name` opcional, `is_first_visit`, `treatment_interest`)
- `schedule_initial_evaluation` (executora final)

**Antes (errado — 9 funções para imobiliária):**
- 7 collect_* separadas + 2 executoras

**Depois (certo — 4 funções para imobiliária):**
- `collect_lead_contact` (parâmetros: `name`, `phone`)
- `collect_lead_preferences` (parâmetros: `budget_range`, `property_type`, `bedrooms`, `neighborhoods`, `timeframe`)
- `handoff_to_broker` (executora condicional — leads quentes)
- `enroll_in_nurture_funnel` (executora condicional — leads frios)

#### Regra de quantidade

Para a maioria dos agentes, o número total de funções fica entre **2 e 5**:
- 1-3 funções de coleta (agrupando dados por etapa/intenção)
- 1-2 funções executoras (ação final no mundo)

Se você gerou **mais de 5 funções**, releia e tente agrupar. Se gerou **menos de 2**, está faltando coleta ou executora.

### Identifique as ações executoras finais

**Além das funções de coleta, identifique TODAS as ações executoras finais que o escopo do agente exige** e gere uma função separada para cada uma. Ações executoras NÃO são opcionais — são o motivo do agente existir.

| Escopo típico (da pergunta 1 do briefing) | Função(ões) executora(s) obrigatórias além das de coleta |
|---|---|
| Agendar, marcar horário | `schedule_appointment` (ou similar) — função final que grava o agendamento no sistema |
| Vender, fechar pedido | `register_order` ou `create_order` — registra o pedido |
| Qualificar lead | `register_lead` ou `qualify_and_handoff` — registra o lead qualificado |
| Suporte, atendimento | `open_ticket` ou `handoff_to_human` — abre chamado / encaminha |
| Cadastrar | `register_customer` — efetiva o cadastro no banco |
| Cobrança | `register_payment_intent` ou similar |

**Regra prática:** se o agente, segundo o escopo, **toma uma ação no mundo** (grava, agenda, registra, encaminha), tem que existir uma função executora final. As funções de coleta só preenchem variáveis; quem efetua a ação é a executora. Sem ela, o agente fica conversando no vazio.

Use um cabeçalho `## Função: nome_em_ingles` para cada função (coleta + executora) e dentro:

### Nome
- **Em inglês**, snake_case, verbo + objeto agrupador. Ex.: `collect_contact_info`, `collect_appointment_slot`, `collect_lead_preferences`, `register_order`, `schedule_appointment`, `handoff_to_human`. Evite nomes que se referem a 1 só dado (`collect_email`, `collect_name`) — agrupe na mesma função.
- **LIMITE ESTRITO: 50 caracteres.**

### Descrição
- 1-2 frases em português dizendo o que a função faz e quando o agente a usa.
- **LIMITE ESTRITO: 1.000 caracteres** (mire em 150).

### Prompt da Função (campo "Gerar")
Estrutura fixa (template do cap. 10 + padrões dos cap. 3, 6, 7, 9 do ebook):

```
OBJETIVO DA FUNÇÃO
- ``nome_funcao`` serve para [o que a função faz em 1 frase].

PARÂMETROS (COMO COLETAR)
- ``param_1``: tipo, formato esperado, exemplo, obrigatório/opcional.
- ``param_2``: tipo, formato esperado, exemplo, obrigatório/opcional.

VALIDAÇÕES
- [regra de validação por parâmetro: range, formato, presença em lista].
- Se inválido, peça correção UMA vez, com exemplo do formato esperado.

FORMATO OBRIGATÓRIO
- [se a função produz JSON estruturado, mostrar exemplo concreto]

RETORNOS (MAPEAMENTO)
- Se retorno == ``sucesso`` → enviar somente: 'Mensagem curta de confirmação'.
- Se retorno == ``erro_validacao`` → enviar somente: 'Mensagem curta de correção'.
- Não adicionar explicações extras.
```

**LIMITE ESTRITO: 2.000 caracteres.** Se passar, corte na ordem: exemplos de FORMATO OBRIGATÓRIO → validações redundantes → descrições longas de parâmetro (a descrição detalhada vai no campo "Descrição do parâmetro", não aqui).

### Parâmetros de função
Para cada parâmetro, devolva uma tabela com as colunas que o formulário pede:

| Campo | Valor | Limite |
|---|---|---|
| Nome (em inglês) | `param_name` | 50 caracteres |
| Descrição | Frase descrevendo o parâmetro e o formato esperado | **500 caracteres** |
| Obrigatório | Sim/Não | — |
| Salvar Resultado em (Campo Personalizado) | nome_da_variavel_de_usuario (ou "—" se não persiste) | — |
| Memória | Ligado / Desligado | — |
| Lista de Opções | Ligado: `opcao1, opcao2, opcao3` / Desligado | — |

Regras de decisão (cap. 6 do ebook + convenções do NicoChat):

- **Lista de Opções** só LIGADA quando o parâmetro é **escolha única** (ex.: tipo de plano: básico/pro/premium, sim/não, categoria fixa). NUNCA quando o usuário pode escolher múltiplos itens.
- **Formato das opções: sempre separadas por vírgula em uma única linha.** Ex.: `básico, pro, premium` ou `sim, não` ou `manhã, tarde, noite`. Sem aspas, sem bullets, sem quebra de linha entre itens.
- **Se as opções vierem de uma variável** (lista que muda — ex.: cardápio, planos sazonais): a variável é **UMA SÓ**, do tipo **texto**, e o valor dela segue **exatamente o mesmo formato fixo da Lista de Opções: uma linha, itens separados por vírgula, sem aspas, sem bullets, sem quebra de linha**. Ex.: variável de bot `planos_disponiveis` com valor `básico, pro, premium`. No campo Lista de Opções referencie como `{{planos_disponiveis}}`. **Nunca** crie uma variável por opção e nunca recomende variável JSON aqui — Lista de Opções é texto puro nesse formato.
- Para coleta de **múltiplos itens** (ex.: carrinho com vários produtos): NÃO use lista de opções; em vez disso, no prompt da função, descreva o **formato JSON** do array que o modelo deve preencher, e indique que o JS posterior valida.
- **Salvar Resultado em**: se o dado precisa persistir por contato (e-mail, nome, telefone, orçamento), aponte para variável de usuário. Se é flag global/lista estática, variável de bot. Se é uso só na execução, deixe vazio. Veja a regra de **tipo de variável** logo abaixo.
- **Memória**: ligar quando o agente deve lembrar desse valor nas próximas mensagens da mesma conversa.
- **Obrigatório**: ligar quando a função não pode rodar sem o valor.

#### Tipo de variável a recomendar (texto vs número vs JSON)

Default: **texto** (ou número, quando for número puro). **JSON é exceção, não regra.**

| Conteúdo da variável | Tipo recomendado |
|---|---|
| Nome, e-mail, telefone, cidade, escolha única, status, flag de etapa | **Texto** |
| Idade, quantidade, orçamento (valor único), nota | **Número** |
| Lista de opções fixas separadas por vírgula (ex.: `básico, pro, premium`) | **Texto** — valor numa única linha, itens separados por vírgula. NÃO é JSON. |
| Carrinho com múltiplos itens + quantidade + observação por item | **JSON** |
| Horário de atendimento por dia da semana | **JSON** |
| Lista de procedimentos com nome + duração + valor | **JSON** |
| Cardápio estruturado com categorias, itens, preços, modificadores | **JSON** |
| Endereço completo se cada parte for usada separadamente (rua, número, cep) | **JSON** |

**Use JSON SOMENTE quando** o dado tem mais de uma propriedade por item, ou é uma estrutura aninhada que precisa ser consultada/iterada. Se cabe numa linha de texto ou num número, não suba para JSON — fica mais difícil de manter e o modelo erra mais na hora de preencher.

Ao recomendar uma variável, deixe explícito o tipo no formato `tipo:texto`, `tipo:número`, `tipo:json` para o usuário não ficar em dúvida ao criá-la no NicoChat.

### Fluxo de Trabalho a Acionar (Function Call)
- Se a função registra/agenda/encaminha algo no NicoChat, sugira um nome de sub-fluxo (ex.: `subflow_register_order`) e diga ao usuário "escolha esse sub-fluxo aqui — ou crie um se ainda não existir".
- Se a função só coleta dado para uso conversacional, escreva "Nenhum (apenas coleta)".

#### Como o resultado da função volta para o prompt do agente (instrução obrigatória)

Sempre que a função tiver mapeamento de retorno (`sucesso`, `erro_validacao`, etc — o bloco "RETORNOS (MAPEAMENTO)" do prompt da função), o usuário **precisa**:

1. **Criar o sub-fluxo** com o mesmo nome usado em "Fluxo de Trabalho a Acionar" (ex.: `subflow_register_order`).
2. Dentro desse sub-fluxo, adicionar o bloco **"Resultado da função AI"** (ícone de peça/puzzle azul, label "Resultado da função AI") logo após o `Start` (ou após as ações que o sub-fluxo executa, ex.: gravar no CRM, mandar e-mail).
3. **Configurar um status por saída** no bloco — um para cada chave do mapeamento de retorno declarado no prompt da função. Os nomes precisam **bater exatamente** com o que está no prompt (ex.: `sucesso`, `erro_validacao`, `fora_horario`).
4. Cada saída de status puxa o ramo do fluxo correspondente. É esse bloco que devolve o status ao agente — sem ele, o mapeamento de retorno do prompt **não tem efeito** e o agente improvisa a resposta.

Devolva esse roteiro como uma lista curta numerada no bloco da função, sempre que houver mapeamento de retorno. Se a função for "Nenhum (apenas coleta)", pule essa instrução.

**Não esqueça do retorno em cada ramo.** Cada saída do bloco "Resultado da função AI" abre um ramo que pode executar ações próprias (mandar mensagem, gravar em variável, chamar outra função). Ao final de cada ramo, o sub-fluxo precisa **devolver o status correspondente** para o prompt do agente — é isso que dispara o mapeamento de RETORNOS declarado no prompt da função (ex.: quando o agente recebe `sucesso`, ele responde com a frase curta definida; quando recebe `erro_validacao`, ele responde com a frase de correção). Sem o retorno explícito ao final do ramo, o agente não recebe o gatilho e improvisa.

Regra: **um ramo no sub-fluxo = um status retornado ao agente = uma condicional executada no prompt**. Os três precisam ter o mesmo nome.

Formato recomendado dentro do bloco da função:

```text
Fluxo de Trabalho a Acionar: subflow_NOME_DA_FUNCAO
Como construir o sub-fluxo:
  1. Criar sub-fluxo "subflow_NOME_DA_FUNCAO".
  2. Adicionar as ações da função (gravar, agendar, validar, etc).
  3. Adicionar o bloco "Resultado da função AI" no final.
  4. Criar uma saída de status para cada chave do mapeamento de retorno:
     sucesso, erro_validacao, ...
  5. Os nomes dos status devem bater exatamente com os do prompt da função.
  6. Em CADA ramo (cada saída), ao terminar as ações próprias daquele ramo,
     devolver o status correspondente para o agente. É o que aciona a
     resposta condicional definida no bloco RETORNOS do prompt da função.
     Sem isso, o agente não recebe o gatilho e improvisa a resposta.
```

> ⚠️ Importante: **nunca use `<` e `>` ao redor dos nomes de status** no texto que vai pro bloco copiável. Em markdown isso vira `&lt;sucesso&gt;` e quebra o copy/paste. Liste os status como nomes nus separados por vírgula (`sucesso, erro_validacao, fora_horario`). O mesmo vale para `<nome_funcao>` — use `NOME_DA_FUNCAO` ou substitua direto pelo nome real.

## Passo 4 — Checklist final (mostre ao usuário antes de encerrar)

Antes de devolver o resultado completo, percorra mentalmente o checklist do cap. 10 do ebook e marque OK/AJUSTAR para cada item. Mostre o checklist no fim da resposta:

- [ ] Agente diz **QUANDO** executar cada função (e não COMO).
- [ ] Cada função diz **COMO** coletar/validar cada parâmetro.
- [ ] Existe formato obrigatório com exemplo para saídas estruturadas.
- [ ] Lista de Opções está ligada APENAS em parâmetros de escolha única, com opções numa única linha separadas por vírgula (ou variável de texto cujo valor segue o mesmo formato — nunca múltiplas variáveis nem variável JSON).
- [ ] Variáveis recomendadas têm o tipo explícito (texto / número / json). JSON aparece apenas para estruturas complexas (cardápio, horários por dia, procedimentos com valor); dados simples ficam em texto/número.
- [ ] Toda função com mapeamento de retorno traz o roteiro do sub-fluxo: criar `subflow_NOME_FUNCAO` (sem `<>` ao redor de nome ou status — usar nomes nus), adicionar o bloco "Resultado da função AI" e configurar uma saída de status por chave do mapeamento, com nomes idênticos aos do prompt.
- [ ] **Função executora final existe.** Se o escopo do agente é "agendar/vender/cadastrar/abrir chamado", existe uma função de ação executora além das de coleta (ex.: `schedule_appointment`, `register_order`, `open_ticket`). Funções de coleta só preenchem variáveis — sem a executora, nada acontece no mundo.
- [ ] **Agrupamento correto de funções (NUNCA 1 função por dado).** Funções de coleta agrupam dados da mesma etapa/intenção/ação como parâmetros da mesma função. Ex.: `collect_contact_info(name, phone)` em vez de `collect_name` + `collect_phone`. Total de funções fica entre **2 e 5** na maioria dos agentes (1-3 coleta agrupada + 1-2 executoras). Se gerou mais de 5, releia e agrupe.
- [ ] Cada ramo do sub-fluxo termina devolvendo o status correspondente ao agente — sem o retorno final, a condicional do prompt não dispara e o agente improvisa.
- [ ] Cada bloco ` ```text ` contém APENAS o conteúdo literal a colar no campo do NicoChat. Recomendações, "criar variável X", "lembrar de Y", rótulos tipo `VARIÁVEIS DE BOT RECOMENDADAS` ficam FORA do bloco, em markdown comum. Verifique campo por campo antes de enviar.
- [ ] **Contagem de caracteres feita em cada bloco** e exibida no formato `*X / Y caracteres*` fora do bloco. Nenhum campo passou do limite (Nome 50, Descrição 1.000, Personalidade 2.000, Habilidades 20.000, Produtos 20.000, Restrições 2.000, Prompt da Função 2.000, Descrição do parâmetro 500).
- [ ] **Divisão correta Personalidade × Habilidades:** Personalidade contém só persona + tom + naturalidade + exemplos de fala. Habilidades contém o que sabe fazer + regras + QUANDO acionar cada função + COMO reagir aos retornos. Não há regras operacionais nem gatilhos de função no campo Personalidade.
- [ ] Existe mapeamento de retorno → resposta curta para sucesso e erro.
- [ ] Listas dinâmicas em variável de bot; seleção do usuário em variável de usuário.
- [ ] Persona aparece explicitamente no campo Personalidade.
- [ ] Bloco NATURALIDADE HUMANA presente: proibição de travessão, de vícios de IA, de fechamentos com resumo, controle de emoji e de bullets em conversa curta.
- [ ] Estilo escolhido pelo usuário (Formal / Informal / Descontraído / livre) está refletido em vocabulário, emoji e permissão de abreviações. Se "sim" para abreviações/erros, regra de frequência e proteção de dados críticos está incluída.
- [ ] Restrições **gerado obrigatoriamente**, nunca vazio, com mínimo 8 itens. Cobre: bloco 1 (6 defaults universais) + bloco 2 (restrições do tipo de agente — vendas/atendimento/agendamento/saúde/jurídico/educacional/cobrança conforme escopo) + bloco 3 (o que o usuário pediu no briefing). Se o usuário disse "nenhuma específica", o campo continua preenchido com bloco 1 + bloco 2 e aviso fora do bloco pedindo revisão.
- [ ] Ajustes recomendados (Modelo, Temperatura, Penalidades, Máx Tokens) com 1 linha de justificativa cada — e Nº de mensagens antes do resumo automático **não** foi recomendado.

## Princípios não-negociáveis

1. **A persona dirige tudo.** Tom, vocabulário, exemplos, gatilhos, restrições — derive da resposta da pergunta 2 do briefing. Se o briefing da persona estiver vago, pare e peça mais detalhe antes de gerar (cap. 9 — antidelírio).
2. **Nome humano sempre.** Nunca "Agente Vendas IA", sempre "Camila", "Rafael", etc.
3. **1 função = 1 ETAPA da conversa, NÃO 1 dado.** Função do NicoChat aceita N parâmetros, então dados que pertencem à mesma etapa/intenção/ação vão JUNTOS como parâmetros da mesma função. Errado: `collect_name`, `collect_email`, `collect_phone` (3 funções). Certo: `collect_contact_info` (1 função, 3 parâmetros). Total típico fica entre **2 e 5 funções** por agente: 1-3 de coleta agrupada + 1-2 executoras finais. Se passou de 5, releia e agrupe. Se ficou abaixo de 2, está faltando executora.
4. **Cada ação executora no mundo = uma função executora.** Se o escopo é "agendar", existe `schedule_*`. Se é "vender/registrar", existe `register_*` ou `create_*`. Se é "encaminhar", existe `handoff_*`. As funções de coleta só preenchem variáveis; quem efetua ação é a executora. Falhar em gerar a executora final = agente conversa sem nunca executar.
4. **Separe QUANDO (agente) de COMO (função).** Não duplique a lógica de coleta dentro do prompt do agente (cap. 3 do ebook).
5. **Delimitadores corretos**: `"..."` para fala literal, `'...'` para resposta curta exata, ` ``...`` ` para nomes de função/parâmetro/processo lógico.
6. **Mapeie retornos.** Toda função deve ter pelo menos `sucesso` e `erro_validacao` mapeados para frases curtas (cap. 7).
7. **Restrições defensivas por padrão.** Toda saída inclui "não inventar dado / não opinar fora do escopo / pedir clarificação se ambíguo" (cap. 9).
8. **Português pt-BR** em tudo que é voltado ao usuário final; nomes de função e parâmetros em inglês snake_case.
9. **Soar humano, nunca robótico.** Todo prompt gerado inclui o bloco NATURALIDADE HUMANA com a proibição explícita de travessão (—), de vícios de IA ("claro!", "com certeza!", "espero ter ajudado", "fico feliz em..."), de fechamentos com resumo, de bullets em conversa curta e de emoji em excesso. Se o estilo for Informal ou Descontraído e o usuário liberou, inclua a permissão controlada de abreviações ("vc", "tbm", "blz") e erros de digitação ocasionais — máximo 1 a cada 3-4 mensagens, nunca em dados críticos (nome, valor, data, endereço).
10. **Estilo escolhido pelo usuário manda.** Formal / Informal / Descontraído / descrição livre — derive o vocabulário, presença de emoji, contrações e permissão de abreviações do que o usuário escolheu no briefing, não do seu default.
11. **Personalidade ≠ Habilidades.** Personalidade e Objetivo da IA é "como o agente SOA" (persona, tom, naturalidade, exemplos de fala). Habilidades é "como o agente AGE" (o que sabe fazer, regras operacionais, QUANDO acionar cada função, COMO reagir aos retornos). Nunca empurre regras de execução ou gatilhos de função para Personalidade — confunde o modelo e estoura o limite de 2.000 caracteres do campo.
12. **Limites de caracteres são lei.** Cada campo tem limite estrito do NicoChat. Conte antes de devolver e mostre a contagem fora do bloco. Estourar = bloco rejeitado/truncado em produção.
13. **Restrições é campo obrigatório, nunca vazio.** Mesmo se o usuário disser "não tem restrição específica", você gera pelo menos os 6 defaults universais + as restrições do tipo de agente (vendas/atendimento/agendamento/saúde/jurídico/etc) inferidas do escopo. Mínimo de 8 itens no campo. Restrições é a principal defesa contra delírio — pular esse campo é o erro mais grave que a skill pode cometer (cap. 9 do ebook).

## Formato final da resposta ao usuário

```
# Agente: {{Nome}}

## Campo: Nome
```text
Camila
```
*6 / 50 caracteres*

## Campo: Descrição
```text
Agente de qualificação de leads de odontologia. Pergunta etapa do funil,
clínica/consultório, faturamento aproximado e principal dor de gestão.
Encaminha para humano quando lead qualifica.
```
*198 / 1.000 caracteres*

## Campo: Personalidade e Objetivo da IA
```text
OBJETIVO
- Você é Camila, consultora comercial da Clínica Sorriso.
- Sua missão: qualificar leads e agendar consultas.

PERSONA DO USUÁRIO
- Pessoas de 25-55 anos buscando tratamento odontológico, com pouca familiaridade técnica.

TOM E ESTILO
- Estilo: Informal, próximo e acolhedor.
- ...

NATURALIDADE HUMANA
- ...

EXEMPLOS DE FALA
- ...
```
*1.847 / 2.000 caracteres*

## Campo: Habilidades
```text
O QUE VOCÊ SABE FAZER
- ...

REGRAS DE EXECUÇÃO
- ...

QUANDO ACIONAR CADA FUNÇÃO
- Quando o usuário disser que tem clínica, execute ``collect_clinic_info``.
- ...

COMO REAGIR AOS RETORNOS DAS FUNÇÕES
- Quando ``collect_clinic_info`` retornar `sucesso`, responda com: 'Anotado!'.
- ...
```
*3.420 / 20.000 caracteres*

## Campo: Informações Sobre Produtos e Serviços

**Variáveis de bot a criar** (NÃO colar no campo):
- `trilhas_disponiveis` (tipo:texto, valor: `trafego, copy, produto_lancamento`) — usada na Lista de Opções da função X.
- `cardapio_json` (tipo:json) — alimenta as descrições por categoria.

**Observação:** o cronograma completo (palestras, salas) fica fora do prompt e é enviado como card pelo sub-fluxo.

```text
EVENTO
- Nome: Hotmart FIRE
- Ativação: ...

ENTREGAS DESTE AGENTE
- ...
```
*1.230 / 20.000 caracteres*

⚠️ Note como o bloco copiável tem APENAS o que entra no campo. As variáveis a criar e a observação ficam FORA, em markdown comum. A contagem `X / Y caracteres` também fica fora do bloco.

(... demais campos do agente, cada um com sua linha de contagem fora do bloco ...)

## Ajustes recomendados
```text
Modelo: OpenAI - Chat Completions / gpt-4.1-mini (ou gpt-4.1)
  Por quê: ...
Temperatura: 0.X
  Por quê: ...
Penalidade de frequência: 0.X
Penalidade de presença: 0.X
Máximo de Tokens: 2000+
Número de mensagens antes do resumo automático: (não recomendado pela skill)
```

---

# Funções

## Função: collect_contact_info

### Campo: Nome
```text
collect_contact_info
```

### Campo: Descrição
```text
...
```

### Campo: Prompt da Função
```text
...
```

### Parâmetros
(tabela)

### Fluxo de Trabalho a Acionar
...

(... próxima função ...)

---

## Checklist final
- [x] ...
- [ ] AJUSTAR: ...
```

Encerre perguntando se o usuário quer ajustar tom/escopo/algum campo antes de partir para a próxima função, ou se quer gerar um Sub-Fluxo (caso alguma função precise).
