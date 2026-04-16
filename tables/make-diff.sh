#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

n=$(basename "${csv}")
n=${n%.*}

mkdir -p "$(dirname "${csv}")"

${PRINTF} "%f,%f,%f,%f\n" \
    "$(${GREP} -F '.loop' "before/${n}.csv" | cut -f5 -d ',')" \
    "$(${GREP} -F '.map' "before/${n}.csv" | cut -f5 -d ',')" \
    "$(${GREP} -F '.loop' "after/${n}.csv" | cut -f5 -d ',')" \
    "$(${GREP} -F '.map' "after/${n}.csv" | cut -f5 -d ',')" \
    > "${csv}"
