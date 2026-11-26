#!/bin/bash
# First-time setup for a fresh Mac (nothing installed, not even git).
# Not meant to be run from the checkout; paste the one-liner from the README:
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/muncherelli/macos-bootstrap/golden-gate-headless/install.sh)"
#
# It installs Homebrew and uv, clones this branch, then hands off to update.sh,
# which is what you run from then on. Extra arguments go to ansible-playbook.

set -euo pipefail

BRANCH="golden-gate-headless"
REPO="https://github.com/muncherelli/macos-bootstrap.git"
DEST="${HOME}/Development/macos-bootstrap"

die() { echo "error: $*" >&2; exit 1; }

# Everything is inside main(), called on the last line, so a download that was
# cut short cannot run half of this script.
main() {
    # Homebrew: its installer also brings the Xcode Command Line Tools (git).
    if [[ ! -x /opt/homebrew/bin/brew ]]; then
        echo "==> Installing Homebrew"
        local installer
        installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ||
            die "could not download the Homebrew installer"
        /bin/bash -c "$installer"
    fi
    [[ -x /opt/homebrew/bin/brew ]] || die "Homebrew is not at /opt/homebrew after installation"
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Over SSH the Command Line Tools install can fail quietly; check for git.
    xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1 ||
        die "git is not available. Install the Xcode Command Line Tools (xcode-select --install at the Mac) and run this again"

    # uv: provides the pinned Python and the pinned Ansible (see pyproject.toml).
    command -v uv >/dev/null || { echo "==> Installing uv"; brew install uv; }

    if [[ ! -d "${DEST}/.git" ]]; then
        echo "==> Cloning ${BRANCH} into ${DEST}"
        mkdir -p "$(dirname "$DEST")"
        git clone --branch "$BRANCH" "$REPO" "$DEST"
    fi

    exec "${DEST}/update.sh" "$@"
}

main "$@"
