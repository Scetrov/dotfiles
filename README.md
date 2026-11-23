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

### Gondolin Micro-VM Sandboxing (`pi-gondolin-mount`)

`npm:pi-gondolin-mount` (`abobco/pi-gondolin-mount`) routes `pi` tool calls (`bash`, `read`, `write`, `edit`) and `!` shell commands into an ephemeral Gondolin Linux micro-VM while keeping provider credentials on the host.

Requires QEMU (`qemu-system-x86` and `qemu-img` on Arch Linux):

```bash
sudo pacman -S qemu-system-x86 qemu-img
pi install npm:pi-gondolin-mount
```

- By default, the current working directory is mounted read-write at `/workspace`.
- Add a `pi-gondolin-mount-config.yml` in a project directory to mount extra host paths using `<host-dir>:<guest-dir>:<ro|rw>` syntax (automatically masked inside the VM).

---

## KeePassXC & Google Drive Sync (`rclone bisync`)

Two-way synchronization of `HomePasswords.kdbx` between `~/Passwords/` and the `Passwords/` folder in Google Drive (`gdrive:Passwords`), keeping a real local copy for offline reliability and safe KeePassXC atomic saves.

> **Secrets notice:** `~/.config/rclone/rclone.conf` is intentionally **not** tracked in this repository because it stores Google OAuth credentials (`client_id`, `client_secret`, and refresh `token`). Configure the `gdrive` remote once per machine.

### Managed Files

- `dot_local/bin/executable_kdbx-sync` → `~/.local/bin/kdbx-sync` — wrapper around `rclone bisync` with `flock` locking, 3s save debounce, SHA-256 loop prevention, local-only timestamped backups (retaining the 20 most recent in `~/.local/share/kdbx-backups/`), missing/empty local file guard, and conflict desktop notifications. Defaults can be overridden via `KDBX_SYNC_DIR` (`~/Passwords`), `KDBX_SYNC_FILE` (`HomePasswords.kdbx`), and `KDBX_SYNC_REMOTE` (`gdrive:Passwords`).
- `dot_config/rclone/kdbx-bisync-filters.txt` → `~/.config/rclone/kdbx-bisync-filters.txt` — restricts bisync strictly to `/HomePasswords.kdbx` (and any `.conflict*` copies) inside `gdrive:Passwords/`, ignoring all other files/databases/subfolders in `Passwords/` and KeePassXC `.lock`/`.tmp` files.
- `dot_config/systemd/user/kdbx-sync.{service,timer}` → `~/.config/systemd/user/` — pulls/syncs every 5 minutes (and 30s after login).
- `dot_config/systemd/user/kdbx-sync-watch.{service,path}` → `~/.config/systemd/user/` — watches `~/Passwords` and pushes local saves within ~3 seconds.

### Setup on a New Machine (Arch / Omarchy)

1. **Install packages:**

   ```bash
   omarchy pkg add rclone keepassxc qt5-wayland
   # or on plain Arch:
   # sudo pacman -S rclone keepassxc qt5-wayland
   ```

2. **Apply dotfiles:**

   ```bash
   chezmoi apply
   ```

3. **Authorize `rclone` with your Google Cloud OAuth app** (keeps credentials out of shell history):

   ```bash
   bash -c 'read -rp "Client ID: " CID && read -rsp "Client Secret: " CSEC && echo && rclone config create gdrive drive scope=drive client_id="$CID" client_secret="$CSEC"'
   ```

   - Answer **`n`** if prompted to configure as a Shared Drive (Team Drive).
   - **Prevent 7-day token expiry:** In [Google Cloud Console](https://console.cloud.google.com/), open **Google Auth Platform → Audience** *(or **APIs & Services → OAuth consent screen**)* and set **Publishing status** to **In production** (click **Publish App**; full Google verification is not needed for personal use). During sign-in, click **Advanced → Go to `<app>` (unsafe) → Continue**. If you published after already authorizing, run `rclone config reconnect gdrive:` once.

4. **Run the initial resync:**

   ```bash
   kdbx-sync --resync
   ```

5. **Enable background sync:**

   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now kdbx-sync.timer kdbx-sync-watch.path
   ```

6. **Open in KeePassXC:** Open `~/Passwords/HomePasswords.kdbx` and ensure **Settings → General → Automatically reload the database when modified externally** is enabled.

### Useful Commands

```bash
kdbx-sync                                                           # Manual two-way sync
kdbx-sync --resync                                                  # Re-initialize bisync state
rclone config reconnect gdrive:                                     # Refresh OAuth token
journalctl --user -u kdbx-sync.service -u kdbx-sync-watch.service   # View sync logs
systemctl --user stop kdbx-sync.timer kdbx-sync-watch.path          # Pause background sync
systemctl --user start kdbx-sync.timer kdbx-sync-watch.path         # Resume background sync
```

### Multi-Device, Conflict & Duplicate Handling

- **Canonical Drive path:** Point every KeePass client/device to **`My Drive/Passwords/HomePasswords.kdbx`** (not `My Drive` root and not Google Drive's **Computers** backup section, which `rclone` does not list).
- **Google Drive duplicates:** Because Google Drive permits multiple files with the same name in a folder, `rclone` logs `Duplicate object found in destination - ignoring` if a second `HomePasswords.kdbx` is created alongside the original. Pause the systemd units before resolving duplicates.
- **Merging diverged copies:** If a `.conflict*` file or backup copy in `~/.local/share/kdbx-backups/` diverges, preview and merge safely with KeePassXC (**Database → Merge from Database...**) or `keepassxc-cli`:

  ```bash
  keepassxc-cli merge -s -d <target.kdbx> <other.kdbx>   # Dry-run diff (read-only)
  keepassxc-cli merge -s <target.kdbx> <other.kdbx>      # Merge changes (keeps history)
  ```

  After replacing `~/Passwords/HomePasswords.kdbx`, push in-place with `rclone copyto ~/Passwords/HomePasswords.kdbx gdrive:Passwords/HomePasswords.kdbx`, remove any extra Drive copies, run `kdbx-sync --resync`, and resume the systemd units.

---

## Recent Changes (2026-11-13 to 2026-11-23)

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
- **2026-11-22:**
  - Added KeePassXC + Google Drive `rclone bisync` script (`dot_local/bin/executable_kdbx-sync`), single-file filter (`dot_config/rclone/kdbx-bisync-filters.txt`), and `systemd --user` timer + save watcher units (`dot_config/systemd/user/kdbx-sync*`).
- **2026-11-23:**
  - Moved `kdbx-sync` remote target from `gdrive:` (root) to `gdrive:Passwords` and updated filter comments and `README.md` with multi-device, pause/resume, and merge recovery documentation.

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
  - **Virtualization & sandboxing:** `qemu-system-x86`, `qemu-img` (for Gondolin micro-VMs)
