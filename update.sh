#!/bin/bash
# Pull the latest commit of this branch, then apply the playbook.
# Run it from the checkout any time:
#
#   ./update.sh                          everything
#   ./update.sh --tags macos             only the macOS settings
#   ./update.sh -e computer_name=devbox  also set the computer name
#
# Extra arguments go to ansible-playbook.

set -euo pipefail

# Everything is inside main() so bash has read the whole file before `git pull`
# can replace it underneath the running script.
main() {
    cd "$(dirname "${BASH_SOURCE[0]}")"
    eval "$(/opt/homebrew/bin/brew shellenv)"

    echo "==> Pulling updates"
    git pull --ff-only || {
        echo "error: could not fast-forward. Commit, stash or discard the local changes" >&2
        echo "       that conflict (see: git status), then run ./update.sh again." >&2
        exit 1
    }

    echo "==> Installing Ansible collections"
    uv run ansible-galaxy collection install -r requirements.yml

    echo "==> Running the playbook (asks for your sudo password)"
    exec uv run ansible-playbook playbook.yml --ask-become-pass "$@"
}

main "$@"
