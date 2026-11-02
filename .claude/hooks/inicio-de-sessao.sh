#!/usr/bin/env bash
# Hook de início de sessão do Claude Code (SessionStart, em .claude/settings.json).
# 1. Atualiza a cópia do time com `git pull --ff-only`, sem pedir senha e sem travar.
# 2. Conta ao Claude quem é a pessoa, o que mudou desde a última sessão e quais bastões estão abertos.
# O que este script imprime entra no contexto da sessão. Ele nunca bloqueia: falha vira aviso, saída 0.

cd "$(dirname "$0")/../.." 2>/dev/null || exit 0

# Valor de uma chave no cabeçalho (entre as linhas ---) de um arquivo markdown. Tolera CRLF.
campo() {
  tr -d '\r' < "$1" | awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[ \t]+/, "", v); sub(/[ \t]+$/, "", v); print v; exit }'
}
data_br() { printf '%s' "$1" | sed -E 's/^([0-9]{4})-([0-9]{2})-([0-9]{2})$/\3\/\2\/\1/'; }
minusculo() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

echo "## Memória do time — início de sessão"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "- AVISO: esta pasta não é um repositório Git, então a memória não sincroniza com o time."
  exit 0
fi

# 1. Atualizar a cópia
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  antes=$(git rev-parse HEAD 2>/dev/null)
  saida=$(GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=10}" \
    git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=15 pull --no-rebase --ff-only --quiet 2>&1)
  if [ $? -eq 0 ]; then
    depois=$(git rev-parse HEAD 2>/dev/null)
    if [ "$antes" = "$depois" ]; then
      echo "- Cópia atualizada: nada novo desde a última sessão."
    else
      echo "- Cópia atualizada: $(git rev-list --count "$antes..$depois") commit(s) novo(s) do time."
      git log --format='  - %an, %ad: %s' --date=format:'%d/%m %H:%M' "$antes..$depois" | head -n 12
    fi
  else
    motivo=$(printf '%s\n' "$saida" | grep -v '^hint:' | head -n 2 | tr '\n' ' ')
    case "$saida" in
      *"Not possible to fast-forward"*|*"diverg"*)
        echo "- AVISO: a cópia não atualizou porque esta máquina tem commits que o time não tem, e vice-versa. Sincronize antes de trabalhar (o /encerrar-trabalho faz isso com pull --rebase).";;
      *"would be overwritten"*)
        echo "- AVISO: a cópia não atualizou porque há mudança local não commitada em arquivo que o time alterou. Salve com /encerrar-trabalho e atualize de novo.";;
      *)
        echo "- AVISO: não consegui falar com o repositório do time (sem rede ou sem acesso). A cópia local é de $(git log -1 --format=%cd --date=format:%d/%m/%Y). Motivo: $motivo";;
    esac
  fi
  pendentes=$(git rev-list --count '@{u}..HEAD' 2>/dev/null)
  if [ "${pendentes:-0}" -gt 0 ]; then
    echo "- Há $pendentes commit(s) desta máquina que ainda não foram para o time (falta o push)."
  fi
else
  echo "- Sem repositório remoto configurado: a cópia é só local e não há o que atualizar."
fi

sujos=$(git status --porcelain -- memoria handoffs pessoas empresa 2>/dev/null | head -n 8)
if [ -n "$sujos" ]; then
  echo "- Há memória ou bastão alterado nesta máquina e não commitado (sessão anterior sem /encerrar-trabalho?):"
  printf '%s\n' "$sujos" | sed 's/^/  /'
fi

# 2. Quem é a pessoa (pelo e-mail do git, comparado com o cabeçalho dos aboutme)
email=$(git config user.email 2>/dev/null)
nome=$(git config user.name 2>/dev/null)
perfil=""
if [ -n "$email" ]; then
  for f in pessoas/*/aboutme.md; do
    [ -f "$f" ] || continue
    if [ "$(minusculo "$(campo "$f" email)")" = "$(minusculo "$email")" ]; then
      perfil=$f
      break
    fi
  done
fi
if [ -n "$perfil" ]; then
  eu=$(basename "$(dirname "$perfil")")
  echo "- Pessoa desta sessão: ${nome:-$eu} (\`$perfil\`). Perfil:"
  tr -d '\r' < "$perfil" \
    | awk 'NR == 1 && $0 == "---" { h = 1; next } h && $0 == "---" { h = 0; next } !h' \
    | sed -e '/<!--/,/-->/d' -e '/^[[:space:]]*$/d' | head -n 60 | sed 's/^/  /'
else
  eu=$(minusculo "${nome%% *}")
  echo "- Pessoa desta sessão: ${nome:-desconhecida} <${email:-sem e-mail no git}>, ainda sem aboutme. Ofereça /aboutme uma vez."
fi

# 3. Bastões abertos
lista=""
for f in handoffs/*.md; do
  [ -f "$f" ] || continue
  case "$(basename "$f")" in _*) continue ;; esac
  [ "$(campo "$f" status)" = "aberto" ] || continue
  para=$(campo "$f" para)
  marca=""
  if [ -n "$eu" ] && [ "$(minusculo "$para")" = "$eu" ]; then marca="  ← PARA VOCÊ"; fi
  lista="$lista
  - $(campo "$f" titulo) — de $(campo "$f" de) para ${para:-time}, $(data_br "$(campo "$f" data)"): \`$f\`$marca"
done
if [ -n "$lista" ]; then
  echo "- Bastões abertos (trabalho pela metade esperando alguém):$lista"
else
  echo "- Nenhum bastão aberto."
fi

# 4. Teto do índice
linhas=$(grep -c '^- ' memoria/INDICE.md 2>/dev/null)
if [ "${linhas:-0}" -gt 60 ]; then
  echo "- AVISO: o índice da memória tem $linhas linhas (teto 60). Proponha uma curadoria: fundir o que se repete e promover para empresa/ o que virou regra."
fi

exit 0
