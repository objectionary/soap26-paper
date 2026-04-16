#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

tex=$1

# shellcheck disable=SC1091
source ../functions.sh

csvs=$(${FIND} adiffs/ -name '*.csv')
if [ "${DUP_VENDORS}" = 'true' ] ; then
    max=$(wc -l < jvms.txt)
    now=$(echo "${csvs}" | wc -l)
    more=$(( max - now ))
    while [ "${more}" -gt 0 ]; do
        csvs=$(${PRINTF} '%s\n%s\n' "${csvs}" "$(echo "${csvs}" | tail -1)")
        more=$(( more - 1 ))
    done
fi

(
    ${PRINTF} '\\begin{tabularx}{\\linewidth}{X|l>{\\ttfamily}r>{\\ttfamily}r|l>{\\ttfamily}r>{\\ttfamily\\arraybackslash}r}\n'
    ${PRINTF} '\\toprule\n'
    ${PRINTF} 'Vendor & JVM & {\\rmfamily Ratio} & {\\rmfamily RSD} & JVM & {\\rmfamily Ratio} & {\\rmfamily RSD} \\\\\n'
    ${PRINTF} '\\midrule\n'
    (
        while IFS= read -r d; do
            j=$(basename "${d}")
            j=${j%.*}
            if ! ${GREP} -F -q "${j}" jvms.txt; then
                continue
            fi
            jvm=$(${GREP} -F "${j}" jvms.txt | cut -f1 -d' ')
            old_v=$(${GREP} -F "${j}" jvms.txt | cut -f3 -d' ')
            new_v=$(${GREP} -F "${j}" jvms.txt | cut -f4 -d' ')
            loop_old=$(cut -f2 -d',' "${d}")
            loop_old_rsd=$(cut -f3 -d',' "${d}")
            map_old=$(cut -f4 -d',' "${d}")
            map_old_rsd=$(cut -f5 -d',' "${d}")
            loop_new=$(cut -f6 -d',' "${d}")
            loop_new_rsd=$(cut -f7 -d',' "${d}")
            map_new=$(cut -f8 -d',' "${d}")
            map_new_rsd=$(cut -f9 -d',' "${d}")
            ${PRINTF} '    %s & %s & %s & %s & %s & %s & %s \\\\ \n' \
                "${jvm}" \
                "${old_v}" \
                "$(ratio "$(perl -E "say ${map_old} / ${loop_old}")")" \
                "$(per "$(perl -E "say ${map_old_rsd} + ${loop_old_rsd}")")" \
                "${new_v}" \
                "$(ratio "$(perl -E "say ${map_new} / ${loop_new}")")" \
                "$(per "$(perl -E "say ${map_new_rsd} + ${loop_new_rsd}")")"
        done <<< "${csvs}"
    ) | sort
    ${PRINTF} '\\bottomrule\n'
    ${PRINTF} '\\end{tabularx}\n'
) > "${tex}"
