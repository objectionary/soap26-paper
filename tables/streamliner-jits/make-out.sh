#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

n=$(basename "$@" | ${SED} 's/.out//g')
v=$(echo "${n}" | cut -f2 -d'+')

if [ "${NUMBERS}" -gt 1 ]; then
    NUMBERS=1
fi

${MAKE} -e -C "${STREAMLINER_DIR}" "NUMBERS=${NUMBERS}" "JVM=${v}-${SDK}" clean jitless.csv
mkdir -p "$(dirname "${csv}")"

cp "${STREAMLINER_DIR}/jitless.csv" "${csv}"
