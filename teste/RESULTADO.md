# Resultado do teste de duas pessoas

**Rodada de referência: 01/11/2026, commit `64c1feb`. 22 de 22 checagens passaram.** A Ana encerrou
um trabalho. O Bruno, noutra cópia e noutra sessão, disse só "bom dia, o que eu tenho para hoje?" e
"pode seguir até terminar", e entregou a proposta com o total certo, R$ 34.500,00. O controle negativo
recebeu o mesmo arquivo de proposta, sem a memória e sem o bastão, e chegou a R$ 42.000,00, com a
tabela de preços velha.

**Confirmação: 01/11/2026, commit `d5096ca` (o atual, com as sessões sem conectores). De novo 22 de
22**, com o mesmo contraste: R$ 34.500,00 no Bruno e R$ 42.000,00 no controle.

Todos os números abaixo são do cenário fictício do teste (`teste/cenario/`).

## Ambiente

- Windows 11, Git 2.56 com Git Bash, Claude Code 2.1.308. As sessões de teste rodaram no Sonnet
  (`claude -p --model sonnet`).
- Cada pessoa tem a sua cópia, e as cópias se ligam por um repositório central local (`git clone --bare`).
- As sessões não carregam o `CLAUDE.md` global nem as configurações de usuário de quem roda o teste,
  e não podem escrever em `~/.claude`. A partir do commit `d5096ca`, também rodam sem os conectores
  da conta (ver "O que a rodada de referência ensinou").

## O que cada pessoa recebeu

- **Ana (um prompt):** as anotações de uma call com a Construtora Horizonte. São 30 escoras, a Marta
  é quem decide (não o Paulo, como diz a ficha do cliente), o teto é de R$ 48.000,00, a entrega é até
  20/12/2026 e a proposta tem no máximo 2 páginas. O preço novo é R$ 1.250,00 (a tabela em `empresa/`
  ainda diz R$ 1.400,00), e a decisão é à vista com 8% de desconto. O pedido: fazer só a apresentação
  e o escopo, porque o Bruno fecha amanhã. Depois, `/encerrar-trabalho` e "pode commitar e enviar".
- **Bruno:** "Bom dia! O que eu tenho para hoje?", "Pode seguir até terminar.", `/encerrar-trabalho` e
  "Pode commitar e enviar.". Nenhum dado do trabalho.
- **Controle:** a mesma identidade do Bruno, numa cópia sem remoto. Recebe o arquivo da proposta da
  Ana, como se viesse pelo Drive, e "a Ana começou a proposta (...) e me pediu para terminar".

## Checagens

| Etapa | Checagem | Resultado |
|---|---|---|
| Mecânica | hook reconhece o Bruno pelo e-mail do git | passou |
| Mecânica | hook não vê bastão antes de a Ana trabalhar | passou |
| Mecânica | checador passa na semente | passou |
| Mecânica | dois commits simultâneos no índice se fundem sem conflito | passou |
| Ana | rascunho da proposta criado | passou |
| Ana | o `/encerrar-trabalho` espera o OK antes de commitar | passou |
| Ana | o trabalho chegou ao repositório central | passou |
| Ana | bastão aberto para o Bruno | passou |
| Ana | pelo menos uma memória gravada (foram 4) | passou |
| Ana | checador passa no que ela enviou | passou |
| Bruno | o hook puxou o trabalho da Ana sozinho | passou |
| Bruno | o hook avisou que há bastão para ele | passou |
| Bruno | a primeira resposta já fala do trabalho da Horizonte | passou |
| Bruno | total certo: 30 × R$ 1.250,00 − 8% = R$ 34.500,00 | passou |
| Bruno | usou o preço novo (R$ 1.250,00), não o da tabela | passou |
| Bruno | prazo de entrega de 20/12/2026 | passou |
| Bruno | proposta endereçada à Marta | passou |
| Bruno | nenhuma ferramenta tocou a cópia da Ana | passou |
| Bruno | bastão retomado no repositório central | passou |
| Bruno | checador passa no que ele enviou | passou |
| Controle | só com o arquivo, o total certo não aparece | passou |
| Geral | nenhuma sessão de teste mexeu na configuração global | passou |

## O contraste

| | Bruno (bastão + memória) | Controle (só o arquivo) |
|---|---|---|
| Preço unitário | R$ 1.250,00 | R$ 1.400,00 (tabela de 15/08/2026) |
| Condição | à vista, 8% de desconto | à vista ou 3x sem juros |
| Total | **R$ 34.500,00** | **R$ 42.000,00** |
| Prazo | entrega até 20/12/2026 | "até 30 dias" (não sabia da data) |
| Destinatária | Marta | Marta, mas pedindo para confirmar, porque a ficha cita o Paulo |

O controle não inventou nada: marcou `FALTA` onde não achou dado e pediu para confirmar com a Ana o
que ela combinou na call. Ele só não tinha como saber. É exatamente o problema que o modelo resolve:
a outra pessoa tem o arquivo, mas não tem os mesmos dados. A diferença no total é de R$ 7.500,00, uma
proposta 21,7% mais cara que a combinada (FATO do cenário: 42.000 − 34.500 = 7.500; 7.500 ÷ 34.500).

## Como cada ritual se comportou

- **`/encerrar-trabalho` (Ana):** separou memória de bastão sem ajuda. As 4 memórias foram o preço novo
  e a tabela velha (camada empresa), a Marta decide, a Marta quer 2 páginas e o à vista com 8% (camada
  projeto). Escreveu o bastão com objetivo testável, a conta pronta (30 × 1.250 = 37.500; −8% = 34.500)
  e "o que NÃO foi verificado" (a aprovação do preço só foi relatada, o e-mail não foi lido). Rodou o
  checador, mostrou tudo numa mensagem e esperou o "pode". Não alterou `empresa/` sem OK: propôs a
  alteração.
- **`/passagem-de-bastao` (Bruno):** o "bom dia" já acionou a skill. Ele resumiu em seis tópicos, marcou o
  bastão como `retomado`, avisou "não use os R$ 1.400,00" e perguntou se seguia. Depois escreveu
  Preço, Prazo e Condições, tomou uma decisão reversível (desconto em linha própria, porque a Marta é
  do financeiro), anotou-a no bastão e devolveu o bastão `aberto` com ele mesmo, com o próximo passo
  novo: confirmar o preço com o Carlos e enviar. Não criou memória repetida ("os fatos já estão nas 4
  memórias da Ana").
- **Hook:** puxou o commit da Ana antes do primeiro turno do Bruno, mostrou "1 commit novo do time",
  carregou o perfil dele e marcou o bastão com "PARA VOCÊ".

Os 8 turnos somaram 4,5 minutos de execução (soma do `duration_ms` dos logs).

## O que a rodada de referência ensinou

Houve uma primeira rodada, interrompida, antes da de referência:

1. **O cenário estava ambíguo, e o Claude percebeu.** Na primeira versão, o preço novo vinha de um "e-mail
   do fornecedor". Isso é custo de compra, não preço de venda. O Claude da Ana marcou `FALTA`, não
   calculou o total e perguntou à Ana. O "não suponha" funcionou. O cenário passou a dizer que o
   preço foi aprovado pelo diretor comercial.
2. **No Windows, sem o Git Bash, as permissões de `Bash(...)` não valem.** Com o Git instalado fora da
   pasta padrão, o Claude Code não achou o Git Bash e rodou hooks e comandos na ferramenta PowerShell. O
   `git add` da Ana pediu aprovação e o commit não saiu. O Claude explicou que nada tinha ido para o
   time e passou os comandos. Correção: o `settings.json` ganhou as mesmas regras para `PowerShell(...)`,
   o README explica o `CLAUDE_CODE_GIT_BASH_PATH` e o teste aponta o Git Bash. O hook funcionou nos
   dois casos, porque é chamado com caminho relativo.
3. **Sem o push da Ana, o Bruno ouviu "não há nada para você hoje".** Foi um controle negativo sem querer:
   o Claude dele conferiu os bastões, `trabalho/` e o `git log`, e pediu os dados em vez de inventar.
4. **Na rodada de referência, o Bruno tentou o Gmail de verdade.** Para conferir o e-mail do preço, o
   Claude dele chamou o conector do Gmail da conta de quem rodava o teste. A permissão negou e nenhum
   e-mail foi lido. Para o produto é o comportamento certo (conferir o que não foi verificado). Para o
   teste, não: desde o commit `d5096ca` as sessões rodam com `--strict-mcp-config`, sem conector nenhum.

## Teste à parte: a entrevista `/aboutme` (9 de 9)

Uma pessoa fictícia (Carla, do financeiro) respondeu os 5 blocos, um por turno, e no bloco 1 ofereceu o
CPF "se precisar para algum cadastro". A skill abriu com o aviso de privacidade e só o bloco 1. Recusou
o CPF com a explicação. Preservou o concreto (`Fluxo_Caixa_2026.xlsx`, o escritório de contabilidade,
"fechar até o dia 5"). Mostrou o rascunho antes do commit e ofereceu abrir em `empresa/processos/` as 3
tarefas que só a Carla sabe fazer. O hook passou a reconhecê-la e a carregar o perfil. Esse roteiro rodou
fora do repositório: ainda não é um script em `teste/`.

## O que NÃO foi verificado

- **Uso interativo.** O teste roda em modo `-p`. Nesse modo, as permissões do `.claude/settings.json` são
  ignoradas enquanto a pasta não é confiável, e por isso o teste libera o git pela linha de comando. As
  regras do modelo (o que roda sem pedir e o que é negado) foram conferidas à parte, passadas por
  `--settings`: `git status`, o checador e `git commit` rodaram sem pedir, e `git clean -n` e
  `git reset HEAD --hard` foram negados.
- **Remoto de verdade.** Só repositório local. GitHub, GitLab ou Azure DevOps com login não foram testados.
- **macOS e Linux.** Só Windows 11 com bash 5. Os scripts evitam recursos do bash 4+, mas não rodaram no
  bash 3.2 do macOS.
- **Outros modelos.** Só Sonnet nas sessões de teste.
- **Conector do Drive ou do Teams.** Fora do modelo.
- **Escala.** Duas pessoas e uma dúzia de arquivos. A fusão do índice foi provada com dois commits
  simultâneos, não com um time inteiro ao longo de meses.
