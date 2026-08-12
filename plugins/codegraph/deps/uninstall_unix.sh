#!/usr/bin/env bash
# Remove CodeGraph CLI artifacts from $DANMO_HOME/bin (idempotent).
set -euo pipefail

HOME_DIR="${DANMO_HOME:-}"
if [[ -z "$HOME_DIR" ]]; then
  echo "DANMO_HOME is required" >&2
  exit 1
fi
BIN_DIR="$HOME_DIR/bin"
removed=0
for f in codegraph codegraph.exe codegraph.tar.gz codegraph.zip CODEGRAPH_VERSION; do
  p="$BIN_DIR/$f"
  if [[ -e "$p" ]]; then
    rm -f "$p"
    echo "removed $p"
    removed=1
  fi
done
if [[ "$removed" -eq 0 ]]; then
  echo "==> No CodeGraph artifacts under $BIN_DIR"
else
  echo "==> CodeGraph cleanup done"
fi
