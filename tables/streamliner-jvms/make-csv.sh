#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

# shellcheck disable=SC1091
source ../functions.sh

v=$(basename "${csv}")
v=${v//\.csv/}

rm -rf "benches/${v}"
mkdir -p "benches/${v}"

while IFS= read -r f; do
    while IFS= read -r ln; do
        bench=$(echo "${ln}" | cut -f6 -d. | cut -f1 -d'"')
        ms=$(echo "${ln}" | cut -f5 -d,)
        opt=$(${GREP} -F "dk.casa.streamliner.jmh.TestStreamOpt.${bench}\"" "${f}" | cut -f5 -d,)
        ${PRINTF} "%s,%s\n" "${ms}" "${opt}" >> "benches/${v}/${bench}.csv"
    done < <(${GREP} -F 'dk.casa.streamliner.jmh.TestStream.' "${f}")
done < <(${FIND} . -name "*+${v}.out")

(
    while IFS= read -r f; do
        ms=()
        opt=()
        bench=$(basename "${f}" | ${SED} 's/.csv//g')
        while IFS=',' read -r m o; do
            ms+=("${m}")
            opt+=("${o}")
        done < "${f}"
        ${PRINTF} '%s,%f,%f,%f,%f\n' "${bench}" \
            "$(average "${ms[@]}")" "$(rsd "${ms[@]}")" \
            "$(average "${opt[@]}")" "$(rsd "${opt[@]}")"
    done < <(${FIND} "benches/${v}" -name '*.csv')
) > "${csv}"
