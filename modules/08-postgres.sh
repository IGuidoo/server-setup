#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

if have_cmd psql; then
    ok "postgres already installed: $(psql --version)"
else
    apt_install_if_missing postgresql postgresql-contrib
fi

if ! systemctl is-enabled --quiet postgresql 2>/dev/null; then
    log "enabling postgresql service"
    sudo systemctl enable postgresql
fi
if ! systemctl is-active --quiet postgresql; then
    log "starting postgresql service"
    sudo systemctl start postgresql
fi
