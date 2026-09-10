# A.R.I.A. Lua V1
Adaptive Runtime Intelligence Assistant

Framework em Lua para um assistente conversacional dentro de um jogo que você controla/modifica.

## Estrutura

- `aria/core.lua` — núcleo, memória, ferramentas e processamento.
- `aria/tools.lua` — ferramentas de jogo.
- `aria/parser.lua` — interpretação de comandos em português.
- `aria/ai.lua` — adaptador de IA externo/local.
- `game/adapter.lua` — camada que você liga à API do seu jogo.
- `main.lua` — exemplo completo.

## O que já existe

- Conversa normal.
- Memória de curto prazo.
- Memória persistente em tabela (serialização fica a cargo do host).
- Registro de ferramentas sem `if` gigante.
- Lista de jogadores próximos.
- Busca de player por nome.
- Navegação até player.
- Waypoint.
- Destaque de um player específico.
- Informações de player.
- Posição do jogador.
- Estado extensível.
- Eventos simples.
- Fallback para provedor de IA.
- Proteção básica contra ferramenta inexistente/erro.

## Importante

`game/adapter.lua` é propositalmente genérico. Lua não possui uma API universal para "pegar players" ou "mover personagem". Você deve implementar esses métodos usando a API legítima do seu jogo/mod.

A.R.I.A. não depende de funções fictícias do jogo.
