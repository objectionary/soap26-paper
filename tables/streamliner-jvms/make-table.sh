#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

tex=$1

# shellcheck disable=SC1091
source ../functions.sh

(
    ${PRINTF} '\\begin{tabularx}{\\linewidth}{X|>{\\ttfamily}r>{\\ttfamily}r|>{\\ttfamily}r>{\\ttfamily}r|>{\\ttfamily}r>{\\ttfamily\\arraybackslash}r}\n'
    ${PRINTF} '\\toprule\n'
    ${PRINTF} 'Benchmark'
    c=0
    columns=$(${GREP} -o ' ' <<< "${VERSIONS}" | wc -l)
    for version in ${VERSIONS}; do
        ${PRINTF} ' & \\multicolumn{2}{c%s}{%s %s} ' "$(if [ "${c}" -lt "${columns}" ]; then ${PRINTF} '|'; fi)" "${SDK}" "${version}"
        c=$(( c + 1 ))
    done
    ${PRINTF} '\\\\\n'
    for version in ${VERSIONS}; do
        ${PRINTF} ' & {\\rmfamily Ratio} & {\\rmfamily RSD}'
    done
    ${PRINTF} '\\\\\n'
    ${PRINTF} '\\midrule\n'
    while IFS= read -r bench; do
        ${PRINTF} '  \\texttt{%s} ' "${bench}"
        c=0
        for version in ${VERSIONS}; do
            ln=$(${GREP} -F "${bench}," "${version}.csv")
            ms=$(echo "${ln}" | cut -f2 -d,)
            ms_rsd=$(echo "${ln}" | cut -f3 -d,)
            opt=$(echo "${ln}" | cut -f4 -d,)
            opt_rsd=$(echo "${ln}" | cut -f5 -d,)
            if awk "BEGIN {exit !(${ms} > 0)}"; then
                ${PRINTF} ' & %s & %s ' \
                    "$(ratio "$(perl -E "say ${opt} / ${ms}")")" \
                    "$(per "$(perl -E "say (${opt_rsd} + ${ms_rsd})/2")")"
            else
                ${PRINTF} ' & \\multicolumn{2}{c%s}{\\texttt{n/a}}' "$(if [ "${c}" -lt "${columns}" ]; then ${PRINTF} '|'; fi)"
            fi
            c=$(( c + 1 ))
        done
        ${PRINTF} '\\\\\n'
    done < <(cut -f1 -d, "$(head -2 versions.txt | tail -1).csv" | sort)
    ${PRINTF} '\\bottomrule\n'
    ${PRINTF} '\\end{tabularx}\n'
) > "${tex}"
