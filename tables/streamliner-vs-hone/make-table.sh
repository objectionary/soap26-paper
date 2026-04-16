#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

tex=$1

# shellcheck disable=SC1091
source ../functions.sh

(
    ${PRINTF} '\\begin{tabularx}{\\linewidth}{X|>{\\ttfamily}r>{\\ttfamily}r>{\\ttfamily}r>{\\ttfamily}r|>{\\ttfamily}r>{\\ttfamily}r>{\\ttfamily}r>{\\ttfamily\\arraybackslash}r}\n'
    ${PRINTF} '\\toprule\n'
    ${PRINTF} 'Benchmark'
    ${PRINTF} ' & \\multicolumn{4}{c|}{%s %s} ' "${JVM}" "${JVM_OLD}"
    ${PRINTF} ' & \\multicolumn{4}{c}{%s %s} ' "${JVM}" "${JVM_NEW}"
    ${PRINTF} '\\\\\n'
    for _ in {1..2}; do
        ${PRINTF} '  & {\scshape Strm} & \(\pm\)RSD & \hone{} & \(\pm\)RSD'
    done
    ${PRINTF} '\\\\\n'
    ${PRINTF} '\\midrule\n'
    while IFS= read -r ln; do
        bench=$(echo "${ln}" | cut -f1 -d,)
        ms1=$(echo "${ln}" | cut -f2 -d,)
        ms1_rsd=$(echo "${ln}" | cut -f3 -d,)
        opt1=$(echo "${ln}" | cut -f4 -d,)
        opt1_rsd=$(echo "${ln}" | cut -f5 -d,)
        hopt1=$(echo "${ln}" | cut -f6 -d,)
        hopt1_rsd=$(echo "${ln}" | cut -f7 -d,)
        ms2=$(echo "${ln}" | cut -f8 -d,)
        ms2_rsd=$(echo "${ln}" | cut -f9 -d,)
        opt2=$(echo "${ln}" | cut -f10 -d,)
        opt2_rsd=$(echo "${ln}" | cut -f11 -d,)
        hopt2=$(echo "${ln}" | cut -f12 -d,)
        hopt2_rsd=$(echo "${ln}" | cut -f13 -d,)
        ${PRINTF} '  \\texttt{%s} ' "${bench}"
        if awk "BEGIN {exit !(${ms1} > 0)}"; then
            ${PRINTF} '& %s & %s & %s & %s' \
                "$(ratio "$(perl -E "say ${opt1} / ${ms1}")")" \
                "$(per "$(perl -E "say (${opt1_rsd} + ${ms1_rsd})/2")")" \
                "$(ratio "$(perl -E "say ${hopt1} / ${ms1}")")" \
                "$(per "$(perl -E "say (${hopt1_rsd} + ${ms1_rsd})/2")")"
        else
            ${PRINTF} '& \\multicolumn{4}{c|}{\\texttt{n/a}} '
        fi
        if awk "BEGIN {exit !(${ms2} > 0)}"; then
            ${PRINTF} ' & %s & %s & %s & %s' \
                "$(ratio "$(perl -E "say ${opt2} / ${ms2}")")" \
                "$(per "$(perl -E "say (${opt2_rsd} + ${ms2_rsd})/2")")" \
                "$(ratio "$(perl -E "say ${hopt2} / ${ms2}")")" \
                "$(per "$(perl -E "say (${hopt2_rsd} + ${ms2_rsd})/2")")"
        else
            ${PRINTF} '& \\multicolumn{4}{c}{\\texttt{n/a}}'
        fi
        ${PRINTF} '\\\\\n'
    done < join.csv
    ${PRINTF} '\\bottomrule\n'
    ${PRINTF} '\\end{tabularx}\n'
) > "${tex}"
