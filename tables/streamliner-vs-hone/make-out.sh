#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

n=$(basename "${csv}")
n=${csv//.out/}
v=$(echo "${n}" | cut -f2 -d'+')

make -C "${STREAMLINER_DIR}" clean out.csv -e "JVM=${v}-${JVM_SUFFIX}"

mkdir -p "$(dirname "${csv}")"
cp "${STREAMLINER_DIR}/out.csv" "${csv}"
