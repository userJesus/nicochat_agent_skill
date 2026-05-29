# nicochat-prompt — skill para gerar agentes de IA do NicoChat

Skill que pega um briefing curto e devolve todos os campos prontos para colar nos formulários **Adicionar agente de IA** e **Adicionar função de IA** do [NicoChat](https://app.nicochat.com), seguindo o ebook interno de engenharia de prompt.

Para cada dado que o agente precisa coletar, ela gera uma função separada com parâmetros, mapeamento de retorno e roteiro do sub-fluxo. Todo prompt sai com regras anti-robô (sem travessão, sem "claro!", "espero ter ajudado", etc) e com opção de usar abreviações ("vc", "tbm") e errinhos de digitação como um humano faria.

## O que a skill gera

**Agente:** Nome (humano), Descrição, Personalidade e Objetivo, Habilidades, Restrições, Informações Sobre Produtos e Serviços, e Ajustes (modelo, temperatura, penalidades, máx tokens).

**Cada função:** Nome em inglês, Descrição, Prompt da Função com mapeamento de RETORNOS, Parâmetros (com regras de Lista de Opções e tipo de variável), e roteiro do sub-fluxo (bloco "Resultado da função AI" + retorno por ramo).

---

## Como instalar

Existem dois ambientes onde a skill pode rodar: **Claude normal** (claude.ai / app Claude) e **Claude Code** (CLI, app desktop do Code, extensão do VS Code).

Em cada um, você tem duas opções: pedir ao Claude para instalar **automaticamente**, ou fazer **manualmente** colando os comandos.

---

### Claude normal (claude.ai / app Claude)

A skill vira parte de um **Project** — daí toda conversa dentro desse Project já sabe o protocolo.

#### Automático (mais rápido, vale por uma conversa)

Abra uma conversa nova no claude.ai e cole:

```
Baixa o arquivo daqui:
https://raw.githubusercontent.com/userJesus/nicochat_agent_skill/main/SKILL.md

Lê tudo, e a partir de agora, sempre que eu pedir pra criar um agente
ou função de IA do NicoChat, segue exatamente esse protocolo.
```

Pronto. Funciona só nessa conversa — em uma nova você precisa repetir.

#### Manual (vale pra sempre, dentro de um Project)

1. Acesse https://github.com/userJesus/nicochat_agent_skill/blob/main/SKILL.md
2. Clique em **Raw** e copie tudo (Ctrl+A, Ctrl+C).
3. No claude.ai, crie um **Project** chamado "NicoChat — agentes".
4. Abra **Project knowledge** (ou "Custom instructions", depende da versão).
5. Cole o conteúdo. Salve.

Agora toda conversa dentro desse Project usa a skill automaticamente. É só dizer "cria um agente de IA pra X" e ela puxa o briefing.

---

### Claude Code (CLI, app Desktop, extensão do VS Code)

Os três usam a mesma pasta de skills: `~/.claude/skills/`. Instalou em um, aparece em todos.

#### Automático

Abra o Claude Code (em qualquer um dos três) e cole:

```
Instala essa skill aqui:
https://github.com/userJesus/nicochat_agent_skill

Clone em ~/.claude/skills/nicochat-prompt (no Windows é
%USERPROFILE%\.claude\skills\nicochat-prompt).
```

O Claude clona, confirma e a skill já aparece. Pode ser que peça pra reiniciar a sessão.

#### Manual

Cole no terminal:

**macOS / Linux:**

```bash
git clone https://github.com/userJesus/nicochat_agent_skill.git ~/.claude/skills/nicochat-prompt
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/userJesus/nicochat_agent_skill.git "$env:USERPROFILE\.claude\skills\nicochat-prompt"
```

**Windows (CMD):**

```cmd
git clone https://github.com/userJesus/nicochat_agent_skill.git "%USERPROFILE%\.claude\skills\nicochat-prompt"
```

Reinicie o Claude Code. Confirme digitando `/` no chat — `nicochat-prompt` aparece na lista.

---

## Atualizar quando o repo mudar

### Opção A — Auto-update silencioso (recomendado, Claude Code)

Com um hook `SessionStart`, o Claude Code roda `git pull` na pasta da skill toda vez que você abre uma sessão. Se sua working tree estiver suja (edições locais não commitadas), o hook aborta para nunca causar conflito.

**Instalação automática:** cole no Claude Code:

```
Ativa o auto-update da skill nicochat-prompt: adiciona um hook SessionStart
no meu ~/.claude/settings.json que chame
~/.claude/skills/nicochat-prompt/scripts/auto-update.ps1 (Windows) ou
auto-update.sh (macOS/Linux).
```

**Instalação manual:** abra `~/.claude/settings.json` e adicione (ou complete) o bloco `"hooks"`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"%USERPROFILE%\\.claude\\skills\\nicochat-prompt\\scripts\\auto-update.ps1\""
          }
        ]
      }
    ]
  }
}
```

Para **macOS / Linux**, troque o `command` por:

```
"command": "bash $HOME/.claude/skills/nicochat-prompt/scripts/auto-update.sh"
```

(no Linux/macOS o script já vem executável; se não, rode `chmod +x ~/.claude/skills/nicochat-prompt/scripts/auto-update.sh` uma vez).

Custo: ~200-500ms no início de cada sessão. Silencioso se não houver mudança no GitHub; pull rápido se houver.

### Opção B — Sob demanda

**No Claude Code:**

```
atualiza a skill nicochat-prompt
```

Manual:

```bash
cd ~/.claude/skills/nicochat-prompt && git pull
```

### No Claude normal (claude.ai)

Sem automação possível — Projects são conteúdo estático. Sempre que o repo mudar, copie de novo o `SKILL.md` no Project knowledge.

---

## Como usar

Em qualquer ambiente, depois de instalada:

1. Diga algo como **"cria um agente de IA do NicoChat pra qualificar lead de odontologia"**.
2. Responda às 4-5 perguntas de briefing (escopo, persona, estilo, dados a coletar, restrições).
3. Receba todos os campos do formulário em blocos prontos pra copiar.
4. Cole no NicoChat. Pra funções com retorno mapeado, siga o roteiro do sub-fluxo (cria o sub-fluxo, adiciona o bloco "Resultado da função AI", devolve o status em cada ramo).

---

## Princípios da skill

1. Pergunta antes de gerar. Sem briefing, não há saída.
2. Persona-alvo manda em tudo: tom, vocabulário, exemplos.
3. Cada dado a coletar vira uma função separada.
4. Separa **QUANDO** (no agente) de **COMO** (na função).
5. Soa humano: sem travessão, sem vícios de IA, abreviações opcionais.
6. JSON só pra estrutura complexa (cardápio, horários, procedimentos). Dado simples fica em texto.
7. Lista de Opções sempre numa linha, separada por vírgula.

---

## Estrutura

```
nicochat_agent_skill/
├── README.md
├── SKILL.md                    # a skill — frontmatter + protocolo completo
└── scripts/
    ├── auto-update.ps1         # Windows — chamado pelo hook SessionStart
    └── auto-update.sh          # macOS/Linux — chamado pelo hook SessionStart
```

---

## Licença

Uso interno / educacional. Baseado no ebook "Engenharia de Prompt — boas práticas para agentes de IA" (NicoChat).
