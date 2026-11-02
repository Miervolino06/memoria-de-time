---
name: aboutme
description: Entrevista de 20 perguntas, em 5 blocos, que monta pessoas/<slug>/aboutme.md — o papel da pessoa no time, com quem trabalha, onde estão as coisas dela, o que só ela sabe, como é uma boa entrega e o que ela não tolera. Use na primeira sessão de cada pessoa no repositório, quando o hook avisar "ainda sem aboutme", ou quando alguém pedir "me entrevista", "faz o meu aboutme", "atualiza o meu perfil".
---

# /aboutme — a entrevista que ensina o Claude (e o time) a trabalhar com você

O `aboutme` é o perfil que toda sessão carrega quando esta pessoa abre o Claude Code aqui (o hook a
reconhece pelo e-mail do git). Ele também serve ao time: é onde os outros descobrem com quem falar,
onde estão as coisas e o que hoje depende de uma pessoa só.

## Antes de perguntar

1. Descubra quem é: `git config user.name` e `git config user.email`. Sem e-mail configurado, peça o
   e-mail de trabalho e, com o OK da pessoa, rode `git config user.email "<e-mail>"`. O hook depende dele.
2. O slug é o primeiro nome em minúsculas e sem acento (`joão` vira `joao`). Se `pessoas/<slug>/` já
   existir com outro e-mail, acrescente a inicial do sobrenome (`joao-s`).
3. Se o `aboutme` já existir, entre no modo atualização: mostre em cinco linhas o que está lá, pergunte
   o que mudou e refaça só os blocos que mudaram.

## A entrevista

Abra assim, numa mensagem só, e emende o bloco 1:

> São 20 perguntas em 5 blocos, uns 10 minutos. Tudo o que você responder fica visível para o time
> inteiro, então não diga nada que não diria numa reunião. Pode pular qualquer pergunta. Vou salvar em
> `pessoas/<slug>/aboutme.md`.

Faça um bloco por mensagem e espere as respostas. Se uma resposta importante vier vaga ("fica no
Drive"), faça no máximo uma pergunta de seguimento por bloco ("qual pasta?"). Não comente nem elogie
as respostas: siga para o próximo bloco.

**Bloco 1 de 5: papel**
1. Como você prefere ser chamado?
2. Qual é o seu papel, numa frase que alguém de fora da empresa entenderia?
3. Quais são as três tarefas que mais ocupam a sua semana?
4. Que decisões são suas, sem precisar perguntar a ninguém?

**Bloco 2 de 5: com quem**
5. Com quem do time você trabalha mais de perto, e para quê?
6. De que clientes, fornecedores ou parceiros você é o contato?
7. Quando você trava, a quem recorre, e para quê?
8. Quem depende de uma entrega sua para conseguir trabalhar?

**Bloco 3 de 5: onde estão as coisas**
9. Onde ficam os arquivos do seu trabalho: quais pastas do Drive, canais do Teams e sistemas?
10. Que planilhas, modelos ou documentos você usa sempre? Algum só você sabe usar?
11. Que informação você tem e os outros não têm, mas deveriam ter?
12. Que tarefa sua você gostaria que outra pessoa conseguisse fazer sem você?

**Bloco 4 de 5: qualidade**
13. Como é uma entrega excelente no seu trabalho? Dê um exemplo real.
14. O que você sempre confere antes de entregar ou enviar?
15. Que erros você não tolera, seus ou dos outros?
16. O que alguém novo costuma errar na sua área?

**Bloco 5 de 5: como trabalhar com você**
17. Como prefere receber resposta: curta ou detalhada? Em lista, tabela ou texto corrido?
18. Em que horários e por quais canais você prefere ser acionado?
19. O que o Claude deve sempre fazer quando trabalhar com você?
20. E o que ele nunca deve fazer?

## Escrever o arquivo

1. Monte `pessoas/<slug>/aboutme.md` com a estrutura de `pessoas/_modelo.md`, sem o bloco de
   comentário final. No cabeçalho, `email` é o do git e `atualizado` é a data de hoje (AAAA-MM-DD).
2. Escreva na voz da pessoa ("faço", "prefiro"), em tópicos curtos, e preserve o concreto: o nome da
   pasta, da planilha, do cliente, do sistema. Não enfeite e não complete lacunas. Pergunta pulada fica
   como "não respondeu".
3. Fica de fora, mesmo que a pessoa conte: CPF, endereço, telefone pessoal, salário, saúde, família,
   senha. Se ela disser algo assim, avise que não vai para o arquivo.
4. Mostre o arquivo inteiro e pergunte: "Confere? Quer tirar ou corrigir alguma coisa?" Aplique as
   correções.

## Depois

- As respostas 10 a 12 costumam revelar trabalho que depende de uma pessoa só. Para cada item, ofereça
  uma vez: "Quer que eu abra `empresa/processos/<slug>.md` para isso? Pode ser outro dia." Não abra
  sem o sim.
- Proponha o commit: `git add pessoas/<slug>/aboutme.md` com a mensagem `aboutme: <Nome>` e pergunte
  "Posso commitar e enviar para o time?". Com o OK, faça o commit. Se houver remoto, rode
  `git pull --rebase` e depois `git push`. Sem remoto, diga que o commit ficou só nesta máquina.
- Termine com uma linha: "A partir da próxima sessão, o Claude reconhece você pelo e-mail <e-mail> e já
  começa sabendo isto."
