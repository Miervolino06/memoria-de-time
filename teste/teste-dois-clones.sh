#!/usr/bin/env bash
# Teste de duas pessoas para a memória de time.
# A Ana encerra um trabalho. O Bruno, noutra cópia e noutra sessão, retoma só pelo bastão e pela
# memória, sem receber nenhum dado do trabalho. Um controle negativo recebe o arquivo da Ana, sem a
# memória e sem o bastão, e não pode chegar ao total certo.
#
# Uso: bash teste/teste-dois-clones.sh [--sem-claude] [pasta]
#   --sem-claude  roda só a parte mecânica (hook, checador e fusão do índice), sem gastar cota
#   pasta         onde criar o repositório central e as cópias (padrão: uma pasta temporária nova)
# Variáveis: MODELO_CLAUDE (padrão sonnet) e TEMPO_TURNO em segundos (padrão 900).
# Saída 0 = tudo passou. O resumo fica em <pasta>/resultado.txt e as conversas em <pasta>/logs/.

set -u
RAIZ=$(cd "$(dirname "$0")/.." && pwd)
CENARIO="$RAIZ/teste/cenario"
SEM_CLAUDE=0
if [ "${1:-}" = "--sem-claude" ]; then SEM_CLAUDE=1; shift; fi
BASE=${1:-"${TMPDIR:-/tmp}/memoria-de-time-teste-$(date +%Y%m%d-%H%M%S)"}
MODELO=${MODELO_CLAUDE:-sonnet}
TEMPO=${TEMPO_TURNO:-900}
PROPOSTA=trabalho/propostas/construtora-horizonte.md

if [ -n "$(ls -A "$BASE" 2>/dev/null)" ]; then echo "A pasta $BASE não está vazia. Escolha outra."; exit 2; fi
mkdir -p "$BASE/logs" && BASE=$(cd "$BASE" && pwd)
RESULTADO="$BASE/resultado.txt"
: > "$RESULTADO"

passou=0
falhou=0
registra() { printf '%s\n' "$*" | tee -a "$RESULTADO"; }
confere() { # confere "<descrição>" <comando...>
  local d=$1
  shift
  if "$@" >/dev/null 2>&1; then
    registra "PASSOU  $d"
    passou=$((passou + 1))
  else
    registra "FALHOU  $d"
    falhou=$((falhou + 1))
  fi
}
identidade() { git -C "$1" config user.name "$2" && git -C "$1" config user.email "$3"; }
checador_ok() { (cd "$1" && bash scripts/checar-memoria.sh); }
memorias() { find "$1/memoria" -type f -name '*.md' ! -name 'INDICE.md' ! -name '_*'; }
resumo() {
  registra "Resultado: $passou passou, $falhou falhou."
  [ "$falhou" -eq 0 ]
  exit $?
}

command -v git >/dev/null || { echo "Precisa do git."; exit 2; }
if [ "$SEM_CLAUDE" -eq 0 ] && ! command -v claude >/dev/null; then
  echo "Precisa do Claude Code logado (comando claude), ou rode com --sem-claude."
  exit 2
fi
registra "Teste de duas pessoas, $(date '+%d/%m/%Y %H:%M'). Modelo do repositório: commit $(git -C "$RAIZ" rev-parse --short HEAD). Pasta: $BASE"
if [ -n "$(git -C "$RAIZ" status --porcelain 2>/dev/null)" ]; then
  registra "AVISO   o repositório tem mudança não commitada; o teste usa só o último commit."
fi

# 1. Repositório central, semente do cenário e três cópias (Ana, Bruno e o controle, sem remoto)
git clone -q --bare "$RAIZ" "$BASE/central.git"
git clone -q "$BASE/central.git" "$BASE/ana"
identidade "$BASE/ana" "Ana Teste" "ana@exemplo.com"
cp -R "$CENARIO/semente/." "$BASE/ana/"
git -C "$BASE/ana" -c core.safecrlf=false add -A
git -C "$BASE/ana" commit -qm "semente do cenário de teste"
git -C "$BASE/ana" push -q
SEMENTE=$(git -C "$BASE/ana" rev-parse HEAD)
for p in bruno controle; do
  git clone -q "$BASE/central.git" "$BASE/$p"
  identidade "$BASE/$p" "Bruno Teste" "bruno@exemplo.com"
done
git -C "$BASE/controle" remote remove origin

# 2. Parte mecânica
(cd "$BASE/bruno" && bash .claude/hooks/inicio-de-sessao.sh) > "$BASE/logs/hook-bruno-antes.txt" 2>&1
confere "hook reconhece o Bruno pelo e-mail do git" grep -q "Pessoa desta sessão: Bruno Teste" "$BASE/logs/hook-bruno-antes.txt"
confere "hook não vê bastão antes de a Ana trabalhar" grep -q "Nenhum bastão aberto" "$BASE/logs/hook-bruno-antes.txt"
confere "checador passa na semente" checador_ok "$BASE/ana"

uniao() { # dois commits simultâneos na mesma seção do índice
  local u="$BASE/uniao" p
  git clone -q --bare "$BASE/central.git" "$u/central.git" || return 1
  for p in p1 p2; do
    git clone -q "$u/central.git" "$u/$p" && identidade "$u/$p" "$p" "$p@exemplo.com" || return 1
    printf -- '---\nresumo: fato de %s\ntipo: aprendizado\nautor: %s\ndata: 2026-11-01\nfonte: teste de fusão\n---\n\nFato de %s.\n' \
      "$p" "$p" "$p" > "$u/$p/memoria/empresa/fato-$p.md"
    awk -v l="- [Fato de $p](empresa/fato-$p.md) — teste de fusão ($p, 01/11/2026)" '{ print } /^## Empresa/ { print l }' \
      "$u/$p/memoria/INDICE.md" > "$u/indice.tmp" && mv "$u/indice.tmp" "$u/$p/memoria/INDICE.md"
    git -C "$u/$p" -c core.safecrlf=false add -A && git -C "$u/$p" commit -qm "memória de $p" || return 1
  done
  git -C "$u/p1" push -q && git -C "$u/p2" pull -q --rebase || return 1
  grep -q 'fato-p1.md' "$u/p2/memoria/INDICE.md" && grep -q 'fato-p2.md' "$u/p2/memoria/INDICE.md" && checador_ok "$u/p2"
}
confere "dois commits simultâneos no índice se fundem sem conflito" uniao

if [ "$SEM_CLAUDE" -eq 1 ]; then resumo; fi

# 3. Sessões do Claude. Sem o CLAUDE.md global, sem as configurações de usuário e sem os conectores
# da conta de quem roda o teste (Gmail, Drive...), para simular outra pessoa; e sem permissão de
# mexer em ~/.claude.
CONFIG="$BASE/config-teste.json"
cat > "$CONFIG" <<'JSON'
{
  "claudeMdExcludes": ["**/.claude/CLAUDE.md"],
  "permissions": { "deny": ["Edit(~/.claude/**)", "Write(~/.claude/**)"] }
}
JSON
impressao_global() { cat "$HOME/.claude/CLAUDE.md" "$HOME/.claude/settings.json" 2>/dev/null | cksum; }
GLOBAL_ANTES=$(impressao_global)
# No Windows, aponta o Claude Code para o Git Bash (numa instalação padrão do Git ele acha sozinho).
case "$(uname -s)" in
  MINGW* | MSYS* | CYGWIN*)
    if [ -z "${CLAUDE_CODE_GIT_BASH_PATH:-}" ] && command -v cygpath >/dev/null 2>&1; then
      gb="$(cygpath -w /)bin\\bash.exe"
      if [ -f "$(cygpath -u "$gb")" ]; then export CLAUDE_CODE_GIT_BASH_PATH="$gb"; fi
    fi
    ;;
esac
LIMITE=""
if timeout --version 2>/dev/null | grep -q coreutils; then LIMITE="timeout $TEMPO"; fi
PY=""
for c in python3 python py; do
  if command -v "$c" >/dev/null 2>&1 && [ "$("$c" -c 'print(1)' 2>/dev/null)" = "1" ]; then PY=$c; break; fi
done
texto_final() { # o texto da última resposta de um log stream-json
  if [ -z "$PY" ]; then grep '"type":"result"' "$1"; return; fi
  "$PY" - "$1" <<'PYEOF'
import json, sys
sys.stdout.reconfigure(encoding="utf-8")
for linha in open(sys.argv[1], encoding="utf-8"):
    try:
        o = json.loads(linha)
    except ValueError:
        continue
    if o.get("type") == "result":
        print(o.get("result") or "")
PYEOF
}
turno() { # turno <cópia> <prompt> [continua]
  local copia=$1 nome=$2 extra=() rc
  if [ "${3:-}" = "continua" ]; then extra=(--continue); fi
  registra "...     turno $nome"
  (cd "$BASE/$copia" && $LIMITE claude -p "$(cat "$CENARIO/prompts/$nome.txt")" ${extra[@]+"${extra[@]}"} \
    --model "$MODELO" --setting-sources project,local --settings "$CONFIG" --strict-mcp-config \
    --permission-mode acceptEdits --allowedTools "Bash(git *)" "Bash(bash scripts/checar-memoria.sh)" \
    "PowerShell(git *)" "PowerShell(bash scripts/checar-memoria.sh)" \
    --output-format stream-json --verbose < /dev/null > "$BASE/logs/$nome.jsonl" 2> "$BASE/logs/$nome.err")
  rc=$?
  [ "$rc" -eq 0 ] || registra "AVISO   turno $nome saiu com código $rc: $(head -c 300 "$BASE/logs/$nome.err")"
  texto_final "$BASE/logs/$nome.jsonl" > "$BASE/logs/$nome.txt" 2>/dev/null
}

# 4. A Ana trabalha, encerra e envia
turno ana ana-1
confere "Ana: rascunho da proposta criado" test -f "$BASE/ana/$PROPOSTA"
turno ana ana-2 continua
confere "Ana: o /encerrar-trabalho espera o OK antes de commitar" test "$(git -C "$BASE/ana" rev-parse HEAD)" = "$SEMENTE"
turno ana ana-3 continua
FIM_ANA=$(git --git-dir="$BASE/central.git" rev-parse HEAD)
confere "Ana: o trabalho chegou ao repositório central" test "$FIM_ANA" != "$SEMENTE"
git clone -q "$BASE/central.git" "$BASE/confere-ana"
BASTAO=$(grep -l '^status: aberto' "$BASE"/confere-ana/handoffs/*.md 2>/dev/null | grep -v '/_modelo.md' | head -n 1)
BASTAO=${BASTAO#"$BASE/confere-ana/"}
confere "Ana: bastão aberto para o Bruno" grep -q '^para: bruno' "$BASE/confere-ana/${BASTAO:-sem-bastao}"
confere "Ana: pelo menos uma memória gravada" test -n "$(memorias "$BASE/confere-ana")"
confere "Ana: checador passa no que ela enviou" checador_ok "$BASE/confere-ana"

# 5. O Bruno retoma noutra cópia, só com "bom dia" e "pode seguir"
turno bruno bruno-1
confere "Bruno: o hook puxou o trabalho da Ana sozinho" test "$(git -C "$BASE/bruno" rev-parse HEAD)" = "$FIM_ANA"
confere "Bruno: o hook avisou que há bastão para ele" grep -q 'PARA VOC' "$BASE/logs/bruno-1.jsonl"
confere "Bruno: a primeira resposta já fala do trabalho da Horizonte" grep -qi 'horizonte' "$BASE/logs/bruno-1.txt"
turno bruno bruno-2 continua
P_BRUNO="$BASE/bruno/$PROPOSTA"
confere "Bruno: total certo (30 x R\$ 1.250,00 - 8% = R\$ 34.500,00)" grep -q '34\.500' "$P_BRUNO"
confere "Bruno: usou o preço novo aprovado (R\$ 1.250,00), não o da tabela" grep -q '1\.250' "$P_BRUNO"
confere "Bruno: prazo de entrega de 20/12/2026" grep -qE '20/12(/2026)?|20 de dezembro' "$P_BRUNO"
confere "Bruno: proposta endereçada à Marta" grep -qi 'marta' "$P_BRUNO"
sem_rastro_da_ana() {
  local n
  n=$(basename "$BASE")
  ! grep -qiE "${n}[/\\\\]+ana([/\\\\\"]|$)" "$BASE"/logs/bruno-*.jsonl
}
confere "Bruno: nenhuma ferramenta tocou a cópia da Ana" sem_rastro_da_ana
turno bruno bruno-3 continua
turno bruno bruno-4 continua
git clone -q "$BASE/central.git" "$BASE/confere-bruno"
confere "Bruno: bastão retomado ou concluído no repositório central" \
  grep -qE '^(status: concluido|retomado_por: bruno)' "$BASE/confere-bruno/${BASTAO:-sem-bastao}"
confere "Bruno: checador passa no que ele enviou" checador_ok "$BASE/confere-bruno"

# 6. Controle negativo: o arquivo da Ana chega (como chegaria pelo Drive), a memória e o bastão não
mkdir -p "$BASE/controle/$(dirname "$PROPOSTA")"
git --git-dir="$BASE/central.git" show "$FIM_ANA:$PROPOSTA" > "$BASE/controle/$PROPOSTA" 2>/dev/null
cp "$BASE/controle/$PROPOSTA" "$BASE/logs/rascunho-da-ana.md" 2>/dev/null
turno controle controle-1
sem_total_certo() { test -s "$1" && ! grep -q '34\.500' "$1"; }
confere "Controle: só com o arquivo, o total certo não aparece" sem_total_certo "$BASE/controle/$PROPOSTA"
registra "        totais na proposta do controle: $(grep -oE 'R\$ ?[0-9.]+,[0-9]{2}' "$BASE/controle/$PROPOSTA" 2>/dev/null | sort -u | tr '\n' ' ')"
confere "nenhuma sessão de teste mexeu na configuração global" test "$(impressao_global)" = "$GLOBAL_ANTES"

resumo
