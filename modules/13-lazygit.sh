#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

if have_cmd lazygit; then
    ok "lazygit already installed: $(lazygit --version | head -1)"
    exit 0
fi

# Prefer apt (Ubuntu 24.04+ has it in universe).
if apt-cache madison lazygit 2>/dev/null | grep -q .; then
    apt_install_if_missing lazygit
    exit 0
fi

log "lazygit not in apt — installing from GitHub release"
case "$(uname -m)" in
    x86_64)        ARCH="x86_64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "unsupported arch: $(uname -m)"; exit 1 ;;
esac

VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep -Po '"tag_name": "v\K[^"]*')
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VERSION}_Linux_${ARCH}.tar.gz" \
    -o "$TMP/lazygit.tar.gz"
tar -xf "$TMP/lazygit.tar.gz" -C "$TMP" lazygit
sudo install -m 0755 "$TMP/lazygit" /usr/local/bin/lazygit
log "installed lazygit $VERSION"
