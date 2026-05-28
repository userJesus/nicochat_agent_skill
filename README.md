# nicochat-prompt — skill para gerar agentes de IA do NicoChat

Skill do **Claude** (Claude Code / Claude Desktop / Claude Code web) que, a partir de um briefing curto, devolve todos os campos prontos para colar nos formulários **"Adicionar agente de IA"** e **"Adicionar função de IA"** do [NicoChat](https://app.nicochat.com), seguindo o ebook interno de engenharia de prompt.

Para cada dado que o agente precisa coletar do usuário, a skill gera uma função separada com parâmetros, mapeamento de retorno e o roteiro do sub-fluxo correspondente. Todo prompt gerado inclui regras de naturalidade humana (sem travessões, sem vícios típicos de IA, com permissão controlada de abreviações se o estilo for informal).

## O que a skill gera

**Para o agente:**
- Nome (humano), Descrição
- Personalidade e Objetivo da IA (estruturado: OBJETIVO, PERSONA, TOM, REGRAS, NATURALIDADE HUMANA, EXECUÇÃO DE FUNCTIONS)
- Habilidades, Restrições
- Informações Sobre Produtos e Serviços (texto, YAML ou recomendação de variável)
- Ajustes recomendados: modelo (`gpt-4.1-mini` ou `gpt-4.1`), temperatura, penalidades, máx tokens

**Para cada função:**
- Nome (em inglês, snake_case), Descrição
- Prompt da Função com mapeamento de RETORNOS
- Parâmetros (com regras de Lista de Opções, tipo de variável, Memória, Obrigatório)
- Fluxo de Trabalho a Acionar + roteiro completo do sub-fluxo (com bloco "Resultado da função AI" e retorno por ramo)

## Princípios da skill

1. Briefing primeiro — 4-5 perguntas antes de gerar qualquer coisa.
2. Persona-alvo dirige tudo (tom, vocabulário, exemplos).
3. Cada dado a coletar = uma função separada.
4. Separa QUANDO (agente) de COMO (função).
5. Soa humano: sem travessão (—), sem "claro!", sem "espero ter ajudado", sem fechamento com resumo. Abreviações ("vc", "tbm") e errinhos de digitação são opcionais e configuráveis no briefing.
6. JSON só para estruturas complexas (cardápio, horários, procedimentos). Dados simples ficam em texto/número.
7. Lista de Opções sempre em uma linha, separada por vírgula. Se for variável: variável única do tipo texto com o mesmo formato.

---

## Instalação

A skill é uma pasta com um único arquivo `SKILL.md`. O Claude descobre skills automaticamente em pastas específicas, então **"instalar"** = colocar essa pasta no lugar certo.

Existem duas formas para cada cliente: **automática** (você pede ao Claude e ele faz) e **manual** (você mesmo executa os comandos).

### 1. Claude Code (CLI / Desktop) — Windows, macOS, Linux

Skills globais vivem em `~/.claude/skills/<nome-da-skill>/SKILL.md`. Funciona igual no CLI e no app desktop.

#### Automática (pedindo ao Claude)

Abra o Claude Code e cole:

```
Instale a skill nicochat-prompt deste repositório no meu Claude:
https://github.com/userJesus/nicochat_agent_skill

Clone o repo em ~/.claude/skills/nicochat-prompt (no Windows:
C:\Users\<MEU_USUARIO>\.claude\skills\nicochat-prompt). Se a pasta já
existir, atualize com git pull.
```

O Claude vai executar os comandos. Depois reinicie a sessão (no CLI, basta abrir uma nova; no Desktop, feche e abra de novo).

#### Manual

**macOS / Linux:**

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/userJesus/nicochat_agent_skill.git ~/.claude/skills/nicochat-prompt
```

**Windows (PowerShell):**

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
git clone https://github.com/userJesus/nicochat_agent_skill.git "$env:USERPROFILE\.claude\skills\nicochat-prompt"
```

**Windows (CMD):**

```cmd
mkdir "%USERPROFILE%\.claude\skills" 2>nul
git clone https://github.com/userJesus/nicochat_agent_skill.git "%USERPROFILE%\.claude\skills\nicochat-prompt"
```

Reinicie o Claude Code. Confirme com `/skills` (a skill `nicochat-prompt` deve aparecer na lista).

#### Atualizar depois

```bash
cd ~/.claude/skills/nicochat-prompt && git pull
```

### 2. Extensão do Claude Code no VS Code

A extensão **Claude Code** do VS Code usa o mesmo diretório `~/.claude/skills/` do CLI. Se você já instalou pelo método acima, a skill aparece automaticamente na extensão.

#### Automática (pedindo ao Claude dentro do VS Code)

Abra o painel do Claude Code no VS Code e cole:

```
Instale a skill nicochat-prompt:
https://github.com/userJesus/nicochat_agent_skill

Clone em ~/.claude/skills/nicochat-prompt e me confirme quando estiver
disponível.
```

#### Manual

Mesmo procedimento da seção anterior (CLI). A extensão lê do mesmo lugar.

Para verificar dentro do VS Code: abra um chat do Claude Code e digite `/` — `nicochat-prompt` deve aparecer na lista de skills.

#### Skill por projeto (alternativa)

Se quiser a skill disponível **apenas em um projeto específico** (versionada com o repo desse projeto), em vez de globalmente:

```bash
cd <seu-projeto>
mkdir -p .claude/skills
git clone https://github.com/userJesus/nicochat_agent_skill.git .claude/skills/nicochat-prompt
```

Adicione `.claude/skills/nicochat-prompt` ao `.gitignore` do projeto se não quiser commitar, ou commit normalmente se quiser que o time inteiro tenha a skill.

### 3. Claude Code Web (claude.ai/code)

A versão web não permite escrever no filesystem local do seu computador — ela roda em ambiente isolado. Tem dois caminhos:

#### Automática (skill por sessão, mais simples)

No início da conversa, cole:

```
Para esta conversa, use como skill o conteúdo de:
https://raw.githubusercontent.com/userJesus/nicochat_agent_skill/main/SKILL.md

Carregue o arquivo, leia as instruções dele e, daqui pra frente, sempre
que eu pedir para criar um agente ou função de IA do NicoChat, siga
exatamente esse processo (briefing → geração de campos → checklist).
```

O Claude vai baixar via `WebFetch`, ler e seguir o protocolo da skill na conversa atual. Você precisa repetir isso a cada nova sessão — é o jeito mais rápido para uso pontual.

#### Manual (skill persistente via "Custom Instructions" ou "Project")

Se você usa **Projects** no claude.ai (ou Custom Instructions):

1. Crie um Project chamado "NicoChat — agentes".
2. Em "Project knowledge" / "Custom instructions", cole o conteúdo de [`SKILL.md`](./SKILL.md) deste repositório (copie tudo).
3. Salve. Toda conversa dentro do project vai usar a skill automaticamente.

#### Conectando o repo (se a sua conta tiver integração GitHub)

Se a sua versão do Claude permite conectar repositórios:

1. Conecte `userJesus/nicochat_agent_skill`.
2. Mande: "Use a skill definida em `SKILL.md` deste repo conectado."

---

## Uso

Em qualquer um dos clientes, depois de instalada:

1. Diga algo como **"cria um agente de IA do NicoChat para qualificar leads de odontologia"** — a skill é acionada automaticamente.
2. Responda às 4-5 perguntas de briefing (escopo, persona, estilo de comunicação, dados a coletar, restrições).
3. Receba todos os campos prontos em blocos copiáveis, separados por campo do formulário.
4. Cole no NicoChat na ordem indicada. Para funções com retorno mapeado, siga o roteiro do sub-fluxo (cria sub-fluxo, adiciona bloco "Resultado da função AI", devolve status em cada ramo).

---

## Estrutura do repositório

```
nicochat_agent_skill/
├── README.md     # este arquivo
└── SKILL.md      # a skill propriamente dita — frontmatter + protocolo completo
```

A pasta do skill, quando instalada, fica em `~/.claude/skills/nicochat-prompt/` (e o Claude lê `SKILL.md` dela).

---

## Atualização

Sempre que houver mudança no `SKILL.md`:

```bash
cd ~/.claude/skills/nicochat-prompt
git pull
```

Ou peça ao Claude: **"atualize a skill nicochat-prompt"**.

---

## Contribuição / ajustes

Este repo é a fonte oficial da skill. Se você usa em produção e quer ajustar regras (tom, modelos default, tabelas de temperatura, etc), edite `SKILL.md` direto na sua cópia local — `git pull` futuros vão pedir merge se houver conflito.

---

## Licença

Uso interno / educacional. Baseado no ebook "Engenharia de Prompt — boas práticas para agentes de IA" (NicoChat).
