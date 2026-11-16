# Dotfiles (chezmoi)

Personal dotfiles and system setup for Arch/Omarchy, managed with [`chezmoi`](https://www.chezmoi.io/).

## Applying Configuration

```bash
chezmoi diff
chezmoi apply
```

This repository uses a `gitleaks` pre-commit hook (`.pre-commit-config.yaml`) to prevent committing secrets.

---

## AI Coding Agent (`pi`) Setup

The `pi` agent configuration is managed at `dot_pi/agent/settings.json` (applied to `~/.pi/agent/settings.json`).

> **Note:** `pi`, `node`, and several other CLI tools are configured as lazy-loaded `mise` tools in `/etc/mise/conf.d/omarchy-tools.toml`.

### Configured `pi` Packages

- `git:github.com/richards-ensono/pi-openspec-status` — OpenSpec status widget & overlay
- `npm:@juicesharp/rpiv-ask-user-question` — Interactive terminal Q&A tool
- `npm:@juicesharp/rpiv-todo` — Persistent task tracking & overlay
- `npm:@narumitw/pi-usage` — Live provider quotas and limits
- `npm:@tmustier/pi-usage-extension` — Historical `/usage` session dashboard
- `npm:context-mode` — SQLite/FTS5 sidecar to reduce context bloat
- `npm:pi-simplify` — Post-edit code simplification loop
- `npm:pi-subagents` — Subagent delegation
- `npm:pi-web-access` — Web search and page fetch

### Installing OpenSpec CLI

Requires Node.js `>= 20.19.0` (or `22.12.0+`):

```bash
npm install -g @fission-ai/openspec@latest
openspec --version
```

To initialize OpenSpec in a project:

```bash
openspec init
```

### Installing / Verifying Context Mode

`npm:context-mode` (`mksglu/context-mode`, local SQLite/FTS5 extension with no cloud proxy) is already declared in `~/.pi/agent/settings.json`. If you also want to install it explicitly:

```bash
pi install npm:context-mode
```

Verify inside a `pi` session by running:

```bash
ctx stats
```

---

## Recent Changes (2026-11-13 to 2026-11-16)

### Dotfiles & Config (`chezmoi`)

- **2026-11-14:** Initialized `chezmoi` repo with Hyprland (`.lua`), Omarchy shell/menu/theme hooks, Ghostty, Zsh, Git (`defaultBranch = main`), GnuPG/YubiKey, and `gh` configs.
- **2026-11-15:** Configured `SSH_AUTH_SOCK` via `gpgconf` in `dot_zshrc`.
- **2026-11-16:**
  - Added `gitleaks` pre-commit hook (`.pre-commit-config.yaml`).
  - Added `scripts/rdp-molasses.sh` (credentials retrieved via `pass`).
  - Added Neovim (LazyVim) configuration (`dot_config/nvim/`) and removed Copilot plugins.
  - Updated Starship prompt (`dot_config/starship.toml`) to a Tokyo Night single-line layout with connected powerline segments.
  - Adopted Oh My Tmux (`dot_config/tmux/tmux.conf` + `tmux.conf.local`) merged with Omarchy settings.
  - Added `pi` package configuration (`dot_pi/agent/settings.json`).

### OS Packages (`pacman`)

- **2026-11-13:**
  - **Containers & sandboxing:** `podman`, `passt`, `netavark`, `aardvark-dns`, `fuse-overlayfs`
  - **Security & auth:** `keepassxc`, `pam-u2f`, `libfido2`
  - **Desktop & utilities:** `firefox`, `spotify`, `rclone`, `fwupd`
- **2026-11-14:**
  - **Dotfiles, shell & secrets:** `chezmoi`, `zsh`, `tree`, `pass`, `yubikey-manager`, `ccid`, `mise-bin` upgrade
  - **Apps:** `rawtherapee`, `rdesktop`
- **2026-11-15:**
  - **Toolchains & networking:** `clang`, `llvm`, `compiler-rt`, `nmap`
  - **Remote desktop:** `freerdp`, `rustdesk`, `xdotool`
- **2026-11-16:**
  - **Secrets & linting:** `gitleaks`, `pre-commit`
  - **JS/TS & AI tooling:** `pnpm`, `yarn`, `bun`, `ggml`, `llama-cpp`, `antigravity`
