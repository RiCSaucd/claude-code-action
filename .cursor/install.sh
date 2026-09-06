#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for claude-code-action.
#
# This repository is a Bun project (see CLAUDE.md). The base image does not ship
# Bun, so this script installs the pinned Bun toolchain and then restores
# dependencies from the committed bun.lock.
#
# Network requirements (must be in the Cloud Agent egress allowlist):
#   - bun.sh                            (Bun installer script)
#   - release-assets.githubusercontent.com  (Bun binary download target)
#   - registry.npmjs.org               (bun install package downloads)
set -euo pipefail

# Match the Bun version pinned in .github/workflows/ci.yml.
BUN_VERSION="1.2.12"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Install the pinned Bun toolchain only when it is missing or the wrong version.
# Keeps the install phase idempotent across repeated runs and warm snapshots.
if ! command -v bun >/dev/null 2>&1 || [ "$(bun --version 2>/dev/null)" != "$BUN_VERSION" ]; then
  echo "Installing Bun v${BUN_VERSION}..."
  curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}"
fi

bun --version

# Restore dependencies exactly as locked; fails instead of rewriting bun.lock.
bun install --frozen-lockfile
