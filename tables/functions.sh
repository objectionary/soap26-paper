#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

# Number to word
numeral() {
    words=(zero one two three four five six seven eight nine ten eleven twelve)
    local n=$1
    if [ "${n}" -gt 12 ]; then
        ${PRINTF} '%d' "${n}"
    else
        ${PRINTF} '%s' "${words[n]}"
    fi
}

# Print percents.
per() {
    local float="$1"
    local digits="$2"
    if [ -z "${digits}" ]; then
        if [ -n "${COMPACT}" ]; then
            digits=1
        else
            digits=2
        fi
    fi
    ${PRINTF} "%0.${digits}f\\\\%%" "${float}"
}

# Print float number in three different colors, depending on the value.
ratio() {
    local float="$1"
    local digits="$2"
    if [ -z "${digits}" ]; then
        if [ -n "${COMPACT}" ]; then
            digits=2
        else
            digits=3
        fi
    fi
    t=$(${PRINTF} "%0.${digits}f" "${float}")
    if awk "BEGIN {exit !(${float} > 1.25)}"; then
        tex=$(${PRINTF} '\\textcolor{DarkRed}{%s}' "${t}")
    elif awk "BEGIN {exit !(${float} < 0.75)}"; then
        tex=$(${PRINTF} '\\textcolor{DarkGreen}{%s}' "${t}")
    else
        tex=$(${PRINTF} '%s' "${t}")
    fi
    ${PRINTF} '%s' "${tex}"
}

# Takes array and returns its average.
average() {
    local a=("$@")
    if [ "${#a[@]}" -eq 0 ]; then
        echo "The array provided to average() is empty"
        exit 1
    fi
    local s=0
    for n in "${a[@]}"; do
        s=$(perl -E "say ${s} + ${n}")
    done
    perl -E "say ${s} / ${#a[@]}"
}

# Takes array and returns its RSD (Relative Standard Deviation), in percentages.
rsd() {
    local a=("$@")
    if [ "${#a[@]}" -eq 0 ]; then
        echo "The array provided to rsd() is empty"
        exit 1
    fi
    local n=${#a[@]}
    local sum=0
    for x in "${a[@]}"; do
        sum=$(perl -E "say ${sum} + ${x}")
    done
    local mean
    mean=$(perl -E "say ${sum} / ${n}")
    local sq=0
    for x in "${a[@]}"; do
        sq=$(perl -E "say ${sq} + (${x} - ${mean}) * (${x} - ${mean})")
    done
    local variance
    variance=$(perl -E "say ${sq} / ${n}")
    local stddev
    stddev=$(perl -E "say sqrt(${variance})")
    perl -E "say ${stddev} / ${mean} * 100"
}
