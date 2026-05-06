# server-setup

Idempotent install scripts for a fresh Ubuntu Server VM. Sets up dev tools, dotfiles, git identity, and an SSH key. Each module checks state before acting, so re-running is safe.

## Quick start

On a fresh VM, logged in as your sudo-capable user (**not** root):

```bash
sudo apt-get update && sudo apt-get install -y git
git clone <this-repo-url> ~/server-setup
cd ~/server-setup
./install.sh
```

## What gets installed

| Module           | What it does |
|------------------|--------------|
| `00-timezone`    | Sets timezone (default `Europe/Amsterdam`) |
| `01-system`      | `build-essential`, `curl`, `wget`, `gnupg`, etc. |
| `02-git`         | git |
| `03-gh`          | GitHub CLI (official apt repo) |
| `04-nvm-node`    | nvm + Node LTS |
| `05-pnpm`        | pnpm (via npm) |
| `06-turbo`       | turbo (via npm) |
| `07-docker`      | Docker CE + buildx + compose plugin; adds user to `docker` group |
| `08-postgres`    | PostgreSQL + contrib, enabled and started |
| `09-bat`         | bat (symlinks `batcat` → `bat`) |
| `10-claude-code` | `@anthropic-ai/claude-code` |
| `11-codex`       | `@openai/codex` |
| `12-gemini`      | `@google/gemini-cli` |
| `13-lazygit`     | apt where available, else GitHub release tarball |
| `14-uv`          | Astral uv |
| `15-python`      | `python3`, `pip`, `venv`, `python` → `python3` |
| `16-zsh`         | zsh, fzf, fd, zoxide, tmux, neovim, locales; deploys dotfiles; sets default shell |
| `17-git-config`  | Global git identity + `init.defaultBranch=main` |
| `18-ssh-key`     | ed25519 SSH key (prints pubkey for GitHub) |

## Configuration

Edit `config.sh`, or set the variables in your environment before running.

| Variable | Default | Notes |
|----------|---------|-------|
| `TIMEZONE` | `Europe/Amsterdam` | |
| `NVM_VERSION` | `v0.40.1` | |
| `NODE_VERSION` | `lts/*` | nvm spec, e.g. `20`, `lts/iron` |
| `PNPM_VERSION` | `latest` | |
| `TURBO_VERSION` | `latest` | |
| `GIT_NAME` / `GIT_EMAIL` | _(prompted)_ | global git identity |
| `SKIP` | _(empty)_ | comma-separated short names to skip |

## Usage

```bash
./install.sh                          # run everything
./install.sh --list                   # list available modules
./install.sh --only docker,gh         # run a subset (short names)
SKIP=postgres,gemini ./install.sh     # skip some
```

## Dotfiles

`dotfiles/` is committed. The `16-zsh` module symlinks them into `$HOME`; existing files are renamed to `*.backup-<timestamp>` first.

- `.zshrc` — zinit-managed, Powerlevel10k, fzf-tab, common plugins, NVM/PNPM PATH, history, aliases
- `.p10k.zsh` — Powerlevel10k config
- `.tmux.conf` — placeholder

zinit clones itself on first zsh start and installs every plugin (~30s once).

## After install

1. **Re-login** (or `newgrp docker` + `exec zsh`) so the docker group, default shell, and updated PATH are picked up.
2. **Install a Nerd Font on your client.** Server fonts are irrelevant over SSH — Powerlevel10k icons render in your terminal app. Default for p10k is MesloLGS NF.
3. **Add the printed pubkey to GitHub** at https://github.com/settings/ssh/new. Test with:
   ```bash
   ssh -T git@github.com
   ```

## Adding a module

Drop a file into `modules/` named `NN-<short>.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

if have_cmd mytool; then
    ok "mytool already installed: $(mytool --version)"
    exit 0
fi
# install logic
```

Helpers in `lib/common.sh`: `log`, `ok`, `warn`, `error`, `have_cmd`, `apt_install_if_missing`, `ensure_apt_updated`, `load_nvm`, `npm_install_global_if_missing`.

Modules are run alphabetically. Idempotency is the contract — every module must be safe to run repeatedly.

## Layout

```
server-setup/
├── install.sh         # entry point
├── config.sh          # versions + identity
├── lib/common.sh      # shared helpers
├── modules/           # one file per tool, NN-<short>.sh
└── dotfiles/          # symlinked into $HOME by 16-zsh
```
