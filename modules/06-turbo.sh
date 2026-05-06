#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/../config.sh"

load_nvm

if have_cmd turbo; then
    ok "turbo already installed: $(turbo --version)"
    exit 0
fi

log "installing turbo@$TURBO_VERSION via npm"
npm install -g "turbo@$TURBO_VERSION"
