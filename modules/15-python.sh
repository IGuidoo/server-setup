#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

apt_install_if_missing \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3
