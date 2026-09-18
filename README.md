# macOS bootstrap

Ansible-driven setup for a new Mac: Homebrew packages and casks, Mac App Store apps, Dock layout, shell tooling (Oh My Zsh, fonts, plugins), and system defaults via `defaults` in `os.sh`.

The **golden-gate** branch targets **macOS 27 Golden Gate** (Apple Silicon). System apps live under `/System/Applications` (no `/Applications` shims except Safari), and `os.sh` uses Golden Gate preference keys for Liquid Glass, Spotlight, and Finder.

## Prerequisites

- **macOS 27 Golden Gate** (this repo assumes **Apple Silicon** and Homebrew at `/opt/homebrew`, matching `init.sh`.)
- **Full Disk Access for Terminal** before you run `update.sh`, or the playbook cannot read protected paths. Open **System Settings → Privacy & Security → Full Disk Access**, add **Terminal**, then restart Terminal if needed.

## Quick start

1. **Clone and enter the repo**

   ```bash
   git clone https://github.com/muncherelli/macos-bootstrap.git
   cd macos-bootstrap
   ```

2. **First run: tooling and hostname**

   Run `init.sh` once on a clean machine. It installs **Homebrew** and **Ansible**, prompts for **Computer Name / HostName / LocalHostName**, and optionally reboots.

   ```bash
   ./init.sh
   ```

3. **Customize**

   - **`playbook.yml`** — Homebrew formulae and casks, `mas` apps, Dock items, fonts, Zsh theme/plugins, and it runs `os.sh` as part of the play.
   - **`os.sh`** — `defaults write` and other macOS UI and Finder preferences.

4. **Apply software and settings**

   ```bash
   ./update.sh
   ```

   This installs Ansible collections from `requirements.yml`, then runs `ansible-playbook playbook.yml` (with `sudo` when prompted).

## Re-running

Use **`./update.sh`** whenever you change `playbook.yml`, `os.sh`, or roles. Run **`./init.sh`** only when you still need Homebrew/Ansible or want to change the machine name again.

## Mac App Store apps

The playbook uses **`mas`** for App Store installs. Sign in first if those tasks fail, for example:

```bash
mas signin
```

## Repository layout

| File | Role |
|------|------|
| `init.sh` | Installs Homebrew and Ansible; optional hostname change and reboot |
| `update.sh` | Verifies Full Disk Access; `ansible-galaxy install`; runs the playbook |
| `playbook.yml` | Main Ansible play (Homebrew, `mas`, Dock, shell, invokes `os.sh`) |
| `os.sh` | macOS defaults and preferences (called from the playbook) |
| `requirements.yml` | Ansible collection dependencies (`geerlingguy.mac`) |
| `ansible.cfg` | Local inventory and interpreter settings |
| `inventory` | `localhost` over SSH local connection |

## License

See [LICENSE](LICENSE).
