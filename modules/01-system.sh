#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/common.sh"

ensure_apt_updated
apt_install_if_missing \
    build-essential \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    software-properties-common \
    apt-transport-https
