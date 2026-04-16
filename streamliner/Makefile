# SPDX-FileCopyrightText: Copyright (c) 2025-2026 Objectionary.com
# SPDX-License-Identifier: MIT

SHELL := $(shell env bash -c 'command -v bash')

.ONESHELL:
.SHELLFLAGS := -e -o pipefail -c
.PHONY: all clean test
.SECONDARY:
.PRECIOUS:

PRINTF := $(shell which gprintf 2>/dev/null || echo printf)
FIND := $(shell which gfind 2>/dev/null || echo find)
GREP := $(shell which ggrep 2>/dev/null || echo grep)
SED := $(shell which gsed 2>/dev/null || echo sed)

JAVAS := $(shell $(FIND) src -name '*.java' -type f)

NUMBERS=1
ITERATIONS=1
WARMUPS=1
JVM=8.0.462-zulu

export NUMBERS ITERATIONS WARMUPS JVM PRINTF FIND GREP SED

all: out.csv profiling.csv jitless.csv

.SILENT:
out/classes: $(JAVAS) pom.xml
	mkdir -p src/main/java/paper
	cp ../tables/Misc.java src/main/java/paper
	source ../tables/sdk-use.sh "$(JVM)" >>../log.txt 2>&1
	mvn --quiet clean compile >>../log.txt 2>&1

.SILENT:
out.csv: out/classes $(JAVAS) pom.xml ./make-out.sh
	./make-out.sh $@ >>../log.txt 2>&1

.SILENT:
profiling.csv: out/classes $(JAVAS) pom.xml ./make-profile.sh
	./make-profile.sh $@ >>../log.txt 2>&1

.SILENT:
jitless.csv: out/classes $(JAVAS) pom.xml ./make-out-without-jit.sh
	./make-out-without-jit.sh $@ >>../log.txt 2>&1

.SILENT:
clean:
	rm -rf target/
	rm -rf out/
	rm -f out.csv
	rm -f profiling.csv
	rm -f profiling.log
	rm -f jitless.csv
