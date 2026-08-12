#!/usr/bin/env bash
# Darwin deps entry — installs CodeGraph CLI into $DANMO_HOME/bin.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=install_unix.sh
source "$SCRIPT_DIR/install_unix.sh"
