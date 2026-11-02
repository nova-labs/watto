#!/bin/bash
# The wautils half of provisioning, run on the server by deploy/provision:
# builds Ruby into ~/.rubies and sets up the git repo that deploys on push.
# Safe to re-run.

set -euo pipefail

# Don't trust sudo to set these: depending on the sudo, HOME and the working
# directory can still be the admin's, which wautils can't write to.
HOME=$(getent passwd "$(id -un)" | cut -d: -f6)
export HOME
cd "$HOME"

GIT_DIR=$HOME/git/watto
WORK_TREE=$HOME/srv/watto

here=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$WORK_TREE"
"$here/../bin/install-ruby" "$WORK_TREE/.env"

echo "==> Setting up the deploy repo"
[ -d "$GIT_DIR" ] || git init -q --bare --initial-branch=main "$GIT_DIR"
install -m 755 "$here/post-receive" "$GIT_DIR/hooks/post-receive"

if [ ! -f "$WORK_TREE/.env" ]; then
  echo
  echo "!! $WORK_TREE/.env is missing. Copy it from the current server before"
  echo "   the first deploy (see DEPLOY.md)."
fi
