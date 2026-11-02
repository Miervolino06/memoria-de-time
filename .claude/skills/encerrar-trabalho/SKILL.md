---
name: encerrar-trabalho
description: Ritual de fim de trabalho. Grava em memoria/ o que se aprendeu e decidiu (um fato por arquivo, na camada certa, com fonte), escreve ou atualiza o bastão em handoffs/ se algo ficou pela metade, roda o checador e propõe o commit para o time. Use quando a pessoa disser "encerra", "fecha por hoje", "terminei", "salva o que aprendemos", ao fim de uma sessão que produziu decisão, aprendizado ou dado novo, e sempre que o trabalho for continuar outro dia ou com outra pessoa.
---

# /encerrar-trabalho — o que esta sessão sabe passa a ser do time

O que não for escrito aqui morre com a conversa. Isso vale sobretudo para o que a pessoa contou no
chat e não está em nenhum arquivo: número, nome, prazo, preferência do cliente, a decisão e o porquê
dela. O objetivo é que outra pessoa (ou a mesma, amanhã) continue sem perguntar nada.

## 1. Levantar

Releia a conversa e rode `git status --short` e `git diff --stat`. Separe:

- **Entregas:** arquivos criados ou alterados nesta sessão.
- **Decisões:** o que foi escolhido, por quê e com base em quê.
- **Aprendizados:** o que, se esquecido, faria alguém errar ou refazer trabalho. Inclui exceção a um
  documento (o preço mudou e a tabela ainda não).
- **Dados que só estão na conversa:** números, nomes, datas, contatos, condições.
- **Pendências:** o que falta para o trabalho ficar pronto.

## 2. Separar o que vai para onde

| É… | Vai para |
|---|---|
| Fato que vale além deste trabalho (regra, preferência de cliente, exceção a documento, lição) | `memoria/` |
| Estado deste trabalho (próximo passo, o que falta, dados para terminar) | o bastão, em `handoffs/` |
| Passo a passo do que foi feito | nada, porque o `git log` já guarda |
| Senha, token, dado pessoal sensível | nada, nunca |

Antes de criar uma memória, procure se o assunto já existe: `memoria/INDICE.md` e a pasta da camada.
Se existir, atualize aquele arquivo (e acrescente `atualizado: AAAA-MM-DD` no cabeçalho). Se o fato
desmente um documento de `empresa/` (preço, contato, processo), registre a memória e inclua na
proposta do passo 6 "atualizar `empresa/...`". Só altere o documento com o OK da pessoa.

## 3. Escrever as memórias

- Um fato por arquivo, no formato de `memoria/_modelo.md` (sem o bloco de comentário final).
- A camada é a pasta: `memoria/empresa/` vale para qualquer trabalho; `memoria/projetos/<slug>/` vale
  para um cliente ou projeto (mesmo slug de `empresa/clientes/`); `memoria/pessoas/<slug>/` registra
  como trabalhar com alguém, e só com o OK dessa pessoa.
- O nome do arquivo é o assunto em slug: minúsculas, sem acento, com hífen.
- `fonte` diz de onde veio o fato: o e-mail com data, a reunião com quem e quando, o arquivo. "Conversa
  com <pessoa> em dd/mm/aaaa" vale quando foi ela quem contou.
- Cada memória ganha uma linha em `memoria/INDICE.md`, na seção da camada:
  `- [Título curto](projetos/<slug>/<arquivo>.md) — a lição em uma frase (autor, dd/mm/aaaa)`.

## 4. Escrever o bastão (se algo ficou pela metade)

- Se esta sessão retomou um bastão, atualize **o mesmo arquivo**. Terminou: `status: concluido`,
  `concluido_em: AAAA-MM-DD` e uma linha com o resultado em "Onde está". Não terminou: atualize as
  seções, ajuste o `para:` e volte o status para `aberto`.
- Senão, crie `handoffs/AAAA-MM-DD_<projeto>_<de>-para-<para>.md` a partir de `handoffs/_modelo.md`.
  `para` é quem continua: o slug da pessoa citada na conversa, o próprio slug se for a mesma pessoa
  amanhã, ou `time`.
- Faça o **teste do estranho** antes de seguir: releia o bastão como se você fosse quem recebe, sem
  acesso a esta conversa. Para cada pergunta que essa pessoa precisaria fazer, escreva a resposta no
  bastão ou numa memória ligada a ele. Todo número, nome, data ou condição necessário para o próximo
  passo precisa estar escrito, com fonte. O que você não sabe vira `FALTA:` (e pergunte agora à
  pessoa, se ela souber).

## 5. Checar

Rode `bash scripts/checar-memoria.sh` e corrija até sair `OK`. Aviso de senha anotada se resolve
trocando a senha por "pedir acesso a <pessoa>".

## 6. Propor o commit (e esperar o OK)

Mostre numa mensagem só:

```
Vou registrar:
- Memória (<camada>): <resumo> → memoria/...
- Bastão para <pessoa>: <título>. Próximo passo: <...> → handoffs/...
- Arquivos de trabalho: <...>
- (se houver) Atualizar empresa/...: <o quê>
Commit: "encerrar: <trabalho> — <n> memória(s), bastão para <pessoa>"
Posso commitar e enviar para o time?
```

Se a pessoa pedir mudança, ajuste e mostre de novo. Sem OK, nada de commit.

## 7. Commitar e enviar

1. `git add` com a lista explícita dos arquivos da proposta. Nada de `git add -A`, que leva arquivo
   pessoal ou alheio junto.
2. `git commit -m "<mensagem>"`.
3. Se houver remoto (`git rev-parse --abbrev-ref @{u}` responde), rode `git pull --rebase` e depois
   `git push`. Conflito no índice se resolve sozinho (o índice funde as duas versões). Em qualquer
   outro arquivo, mostre o conflito à pessoa e resolvam juntos, sem descartar a mudança de ninguém.
   Push recusado: `git pull --rebase` e mais uma tentativa. Se falhar de novo, explique.
4. Sem remoto: diga que o commit ficou só nesta máquina e que o README explica como ligar o time.

Feche com uma linha: o que foi para o time (commit `<hash curto>`) e, se houver bastão, um aviso
pronto para a pessoa colar no Teams. Por exemplo: "<Pessoa>, deixei o bastão de <trabalho> no
repositório. É só abrir o Claude Code na pasta e pedir para retomar." Quem envia é a pessoa, não você.
