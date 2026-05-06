#!/usr/bin/env bash
# Shared helpers, sourced by install.sh and every module.

CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log()   { printf "${CYAN}[+]${NC} %s\n" "$*"; }
ok()    { printf "${GREEN}[=]${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}[!]${NC} %s\n" "$*"; }
error() { printf "${RED}[x]${NC} %s\n" "$*" >&2; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

ensure_apt_updated() {
    local stamp=/var/lib/apt/periodic/update-success-stamp
    if [[ ! -f $stamp ]] || (( $(date +%s) - $(stat -c %Y "$stamp") > 3600 )); then
        log "apt-get update"
        sudo apt-get update -qq
    fi
}

apt_install_if_missing() {
    local pkgs=()
    for p in "$@"; do
        if ! dpkg -s "$p" >/dev/null 2>&1; then
            pkgs+=("$p")
        fi
    done
    if (( ${#pkgs[@]} > 0 )); then
        ensure_apt_updated
        log "apt installing: ${pkgs[*]}"
        sudo apt-get install -y "${pkgs[@]}"
    else
        ok "apt packages already present: $*"
    fi
}

# nvm.sh references unset vars, so toggle set -u around the source.
load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        set +u
        # shellcheck disable=SC1091
        source "$NVM_DIR/nvm.sh"
        set -u
    fi
}

npm_install_global_if_missing() {
    local cmd="$1" pkg="$2"
    if have_cmd "$cmd"; then
        ok "$cmd already installed: $("$cmd" --version 2>/dev/null | head -1)"
        return 0
    fi
    log "npm install -g $pkg"
    npm install -g "$pkg"
}
