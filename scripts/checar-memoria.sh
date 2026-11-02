#!/usr/bin/env bash
# Checador da memória do time. O /encerrar-trabalho roda antes de propor o commit, e dá para rodar à
# mão: `bash scripts/checar-memoria.sh`. Confere, sem depender de ninguém lembrar, que:
#   1. cada memória está numa camada, tem cabeçalho completo e data no formato AAAA-MM-DD;
#   2. índice e arquivos batem nos dois sentidos (nada fora do índice, nenhum link quebrado ou repetido);
#   3. cada bastão tem título, de, para, data e status válido;
#   4. nada com cara de chave privada, token ou CPF entrou no repositório.
# Saída 0 = pode commitar. Saída 1 = há erro (cada linha diz o quê e onde).

cd "$(dirname "$0")/.." || exit 1

erros=0
avisos=0
erro() { echo "ERRO   $*"; erros=$((erros + 1)); }
aviso() { echo "AVISO  $*"; avisos=$((avisos + 1)); }

campo() {
  tr -d '\r' < "$1" | awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[ \t]+/, "", v); sub(/[ \t]+$/, "", v); print v; exit }'
}
data_ok() { printf '%s' "$1" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; }

# 1 e 2. Memórias e índice
indice=memoria/INDICE.md
links=""
if [ -f "$indice" ]; then
  # Só os itens da lista; o bloco de instruções (linhas com ">") tem um link de exemplo.
  links=$(tr -d '\r' < "$indice" | grep '^- ' | grep -o '](\([^)]*\))' | sed -e 's/^](//' -e 's/)$//' | grep -v '^https\?:')
else
  erro "falta o $indice"
fi

n_mem=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  n_mem=$((n_mem + 1))
  rel=${f#memoria/}
  case "$rel" in
    *[!a-z0-9/._-]*) erro "$f: use só letras minúsculas sem acento, números e hífen no nome" ;;
  esac
  case "$rel" in
    empresa/*.md | projetos/*/*.md | pessoas/*/*.md) ;;
    *) erro "$f: fora das camadas (memoria/empresa/, memoria/projetos/<slug>/, memoria/pessoas/<slug>/)" ;;
  esac
  for k in resumo tipo autor data fonte; do
    [ -n "$(campo "$f" "$k")" ] || erro "$f: falta '$k:' no cabeçalho"
  done
  d=$(campo "$f" data)
  if [ -n "$d" ] && ! data_ok "$d"; then erro "$f: data '$d' fora do formato AAAA-MM-DD"; fi
  t=$(campo "$f" tipo)
  case "$t" in
    "" | decisao | aprendizado | preferencia | referencia) ;;
    *) erro "$f: tipo '$t' (use decisao, aprendizado, preferencia ou referencia)" ;;
  esac
  c=$(printf '%s\n' "$links" | grep -cxF "$rel")
  if [ "$c" -eq 0 ]; then erro "$f: não está no índice ($indice)"; fi
  if [ "$c" -gt 1 ]; then erro "$f: aparece $c vezes no índice"; fi
done < <(find memoria -type f -name '*.md' ! -name 'INDICE.md' ! -name '_*' | sort)

while IFS= read -r l; do
  [ -n "$l" ] || continue
  [ -f "memoria/$l" ] || erro "$indice: link quebrado para '$l' (o caminho é relativo a memoria/)"
done <<< "$links"

n_linhas=$(grep -c '^- ' "$indice" 2>/dev/null)
if [ "${n_linhas:-0}" -gt 60 ]; then aviso "$indice tem $n_linhas linhas (teto 60): hora de curar"; fi

# 3. Bastões
n_bastoes=0
n_abertos=0
for f in handoffs/*.md; do
  [ -f "$f" ] || continue
  case "$(basename "$f")" in _*) continue ;; esac
  n_bastoes=$((n_bastoes + 1))
  for k in titulo de para data status; do
    [ -n "$(campo "$f" "$k")" ] || erro "$f: falta '$k:' no cabeçalho"
  done
  s=$(campo "$f" status)
  case "$s" in
    aberto) n_abertos=$((n_abertos + 1)) ;;
    "" | retomado | concluido) ;;
    *) erro "$f: status '$s' (use aberto, retomado ou concluido)" ;;
  esac
  d=$(campo "$f" data)
  if [ -n "$d" ] && ! data_ok "$d"; then erro "$f: data '$d' fora do formato AAAA-MM-DD"; fi
done

# 4. Segredos e dado sensível (arquivos versionados e novos, fora os ignorados pelo .gitignore)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  graves='-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[0-9]{6,}-|sk-ant-[A-Za-z0-9_-]{20,}|sk-proj-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,}|[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}'
  while IFS= read -r achado; do
    [ -n "$achado" ] && erro "parece chave, token ou CPF: ${achado%%:*} (linha $(printf '%s' "$achado" | cut -d: -f2)). Tire do arquivo."
  done < <(git grep -nIE --untracked -e "$graves" -- . ':(exclude)scripts/checar-memoria.sh' 2>/dev/null)
  while IFS= read -r achado; do
    [ -n "$achado" ] && aviso "parece senha anotada: ${achado%%:*} (linha $(printf '%s' "$achado" | cut -d: -f2)). Senha não entra; escreva a quem pedir acesso."
  done < <(git grep -nIiE --untracked -e '(senha|password|passwd)[[:space:]]*[:=][[:space:]]*[^[:space:]]{4,}' -- . ':(exclude)scripts/checar-memoria.sh' ':(exclude)*_modelo.md' 2>/dev/null)
fi

echo "Memórias: $n_mem · bastões: $n_bastoes ($n_abertos aberto(s)) · índice: ${n_linhas:-0} linha(s) · erros: $erros · avisos: $avisos"
if [ "$erros" -gt 0 ]; then
  echo "Corrija os erros antes do commit."
  exit 1
fi
echo "OK: pode commitar."
exit 0
