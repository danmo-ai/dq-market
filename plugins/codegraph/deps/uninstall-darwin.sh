#!/usr/bin/env bash
# Darwin uninstall entry — removes CodeGraph CLI from $DANMO_HOME/bin.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=uninstall_unix.sh
source "$SCRIPT_DIR/uninstall_unix.sh"
