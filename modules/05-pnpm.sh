#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/../config.sh"

load_nvm

if have_cmd pnpm; then
    ok "pnpm already installed: $(pnpm --version)"
    exit 0
fi

log "installing pnpm@$PNPM_VERSION via npm"
npm install -g "pnpm@$PNPM_VERSION"
