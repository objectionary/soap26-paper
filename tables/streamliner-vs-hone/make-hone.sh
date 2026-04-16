#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

n=$(basename "${csv}")
n=${csv//.hone/}
v=$(echo "${n}" | cut -f2 -d'+')

# shellcheck disable=SC1091
source ../sdk-use.sh "${v}-${JVM_SUFFIX}"

rm -rf src
cp -r "${STREAMLINER_DIR}/src" src

for d in asm other stream utils; do
    rm -rf src/main/java/dk/casa/streamliner/${d}
done

mvn --update-snapshots --batch-mode --errors --fail-fast clean package \
    "-Djvm.version=$(echo "${v}" | cut -f1 -d'.')" \
    "-Dhone.version=${HONE_VERSION}" \
    "-Djeo.version=${JEO_VERSION}" \
    "-Dnumbers=${NUMBERS}" "-Diterations=${ITERATIONS}" "-Dwarmups=${WARMUPS}"

mkdir -p "$(dirname "${csv}")"
cp target/hone-results.csv "${csv}"
