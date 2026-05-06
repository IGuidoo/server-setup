#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/../config.sh"

if [[ -d "$HOME/.nvm" ]]; then
    ok "nvm already present at ~/.nvm"
else
    log "installing nvm $NVM_VERSION"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
fi

load_nvm

if ! have_cmd nvm; then
    error "nvm did not load — open a new shell and rerun"
    exit 1
fi

if have_cmd node; then
    ok "node already installed: $(node --version)"
else
    log "installing node ($NODE_VERSION)"
    if [[ "$NODE_VERSION" == "lts/"* || "$NODE_VERSION" == "lts" ]]; then
        nvm install --lts
        nvm alias default 'lts/*'
    else
        nvm install "$NODE_VERSION"
        nvm alias default "$NODE_VERSION"
    fi
fi
