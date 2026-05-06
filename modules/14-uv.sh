#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

if have_cmd uv; then
    ok "uv already installed: $(uv --version)"
    exit 0
fi

log "installing uv via official installer"
curl -LsSf https://astral.sh/uv/install.sh | sh
