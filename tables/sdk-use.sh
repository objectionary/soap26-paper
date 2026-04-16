#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

jvm=$1

# shellcheck disable=SC1091
source "${HOME}/.sdkman/bin/sdkman-init.sh"

if [ ! -e "${HOME}/.sdkman/candidates/java/${jvm}" ]; then
    sdk install java "${jvm}" --default <<< "Y"
fi

sdk default java "${jvm}" <<< "Y"

echo "Switched to Java ${jvm}"
