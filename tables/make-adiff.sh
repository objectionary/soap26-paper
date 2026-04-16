#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

# shellcheck disable=SC1091
source ../functions.sh

j=$(basename "${csv}")
j=${j%.*}

mkdir -p "$(dirname "${csv}")"

loop_before=()
map_before=()
loop_after=()
map_after=()

while IFS= read -r d; do
    n=$(basename "${d}")
    n=${n%.*}
    jj=$(echo "${n}" | cut -f2 -d'+')
    if [ ! "${j}" == "${jj}" ]; then
        continue
    fi
    while IFS=',' read -r lb mb la ma; do
        loop_before+=("${lb}")
        map_before+=("${mb}")
        loop_after+=("${la}")
        map_after+=("${ma}")
    done < "${d}"
done < <(${FIND} diffs/ -name '*.csv')

${PRINTF} "%s,%f,%f,%f,%f,%f,%f,%f,%f\n" \
    "${j}" \
    "$(average "${loop_before[@]}")" "$(rsd "${loop_before[@]}")" \
    "$(average "${map_before[@]}")" "$(rsd "${map_before[@]}")" \
    "$(average "${loop_after[@]}")" "$(rsd "${loop_after[@]}")" \
    "$(average "${map_after[@]}")" "$(rsd "${map_after[@]}")" \
    > "$@"
