#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

apt_install_if_missing bat

# Ubuntu installs the binary as 'batcat' to avoid a name clash; expose it as 'bat'.
mkdir -p "$HOME/.local/bin"
if ! have_cmd bat && have_cmd batcat; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    log "symlinked batcat -> ~/.local/bin/bat (ensure ~/.local/bin is on PATH)"
fi
