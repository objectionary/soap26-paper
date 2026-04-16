#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

(
    while IFS= read -r ln; do
        bench=$(echo "${ln}" | cut -f1 -d,)
        ms1=$(echo "${ln}" | cut -f2 -d,)
        ms1_rsd=$(echo "${ln}" | cut -f3 -d,)
        opt1=$(echo "${ln}" | cut -f4 -d,)
        opt1_rsd=$(echo "${ln}" | cut -f5 -d,)
        hopt1=$(echo "${ln}" | cut -f6 -d,)
        hopt1_rsd=$(echo "${ln}" | cut -f7 -d,)
        ms2=$(${GREP} -F "${bench}," new.csv | cut -f2 -d,)
        ms2_rsd=$(${GREP} -F "${bench}," new.csv | cut -f3 -d,)
        opt2=$(${GREP} -F "${bench}," new.csv | cut -f4 -d,)
        opt2_rsd=$(${GREP} -F "${bench}," new.csv | cut -f5 -d,)
        hopt2=$(${GREP} -F "${bench}," new.csv | cut -f6 -d,)
        hopt2_rsd=$(${GREP} -F "${bench}," new.csv | cut -f7 -d,)
        ${PRINTF} '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "${bench}" \
            "${ms1}" "${ms1_rsd}" \
            "${opt1}" "${opt1_rsd}" \
            "${hopt1}" "${hopt1_rsd}" \
            "${ms2}" "${ms2_rsd}" \
            "${opt2}" "${opt2_rsd}" \
            "${hopt2}" "${hopt2_rsd}"
    done < old.csv
) > "${csv}"
