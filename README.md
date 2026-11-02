# Memória de time para o Claude Code

Um modelo de repositório para o time inteiro trabalhar com o Claude Code a partir dos mesmos dados.
Uma pessoa faz um trabalho, o Claude grava o que se aprendeu e o que ficou pela metade, e a próxima
pessoa que abrir o Claude Code continua de onde a primeira parou, sem precisar perguntar nada.

## O problema

Num time que usa o Claude, o trabalho que dá certo fica preso na conversa de quem fez. O número que o
cliente passou na reunião, o preço que mudou e a tabela ainda não mostra, a decisão e o porquê dela:
tudo isso some quando a sessão fecha. Aí alguém tenta repetir o trabalho e não consegue, porque não
tem os mesmos dados. Juntar os arquivos no Drive não resolve, porque o que falta não está nos
arquivos. Está no contexto.

## A ideia

A memória do time vive em arquivos de texto num repositório Git que todo mundo clona. Toda sessão do
Claude Code aberta na pasta lê esses arquivos. Três rituais, em forma de skill, mantêm a memória viva:

- **`/aboutme`** é uma entrevista de 20 perguntas que ensina o Claude (e o time) a trabalhar com cada
  pessoa;
- **`/encerrar-trabalho`** grava as decisões, os aprendizados e o que ficou pela metade, e propõe o
  commit;
- **`/passagem-de-bastao`** entrega um trabalho para alguém ou retoma o que alguém deixou.

Um hook de início de sessão roda `git pull` sozinho e conta ao Claude quem está falando, o que mudou
e quais trabalhos estão esperando alguém.

## Como funciona no dia a dia

```
 Ana abre o Claude Code na pasta
   └─ hook: git pull + "você é a Ana" + novidades + bastões abertos
 Ana trabalha (o Claude lê empresa/, memoria/ e pessoas/ quando precisa)
 Ana: "/encerrar-trabalho"
   └─ memória (um fato por arquivo) + bastão para o Bruno + checador → "posso commitar?" → push

 Bruno abre o Claude Code na mesma pasta, na máquina dele
   └─ hook: git pull (chega o trabalho da Ana) + "bastão aberto PARA VOCÊ"
 Bruno: "bom dia, o que tenho para hoje?"
   └─ o Claude lê o bastão e as memórias, resume em seis linhas e continua o trabalho
```

## O que tem aqui

```
CLAUDE.md                  roteador curto: regras e onde está cada coisa (carregado em toda sessão)
empresa/                   referência estável, escrita com calma
  empresa.md               o que a empresa faz, como ganha dinheiro, metas (uma página)
  clientes/                uma página por cliente
  produtos/                o que se vende, preço com fonte e data
  processos/               como se faz o que se repete
  glossario.md             siglas e termos da casa
pessoas/<slug>/aboutme.md  como trabalhar com cada pessoa (gerado pelo /aboutme)
memoria/                   o que se aprendeu e decidiu, um fato por arquivo
  INDICE.md                uma linha por memória (carregado em toda sessão)
  empresa/                 camada 1: vale para qualquer trabalho
  projetos/<slug>/         camada 2: vale para um cliente ou projeto
  pessoas/<slug>/          camada 3: combinados com uma pessoa
handoffs/                  bastões: trabalho pela metade esperando alguém
trabalho/<projeto>/        rascunhos em texto do trabalho em andamento (o definitivo vai para o Drive)
.claude/
  settings.json            o hook de início e as permissões do git
  hooks/inicio-de-sessao.sh
  skills/                  as skills do time: aboutme, encerrar-trabalho, passagem-de-bastao
scripts/checar-memoria.sh  checador que roda antes de todo commit
teste/                     o teste de duas pessoas (ver "Como provar que funciona")
```

As skills do time ficam em `.claude/skills/`, porque é lá que o Claude Code procura skills de projeto.
Toda skill nova que o time criar (uma por processo que o Claude executa muitas vezes) entra ali e passa
a valer para todo mundo no próximo `git pull`.

Cada pasta tem um `_modelo.md` com o formato. O modelo é só o formato: o repositório começa sem
nenhum dado, e o que entrar vem do trabalho real.

## O que vai onde

| Se é… | Vai para | Exemplo do tipo |
|---|---|---|
| Referência estável sobre a empresa, um cliente ou um produto | `empresa/` | quem decide no cliente, preço vigente |
| Fato que alguém precisa lembrar e que vale além de um trabalho | `memoria/` | "a tabela do Drive está velha para tal item" |
| Estado de um trabalho que vai continuar | `handoffs/` | próximo passo, o que falta, dados para terminar |
| Rascunho do trabalho em si, em texto | `trabalho/<projeto>/` | a proposta que ainda está sendo escrita |
| Procedimento que o Claude repete | `.claude/skills/` | fechar uma proposta do jeito da casa |
| Preferência pessoal que o time não precisa ver | `CLAUDE.local.md` (fica fora do Git) | "me responda sempre em tópicos" |
| Senha, token, CPF, salário, saúde | lugar nenhum | |

A memória é o degrau de entrada. Quando um fato se repete e vira regra, ele sobe: vai para o documento
de `empresa/` ou vira skill, e o arquivo de memória sai (o Git guarda o histórico). Quando a regra é
quebrada duas vezes, ela vira verificação automática, como o checador.

## Os três rituais

**`/aboutme`.** Na primeira sessão de cada pessoa. São 20 perguntas em 5 blocos (papel, com quem, onde
estão as coisas, qualidade, como trabalhar com você), uns 10 minutos. O resultado vai para
`pessoas/<slug>/aboutme.md`, e o hook passa a reconhecer a pessoa pelo e-mail do Git. As perguntas
"o que só você sabe?" e "que tarefa sua outro deveria conseguir fazer?" mostram o que hoje depende de
uma pessoa só.

**`/encerrar-trabalho`.** No fim de qualquer trabalho que gerou decisão, aprendizado ou dado novo. O
Claude separa o que é memória (vale para o futuro) do que é bastão (estado deste trabalho), procura
se o assunto já existe antes de criar, escreve com fonte, roda o checador e mostra tudo numa mensagem
só, terminando em "posso commitar e enviar para o time?". Nada vai para o time sem o sim.

**`/passagem-de-bastao`.** Para entregar ("vou sair, o Bruno continua") ou receber ("continua o que a
Ana deixou", "o que tenho para hoje?"). O bastão tem objetivo, onde está, próximo passo, decisões com
o porquê, os dados que quem recebe precisa, acessos, pendências e o que não foi verificado. Antes de
enviar, o Claude faz o **teste do estranho**: relê o bastão como quem não estava na conversa e escreve
a resposta de cada pergunta que essa pessoa faria.

Não precisa decorar os comandos. Frases como "encerra por hoje" ou "o que ficou pendente?" já chamam a
skill certa.

## Como instalar no time

**Quem configura (uma vez):**

1. Crie um repositório **privado** no serviço que o time já usa (GitHub, GitLab ou Azure DevOps) e dê
   acesso a cada pessoa.
2. Copie este modelo para lá, preencha o `CLAUDE.md` com o nome da empresa e envie:

```bash
git remote add origin <endereço do repositório privado>
```

```bash
git push -u origin main
```

**Cada pessoa (uma vez):**

1. Instale o Git (no Windows, o [Git for Windows](https://git-scm.com/downloads/win); o Claude Code
   usa o Git Bash dele para rodar o hook) e o Claude Code.
2. Clone o repositório e diga ao Git quem você é. É pelo e-mail que o hook reconhece a pessoa:

```bash
git clone <endereço do repositório privado> memoria-do-time
```

```bash
git -C memoria-do-time config user.name "Seu Nome"
```

```bash
git -C memoria-do-time config user.email "seu.email@empresa.com"
```

3. Abra o Claude Code na pasta `memoria-do-time`, aceite a confiança na pasta e rode `/aboutme`. Sem
   a confiança, o Claude Code ignora as permissões do `.claude/settings.json` e pede aprovação a cada
   comando do git.

Daí em diante, cada pessoa trabalha a partir desta pasta. O hook atualiza a cópia sozinho a cada
sessão, e o `/encerrar-trabalho` envia as mudanças.

**No Windows:** o hook é um script de shell, chamado como `bash .claude/hooks/inicio-de-sessao.sh`.
Numa instalação padrão do Git for Windows, o Claude Code acha o Git Bash sozinho. Se ele avisar "Git
Bash wasn't found" (acontece quando o Git foi instalado numa pasta fora do padrão), aponte para o
bash do Git na variável `CLAUDE_CODE_GIT_BASH_PATH`, por exemplo `C:\Program Files\Git\bin\bash.exe`.
Sem o Git Bash, o Claude Code roda o hook e os comandos no PowerShell. O hook continua funcionando se
o `bash` estiver no PATH, e o `settings.json` já traz as mesmas permissões para a ferramenta
PowerShell. Mesmo sem o hook, o `CLAUDE.md` manda o Claude rodar `git pull` quando o bloco "Memória
do time" não aparece.

## Por que assim

- **Git, e não só uma pasta no Drive.** O Git guarda quem mudou o quê e quando, junta o trabalho de
  duas pessoas que mexeram ao mesmo tempo e deixa voltar atrás. O Claude Code trabalha com arquivos
  locais. O Drive e o Teams continuam sendo o lugar dos documentos grandes, e a memória aponta para
  eles.
- **Um fato por arquivo.** Duas pessoas registram memórias ao mesmo tempo sem conflito, um fato velho
  se corrige ou se apaga sem mexer nos outros, e o Claude abre só o que precisa.
- **Índice curto sempre carregado.** O Claude sabe o que existe sem ler tudo, e o custo de contexto
  fica baixo. O teto é de 60 linhas, e o hook avisa quando passar. Como o índice é o único arquivo que
  todos editam, o `.gitattributes` funde as duas versões em vez de criar conflito.
- **Três camadas.** O que vale para a empresa toda é diferente do que vale para um cliente, que é
  diferente de como uma pessoa gosta de trabalhar. Separar evita que a preferência de um cliente vire
  regra geral.
- **Fonte em todo fato.** Memória sem fonte vira boato. Com fonte, o Claude cita de onde tirou, e quem
  duvida vai conferir. Quando memória e documento discordam, vale o mais recente com fonte, e o Claude
  diz qual usou.
- **Curar em vez de acumular.** Juntar tudo não vira capacidade. Antes de criar uma memória, o Claude
  procura se o assunto já existe, e o que virou regra sobe para `empresa/`.
- **Bastão com "o que não foi verificado".** Quem retoma sabe onde pisar com cuidado, em vez de herdar
  uma certeza que ninguém conferiu.
- **`CLAUDE.md` curto, com o que não fazer.** Regra curta e negativa ("não suponha", "não faça commit
  sem OK") muda mais o comportamento e custa menos contexto que um manual. O detalhe fica nas skills,
  que só carregam quando são usadas.
- **Hook, e não lembrete.** Ninguém precisa lembrar de atualizar a cópia. E o checador prova, sem
  depender de alguém lembrar, que o índice bate com os arquivos e que nenhuma senha entrou.

## Curadoria (15 minutos por mês)

Peça ao Claude: "faz a curadoria da memória". O roteiro é:

1. O índice passou de 60 linhas? Funda as memórias que dizem a mesma coisa.
2. Alguma memória virou regra? Ela sobe para `empresa/` (ou vira skill) e sai de `memoria/`.
3. Alguma memória ficou falsa (preço antigo, contato que saiu)? Atualize ou apague.
4. Algum bastão está `aberto` ou `retomado` há mais de duas semanas? Pergunte ao dono.
5. Rode `bash scripts/checar-memoria.sh` e faça o commit.

## Privacidade e segurança

- O repositório é **privado**, e todos os que têm acesso leem tudo. O que não pode ser lido pelo time
  inteiro não entra.
- Nunca entram senha, token, chave, CPF, salário, saúde ou dado de cliente sob sigilo. O checador
  barra os padrões mais comuns (chave privada, tokens de GitHub, AWS, Google, Slack e Anthropic, CPF
  formatado) e avisa sobre senha anotada. Ele não substitui o bom senso.
- Para dar acesso a alguma coisa, o bastão diz **a quem pedir**, nunca a senha.
- O Claude não faz commit nem push sem o OK da pessoa: é regra do `CLAUDE.md` e das skills, e o push
  ainda pede a aprovação do Claude Code. Force push, `reset --hard` e `git clean` estão bloqueados no
  `.claude/settings.json`, com a flag em qualquer posição do comando.

## Drive e Teams

O repositório não substitui o Drive nem o Teams. A divisão é esta:

- O documento grande (contrato, planilha, apresentação) fica onde já está.
- O repositório guarda o resumo de uma página e o link (`empresa/clientes/`, `empresa/produtos/`), e as
  memórias citam o link como fonte.
- Para o Claude abrir o documento sozinho, ligue o conector do Google Drive ou do Microsoft 365 na
  conta do Claude de cada pessoa. Sem conector, a pessoa abre o link e cola o trecho que importa.

## Como provar que funciona

O `teste/teste-dois-clones.sh` simula duas pessoas em duas cópias do repositório, ligadas a um
repositório central local:

1. A **Ana** recebe, num chat, os dados de uma call com um cliente fictício. Parte desses dados
   desmente a tabela de preços que está em `empresa/`. Ela começa a proposta e roda
   `/encerrar-trabalho` para deixar o resto com o Bruno.
2. O **Bruno**, noutra cópia e noutra sessão, diz só "bom dia, o que tenho para hoje?" e "pode seguir
   até terminar". O hook puxa o trabalho da Ana, e o Claude dele termina a proposta.
3. O script confere se o hook atualizou a cópia do Bruno, se a proposta final tem o total certo (que
   só fecha com o preço novo, a quantidade e o desconto que a Ana combinou), se a sessão do Bruno não
   leu a cópia da Ana e se o bastão foi fechado.
4. **Controle negativo:** uma terceira cópia recebe o arquivo da proposta da Ana, mas não a memória
   nem o bastão (é a situação de hoje, de quem só recebe o arquivo). O script confere se, sem a
   memória, o total certo não aparece.
5. Fora isso, dois commits simultâneos no índice provam que a fusão automática não gera conflito.

Para rodar (precisa do Claude Code logado; cada rodada são oito turnos curtos de sessão, no Sonnet):

```bash
bash teste/teste-dois-clones.sh
```

Sem o Claude, só a parte mecânica (hook, checador, fusão do índice):

```bash
bash teste/teste-dois-clones.sh --sem-claude
```

O resultado da última rodada fica em `teste/RESULTADO.md`.

## Limites conhecidos

- Precisa de Git em cada máquina e de um repositório privado. Para quem nunca usou Git, o Claude roda
  os comandos, mas alguém configura a primeira vez.
- A memória vale o que vale a curadoria. Sem o `/encerrar-trabalho`, nada entra, e sem a curadoria
  mensal o índice incha.
- A busca é por índice e por pasta, não semântica. Isso funciona até umas centenas de memórias. Depois
  disso, vale um índice por cliente ou uma busca vetorial.
- O hook precisa de bash. No Windows, isso quer dizer o Git for Windows.
- O conector do Drive ou do Teams não vem neste modelo: depende da conta de cada pessoa.

## De onde vieram as ideias

O desenho junta padrões que se repetem entre quem usa o Claude no trabalho em equipe: a entrevista
`aboutme` como contexto pessoal; a divisão em procedimento (skill), contexto (nota) e acesso
(conector); o arquivo de passagem de bastão com objetivo, decisões, arquivos e pendências; o resumo de
uma página no lugar do documento bruto; o `CLAUDE.md` curto escrito como lista do que não fazer; e a
curadoria no lugar do acúmulo. O texto e os scripts deste repositório são próprios.
