#!/bin/bash
# The only shell script in this repo: it gets a bare Mac to the point where
# Ansible can run, then Ansible does everything else.
#
# Fresh Mac (nothing installed, not even git), paste:
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/muncherelli/macos-bootstrap/golden-gate-headless/install.sh)"
#
# Later, from inside the checkout, apply local changes with:  ./install.sh
#
# Extra arguments go to ansible-playbook, for example:
#   ./install.sh --tags macos
#   ./install.sh -e computer_name=devbox

set -euo pipefail

BRANCH="golden-gate-headless"
REPO="https://github.com/muncherelli/macos-bootstrap.git"
DEST="${HOME}/Development/macos-bootstrap"

# Homebrew: its installer also brings the Xcode Command Line Tools (and so git).
if [[ ! -x /opt/homebrew/bin/brew ]]; then
    echo "==> Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# uv: provides the pinned Python and the pinned Ansible (see pyproject.toml).
command -v uv >/dev/null || { echo "==> Installing uv"; brew install uv; }

# Run as a file inside a checkout: use that checkout as it is.
# Piped from curl: clone the branch, or update an existing clone.
here="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || true)"
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${here}/playbook.yml" ]]; then
    cd "$here"
elif [[ -d "${DEST}/.git" ]]; then
    echo "==> Updating ${DEST} (${BRANCH})"
    git -C "$DEST" fetch origin "$BRANCH"
    git -C "$DEST" switch "$BRANCH"
    git -C "$DEST" pull --ff-only origin "$BRANCH"
    cd "$DEST"
else
    echo "==> Cloning ${BRANCH} into ${DEST}"
    mkdir -p "$(dirname "$DEST")"
    git clone --branch "$BRANCH" "$REPO" "$DEST"
    cd "$DEST"
fi

echo "==> Installing Ansible collections"
uv run ansible-galaxy collection install -r requirements.yml

echo "==> Running the playbook (asks for your sudo password)"
exec uv run ansible-playbook playbook.yml --ask-become-pass "$@"
