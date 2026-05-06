#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

KEY_PATH="$HOME/.ssh/id_ed25519"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ -f "$KEY_PATH" ]]; then
    ok "ssh key exists: $KEY_PATH"
else
    EMAIL="$(git config --global user.email 2>/dev/null || echo "$USER@$(hostname)")"
    log "generating ed25519 ssh key (comment: $EMAIL)"
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""
    chmod 600 "$KEY_PATH"
    chmod 644 "${KEY_PATH}.pub"
fi

printf "\n${CYAN}--- public key (add to https://github.com/settings/ssh/new) ---${NC}\n"
cat "${KEY_PATH}.pub"
printf "${CYAN}---${NC}\n"
printf "Test: ssh -T git@github.com\n"
