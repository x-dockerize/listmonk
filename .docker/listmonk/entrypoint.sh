#!/bin/sh
set -e

FLAG_FILE="/listmonk/uploads/.installed"

if [ ! -f "$FLAG_FILE" ]; then
  echo "[listmonk] First run detected, running install..."
  ./listmonk --install --yes
  touch "$FLAG_FILE"
fi

echo "[listmonk] Running upgrade (migrations)..."
./listmonk --upgrade --yes

echo "[listmonk] Starting..."
exec ./listmonk
