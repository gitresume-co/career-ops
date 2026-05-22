#!/usr/bin/env bash
# Run once after cloning this fork.
# Enables git rerere so previously-resolved upstream-merge conflicts replay automatically.
set -euo pipefail
cd "$(dirname "$0")/.."
git config rerere.enabled true
git config rerere.autoupdate true
git config merge.ours.driver true
echo "✓ rerere enabled (autoupdate on)"
echo "✓ merge=ours driver registered (used by .gitattributes)"
echo
echo "See docs/SYNC-UPSTREAM.md for the upstream sync workflow."
