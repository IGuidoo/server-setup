#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

DOTFILES_DIR="$(cd "$(dirname "$0")/../dotfiles" && pwd)"

apt_install_if_missing zsh fzf fd-find zoxide tmux neovim locales

# Generate en_US.UTF-8 (referenced by .zshrc).
if ! locale -a 2>/dev/null | grep -qix 'en_US.utf8'; then
    log "generating en_US.UTF-8 locale"
    sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sudo locale-gen en_US.UTF-8
else
    ok "en_US.UTF-8 locale already present"
fi

# Ubuntu installs fd as 'fdfind' to avoid a name clash; expose it as 'fd'.
mkdir -p "$HOME/.local/bin"
if ! have_cmd fd && have_cmd fdfind; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    log "symlinked fdfind -> ~/.local/bin/fd"
fi

deploy_dotfile() {
    local src="$1" dst="$2"
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        ok "$(basename "$dst") already symlinked"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        local backup="${dst}.backup-$(date +%Y%m%d-%H%M%S)"
        log "backing up existing $(basename "$dst") -> $(basename "$backup")"
        mv "$dst" "$backup"
    fi
    log "linking $(basename "$dst") -> $src"
    ln -s "$src" "$dst"
}

deploy_dotfile "$DOTFILES_DIR/.zshrc"     "$HOME/.zshrc"
deploy_dotfile "$DOTFILES_DIR/.p10k.zsh"  "$HOME/.p10k.zsh"
deploy_dotfile "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
    ok "zsh already default shell"
else
    log "setting zsh as default shell for $USER"
    sudo chsh -s "$ZSH_PATH" "$USER"
fi

