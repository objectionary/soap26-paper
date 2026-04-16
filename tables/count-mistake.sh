#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

tex=$1

mistakes=()
while IFS= read -r csv; do
    while IFS= read -r ln; do
        m=$(echo "${ln}" | cut -f6 -d',')
    done < <(cat "${csv}")
    if [[ "${m}" =~ ^[0-9]\.[0-9]+$ ]]; then
        mistakes+=("${m}")
    fi
done < <(find tables/ -wholename 'before/*.csv' -o -wholename 'after/*.csv' -o -name '*.out' -o -name '*.hone')

max=$(awk 'NR==1 || $1 > max { max=$1 } END{ print max }' <<< "${mistakes[@]}")
if [ -z "${max}" ]; then
    max=0
fi

${PRINTF} '%0.3f\\endinput' "${max}" > "${tex}"

echo "Found ${#mistakes[@]} mistakes, maximum is ${max}"
