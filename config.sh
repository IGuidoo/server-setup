#!/usr/bin/env bash
# Edit versions / toggles here. Sourced by install.sh and modules.

TIMEZONE="${TIMEZONE:-Europe/Amsterdam}"

NVM_VERSION="${NVM_VERSION:-v0.40.1}"
NODE_VERSION="${NODE_VERSION:-lts/*}"     # e.g. "20", "lts/*", "lts/iron"
PNPM_VERSION="${PNPM_VERSION:-latest}"
TURBO_VERSION="${TURBO_VERSION:-latest}"

# Git identity. Leave empty to be prompted.
GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"

# Comma-separated module short names to skip, e.g. SKIP="postgres,gemini"
SKIP="${SKIP:-}"
