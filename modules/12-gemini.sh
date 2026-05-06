#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

load_nvm
npm_install_global_if_missing gemini "@google/gemini-cli"
