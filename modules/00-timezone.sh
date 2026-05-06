#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

TIMEZONE="${TIMEZONE:-Europe/Amsterdam}"
CURRENT="$(timedatectl show -p Timezone --value 2>/dev/null || echo unknown)"

if [[ "$CURRENT" == "$TIMEZONE" ]]; then
    ok "timezone already $TIMEZONE"
else
    log "setting timezone $CURRENT -> $TIMEZONE"
    sudo timedatectl set-timezone "$TIMEZONE"
fi
