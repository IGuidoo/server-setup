#!/usr/bin/env bash
# Entry point. Run as your normal user (with sudo). Idempotent — safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/config.sh"

if [[ $EUID -eq 0 ]]; then
    error "Don't run as root. Run as your normal user — the script uses sudo where needed."
    exit 1
fi

if ! sudo -v; then
    error "sudo unavailable for $USER"
    exit 1
fi

# Keep sudo alive while the script runs.
( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 60; done ) &
KEEPALIVE_PID=$!
trap 'kill $KEEPALIVE_PID 2>/dev/null || true' EXIT

MODULES_DIR="$SCRIPT_DIR/modules"
ONLY=""

usage() {
    cat <<EOF
Usage: $0 [--only mod1,mod2] [--list]

  --only LIST   Run only the listed modules (short names, comma-separated)
  --list        List available modules and exit
  -h, --help    Show this help

Configure versions in config.sh. Skip modules with SKIP=foo,bar env var.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --only) ONLY="$2"; shift 2 ;;
        --list)
            for m in "$MODULES_DIR"/*.sh; do
                basename "$m" .sh
            done
            exit 0 ;;
        -h|--help) usage; exit 0 ;;
        *) error "Unknown arg: $1"; usage; exit 1 ;;
    esac
done

# Map short name (e.g. "docker") to file (e.g. "07-docker.sh").
resolve_module() {
    local short="$1"
    local match
    match=$(find "$MODULES_DIR" -maxdepth 1 -name "*-${short}.sh" -printf '%f\n' | head -1)
    [[ -z "$match" ]] && { error "Module not found: $short"; exit 1; }
    echo "$match"
}

short_name() {
    local f="$1"
    f="${f%.sh}"
    echo "${f#*-}"
}

run_module() {
    local file="$1" name
    name=$(short_name "$file")
    if [[ ",$SKIP," == *",$name,"* ]]; then
        warn "skipping $name (SKIP)"
        return 0
    fi
    printf "\n${CYAN}===> %s${NC}\n" "$name"
    bash "$MODULES_DIR/$file"
}

if [[ -n "$ONLY" ]]; then
    IFS=',' read -ra mods <<< "$ONLY"
    for m in "${mods[@]}"; do
        run_module "$(resolve_module "$m")"
    done
else
    for path in "$MODULES_DIR"/*.sh; do
        run_module "$(basename "$path")"
    done
fi

printf "\n${GREEN}Done.${NC} Reminders:\n"
printf "  - log out/in (or 'newgrp docker') to use docker without sudo\n"
printf "  - open a new shell so nvm/node are on PATH\n"
