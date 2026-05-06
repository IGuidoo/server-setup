#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/../config.sh"

NAME="${GIT_NAME:-$(git config --global user.name 2>/dev/null || true)}"
EMAIL="${GIT_EMAIL:-$(git config --global user.email 2>/dev/null || true)}"

if [[ -z "$NAME" || -z "$EMAIL" ]]; then
    if [[ -t 0 ]]; then
        [[ -z "$NAME"  ]] && read -rp "git user.name:  " NAME
        [[ -z "$EMAIL" ]] && read -rp "git user.email: " EMAIL
    else
        warn "GIT_NAME / GIT_EMAIL not set and shell non-interactive — skipping"
        exit 0
    fi
fi

git config --global user.name  "$NAME"
git config --global user.email "$EMAIL"
git config --global init.defaultBranch main
ok "git config: $NAME <$EMAIL> (init.defaultBranch=main)"
