#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025-2026 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

csv=$1

# shellcheck disable=SC1091
source ../tables/sdk-use.sh "${JVM}"

opts=()
for p in java.util java.lang.reflect java.lang.ref java.lang java.util.stream; do
    opts+=("--add-opens java.base/${p}=ALL-UNNAMED")
done

if java -version 2>&1 | head -1 | ${GREP} -qv \"1\.8; then
    export MAVEN_OPTS="${opts[*]}"
fi

echo "Java version:"
java -version

# This invocation optimises bytecode
mvn exec:java -Pprofiling --quiet --update-snapshots -Dexec.mainClass=dk.casa.streamliner.asm.TransformASM
# Copy the optimised classes
cp -R out/asm/. out/classes
# Run the profiling with the optimised classes
mvn package -Pprofiling --update-snapshots -Dmaven.main.skip "-Dnumbers=${NUMBERS}" "-Diterations=${ITERATIONS}" "-Dwarmups=${WARMUPS}" &> "$(dirname "$0")/profiling.log"

mkdir -p "$(dirname "${csv}")"
cp out/profiling.csv "${csv}"
