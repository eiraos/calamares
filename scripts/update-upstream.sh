#!/bin/bash
set -euo pipefail

UPSTREAM_URL="https://gitlab.manjaro.org/applications/calamares.git"
UPSTREAM_BRANCH="development"

WORKING_DIR="$(pwd)"
TEMPORARY_DIR="/tmp/calamares-repo-upstream"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[*] Running in DRY-RUN mode (no commit, no push)"
fi

echo "[*] Clone upstream ($UPSTREAM_BRANCH)..."
rm -rf "$TEMPORARY_DIR"
git clone --single-branch --depth 1 -b "$UPSTREAM_BRANCH" "$UPSTREAM_URL" "$TEMPORARY_DIR"

echo "[*] Sync upstream files..."
if $DRY_RUN; then
    rsync -av --delete --exclude=".git" --dry-run "$TEMPORARY_DIR"/ "$WORKING_DIR"/
    exit 0
else
    rsync -a --delete --exclude=".git" "$TEMPORARY_DIR"/ "$WORKING_DIR"/
fi

pushd "$WORKING_DIR" > /dev/null

if ! git diff --quiet; then
    COMMIT_MESSAGE="[merge] upstream $(date '+%Y-%m-%d %H:%M:%S')"
    echo "[*] Commit changes: $COMMIT_MESSAGE"
    git add .
    git commit -m "$COMMIT_MESSAGE"
    git push origin main
    echo "[✔] Sync done & pushed!"
else
    echo "[=] No changes to commit."
fi

rm -rf $TEMPORARY_DIR

popd > /dev/null
