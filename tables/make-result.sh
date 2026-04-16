#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

j=$(basename "${csv}")
n=${j%.*}

j=$(echo "${n}" | cut -f2 -d'+')
if [[ "${csv}" =~ before ]]; then
    v=$(ggrep -F "${j}" jvms.txt | cut -f3 -d' ')
else
    v=$(ggrep -F "${j}" jvms.txt | cut -f4 -d' ')
fi

# shellcheck disable=SC1091
source ../sdk-use.sh "${v}-${j}"

major=$(echo "${v}" | cut -f1 -d'.')

cp ../pom.xml pom.xml
cp ../Misc.java Misc.java
mvn --batch-mode --errors --quiet --fail-fast \
    "-Diterations=${ITERATIONS}" "-Dwarmups=${WARMUPS}" \
    clean package "-Djvm.version=${major}"

mkdir -p "$(dirname "${csv}")"
cp target/results.csv "${csv}"
