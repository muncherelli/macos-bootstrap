# macOS bootstrap

Ansible setup for a headless macOS development box: Homebrew packages, Dock layout, shell tooling (Oh My Zsh, Powerlevel10k, fonts, plugins), dev toolchains, and macOS system defaults.

The **golden-gate-headless** branch is a minimal variant of **golden-gate** for a development-only Mac that is mostly reached over SSH: no GUI apps, no Mac App Store installs, a Dock with only Safari, and CLI dev toolchains (Node via nvm, Python via uv, Go, Rust, and Docker via Colima). It targets **macOS 27 Golden Gate** on **Apple Silicon** (Homebrew at `/opt/homebrew`).

## Install

On a fresh Mac with nothing installed (not even git), paste this into Terminal or an SSH session:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/muncherelli/macos-bootstrap/golden-gate-headless/install.sh)"
```

That one command:

1. Installs **Homebrew**, which brings the Xcode Command Line Tools and with them git.
2. Installs **uv**, which provides the pinned Python and the pinned Ansible.
3. Clones this branch into `~/Development/macos-bootstrap`.
4. Runs the playbook. You are asked for your password by the Homebrew installer and once more by Ansible.

To set the computer name in the same run, add it to the end:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/muncherelli/macos-bootstrap/golden-gate-headless/install.sh)" "" -e computer_name=devbox
```

### Full Disk Access (Safari settings only)

Safari's preferences are sandboxed, so those few settings need Full Disk Access. Without it the run still completes and prints a notice; grant access and run again.

- At the Mac: **System Settings → Privacy & Security → Full Disk Access**, add **Terminal**.
- Over SSH: **System Settings → General → Sharing → Remote Login → (i) → Allow full disk access for remote users**.

## Re-running

From the checkout, after editing anything:

```bash
cd ~/Development/macos-bootstrap
./install.sh                 # everything
./install.sh --tags macos    # only the macOS settings
```

Run this way, `install.sh` uses the checkout as it is. Pasting the one-liner again instead pulls the latest commit of the branch first. Every task is idempotent, and services such as the Dock or Finder restart only when one of their settings changed.

## Pinned Python and Ansible

Ansible does not come from Homebrew. `uv` builds a virtualenv in `.venv/` from:

| File | Pins |
|------|------|
| `.python-version` | The Python that runs Ansible and its modules |
| `pyproject.toml` | The Ansible release |
| `uv.lock` | Every Python dependency, exactly (created by the first run; commit it) |
| `requirements.yml` | The `geerlingguy.mac` collection version, installed into `collections/` |

To upgrade, change the version in the relevant file, run `uv lock`, and commit.

## Always-on settings

The playbook sets the Mac to never sleep on mains power, wake for network access, start up again after a power failure, and restart if it freezes, so it stays reachable over SSH. Screen Sharing is not touched; enable it by hand if you want it.

## Containers

Docker runs through **Colima** (a CLI-managed Linux VM) instead of Docker Desktop. Start it once after a boot, then use `docker` and `docker compose` as usual:

```bash
colima start
```

## Repository layout

| File | Role |
|------|------|
| `install.sh` | The only shell script: Homebrew, uv, clone, then runs the playbook |
| `playbook.yml` | Packages, computer name, Dock, shell, dev toolchains, power settings, restart handlers |
| `tasks/macos.yml` | macOS UI, Finder, Dock, Spotlight and Safari preferences |
| `pyproject.toml`, `.python-version` | Python and Ansible versions for uv |
| `requirements.yml` | Ansible collection dependencies |
| `ansible.cfg`, `inventory` | Local connection, using the same Python as Ansible itself |

## License

See [LICENSE](LICENSE).
