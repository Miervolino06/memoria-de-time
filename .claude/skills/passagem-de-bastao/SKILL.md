---
name: passagem-de-bastao
description: Passa um trabalho para outra pessoa ou retoma um trabalho que alguém deixou. O bastão é um arquivo em handoffs/ com objetivo, estado, próximo passo, decisões, dados, acessos e o que não foi verificado. Use quando a pessoa disser "passa para o <nome>", "vou sair, o <nome> continua", "continua o que a <nome> deixou", "retoma", "o que tenho para hoje?", "o que ficou pendente?", ou quando o hook mostrar um bastão aberto para ela.
---

# /passagem-de-bastao — entregar e receber trabalho sem perder o contexto

Há dois sentidos. Descubra qual pela frase: "passa", "vou sair" e "deixa para" querem dizer
**passar**; "continua", "retoma", "o que tenho" e "pendente" querem dizer **retomar**. Se a frase não
disser e houver bastão aberto para a pessoa, é retomar. Se ainda assim não estiver claro, pergunte.

## Passar

1. **Para quem:** ache a pessoa em `pessoas/` e leia o `aboutme` dela. Isso mostra o que ela já
   conhece, como prefere receber as coisas e a que pastas e sistemas tem acesso. Sem pessoa definida,
   o bastão vai `para: time`.
2. **Faça os passos 1 a 5 do `/encerrar-trabalho`** (`.claude/skills/encerrar-trabalho/SKILL.md`),
   com o bastão endereçado a essa pessoa. Aqui o teste do estranho não é opcional: liste para si as
   perguntas que ela faria e responda cada uma no bastão. Os dados que estão só na conversa vão para
   "Dados que quem recebe precisa", com fonte.
3. **Acessos:** em "Arquivos e acessos", diga a que pasta, canal ou sistema a pessoa precisa ter acesso
   e quem libera. Senha nunca entra.
4. **Passos 6 e 7 do `/encerrar-trabalho`:** proponha o commit, espere o OK, commite e envie.
5. **Aviso:** entregue um texto curto para a pessoa mandar a quem recebe, por exemplo: "<Nome>, deixei
   o bastão de <trabalho> no repositório do time. Abra o Claude Code na pasta e diga 'retoma o bastão
   de <quem passa>'." Quem envia é a pessoa, não você.

## Retomar

1. **Achar o bastão:** liste os `handoffs/*.md` com `status: aberto`. Primeiro os de `para: <você>`,
   depois os de `para: time`, filtrando por `de:` se a pessoa citou alguém. Se houver mais de um,
   liste e pergunte qual. Se não houver nenhum, diga isso, mostre o `git log -5 --format='%an: %s'`
   (talvez quem passou ainda não tenha enviado) e sugira perguntar a ela.
2. **Ler tudo antes de falar:** o bastão inteiro, cada memória citada nele, a pasta
   `memoria/projetos/<projeto>/`, o `empresa/clientes/<projeto>.md` (se existir) e os arquivos de
   trabalho citados. Veja também se alguém mexeu depois:
   `git log --since=<data do bastão> --format='%an, %ad: %s' -- <arquivos citados>`.
3. **Conferir:** os arquivos citados existem? Em "O que NÃO foi verificado", confira o que for barato
   (uma conta, um arquivo) e sinalize o resto. Se o bastão ou a memória discordarem de um documento de
   `empresa/`, vale o mais recente que tiver fonte. Diga qual dos dois você usou.
4. **Situar a pessoa em até seis linhas:** objetivo, onde parou, próximo passo, decisões que valem,
   dados-chave e o que falta ou é risco. Não pergunte o que já está escrito. Marque o bastão como
   `status: retomado` e acrescente `retomado_por: <você>` e `retomado_em: AAAA-MM-DD`.
5. **Seguir:** se a pessoa já pediu para continuar, siga pelo "Próximo passo". Senão, pergunte uma vez
   "Sigo pelo próximo passo?". Aplique as decisões e os dados do bastão e das memórias sem pedir de
   novo. Se faltar algo essencial que não está escrito em lugar nenhum, não suponha: escreva
   `FALTA: <o quê>` no arquivo de trabalho, avance no que der e prepare a pergunta para quem passou
   (`de:`).
6. **Melhorar o próximo bastão:** se faltou algo, registre uma memória em `memoria/empresa/` (tipo
   `aprendizado`), por exemplo "bastão de evento precisa trazer o número de convidados confirmado". É
   assim que o formato melhora com o uso.
7. **Ao terminar a sessão:** `/encerrar-trabalho`. Ele fecha o bastão (`concluido`) ou o passa adiante.
