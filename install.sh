#!/usr/bin/env bash
# hermes-auditor: installs Hermes Agent if missing and puts the auditor role into $HERMES_HOME/SOUL.md
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/izmukovvladimir-cyber/hermes-auditor/main"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

if ! command -v hermes >/dev/null 2>&1; then
  echo "Ставлю Hermes Agent официальным установщиком Nous Research..." >&2
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup
fi
command -v hermes >/dev/null 2>&1 || {
  echo "Команда hermes не найдена после установки. Открой новый терминал и запусти этот скрипт ещё раз." >&2
  exit 1
}

mkdir -p "$HERMES_HOME"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$REPO_RAW/SOUL.md" -o "$tmp"
grep -q "Аудитор AI-отдела" "$tmp" || { echo "SOUL.md скачался не тот, остановился" >&2; exit 1; }
if [[ -f "$HERMES_HOME/SOUL.md" ]]; then
  cp -p "$HERMES_HOME/SOUL.md" "$(mktemp "$HERMES_HOME/SOUL.md.bak-$(date +%Y%m%d)-XXXXXX")"
fi
cp "$tmp" "$HERMES_HOME/SOUL.md"

cat >&2 <<EOF

Готово: Hermes стоит, роль аудитора лежит в $HERMES_HOME/SOUL.md
Дальше по README:
  1. hermes setup            (модель и Telegram-бот)
  2. nano $HERMES_HOME/SOUL.md   (заполнить метки в фигурных скобках)
  3. hermes gateway install --start-now
EOF
