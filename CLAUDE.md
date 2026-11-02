# Memória do time

Este repositório é a memória compartilhada do time no Claude Code. Quem abre uma sessão aqui parte
dos mesmos dados que o resto do time: o que a empresa é, quem é quem, o que já se aprendeu e o que
ficou pela metade. O índice abaixo é carregado sempre. O resto só se lê quando a tarefa pede.

@memoria/INDICE.md

## Ao começar

- O hook de início atualiza a cópia (`git pull`) e mostra o bloco "Memória do time", com a pessoa,
  as novidades e os bastões abertos. Se o bloco não aparecer, ou vier com aviso de falha, rode
  `git pull` antes de trabalhar. Se não der, avise a pessoa.
- Se houver bastão aberto para a pessoa, ofereça retomar com `/passagem-de-bastao`.
- Se a pessoa ainda não tiver `aboutme`, ofereça `/aboutme` (uns 10 minutos) uma vez, sem insistir.

## Onde está cada coisa

| Preciso de… | Leia |
|---|---|
| O que a empresa faz, metas, números | `empresa/empresa.md` |
| Um cliente ou projeto | `empresa/clientes/<slug>.md` e `memoria/projetos/<slug>/` |
| Produto, serviço, preço | `empresa/produtos/` |
| Como se faz uma tarefa que se repete | `empresa/processos/` ou a skill dela em `.claude/skills/` |
| Sigla ou termo da casa | `empresa/glossario.md` |
| Como cada pessoa trabalha | `pessoas/<slug>/aboutme.md` |
| Trabalho que alguém deixou pela metade | `handoffs/` (os que estão com `status: aberto`) |
| Rascunho de um trabalho em andamento | `trabalho/<projeto>/` (o definitivo vai para o Drive ou o Teams) |

Quando a memória e um documento discordarem, vale o mais recente que tiver fonte. Diga à pessoa qual
dos dois você usou.

## Regras

- Não suponha. O que não está aqui nem na fonte vira pergunta, ou `FALTA: <o quê> (procurei em …)`.
- Todo número ou fato da empresa cita a fonte: arquivo, link do Drive ou do Teams, e-mail com data.
- Documento grande fica no Drive ou no Teams. Aqui entram o resumo de uma página e o link.
- Nunca grave senha, token, CPF, salário, dado de saúde ou outro dado pessoal sensível, nem dado de
  cliente sob sigilo.
- Não faça commit nem push sem o OK da pessoa. Nunca force push e nunca reescreva o histórico.
- Não reorganize pastas nem reescreva o texto de outra pessoa sem pedir: faça a mudança mínima.

## Ao terminar

Trabalho que gerou decisão, aprendizado ou ficou pela metade termina com `/encerrar-trabalho`
(memória + bastão + commit proposto). Para entregar o trabalho a alguém, use `/passagem-de-bastao`.
