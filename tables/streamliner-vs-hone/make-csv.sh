#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

# shellcheck disable=SC1091
source ../functions.sh

if [ "$csv" == 'old.csv' ]; then
    v=${JVM_OLD}
else
    v=${JVM_NEW}
fi

rm -rf "benches/${v}"
mkdir -p "benches/${v}"

while IFS= read -r f; do
    n=$(basename "${f}" | ${SED} 's/.out//g')
    while IFS= read -r ln; do
        bench=$(echo "${ln}" | cut -f6 -d. | cut -f1 -d'"')
        ms=$(echo "${ln}" | cut -f5 -d,)
        opt=$(${GREP} -F "TestStreamOpt.${bench}\"" "outs/${n}.out" | cut -f5 -d,)
        hopt=$(${GREP} -F "TestStreamOpt.${bench}\"" "hones/${n}.hone" | cut -f5 -d,)
        ${PRINTF} '%s,%s,%s\n' "${ms}" "${opt}" "${hopt}" >> "benches/${v}/${bench}.csv"
    done < <(${GREP} -F 'dk.casa.streamliner.jmh.TestStream.' "${f}")
done < <(find . -name "*+${v}.out")

(
    while IFS= read -r f; do
        ms=()
        opt=()
        hopt=()
        bench=$(basename "${f}" | ${SED} 's/.csv//g')
        while IFS=',' read -r m o h; do
            ms+=("${m}")
            opt+=("${o}")
            hopt+=("${h}")
        done < "${f}"
        ${PRINTF} '%s,%f,%f,%f,%f,%f,%f\n' "${bench}" \
            "$(average "${ms[@]}")" "$(rsd "${ms[@]}")" \
            "$(average "${opt[@]}")" "$(rsd "${opt[@]}")" \
            "$(average "${hopt[@]}")" "$(rsd "${hopt[@]}")"
    done < <(find "benches/${v}" -name '*.csv' | sort)
) > "${csv}"
