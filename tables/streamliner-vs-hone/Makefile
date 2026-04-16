# SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
# SPDX-License-Identifier: MIT

SHELL := $(shell env bash -c 'command -v bash')

.ONESHELL:
.SHELLFLAGS := -e -o pipefail -c
.PHONY: all clean test
.SECONDARY:
.PRECIOUS:

RUNS=01
STREAMLINER_DIR=../../streamliner
ITERATIONS=1
WARMUPS=1

PRINTF := $(shell which gprintf 2>/dev/null || echo printf)
FIND := $(shell which gfind 2>/dev/null || echo find)
GREP := $(shell which ggrep 2>/dev/null || echo grep)
SED := $(shell which gsed 2>/dev/null || echo sed)

HONE_VERSION=0.20.3
JEO_VERSION=0.14.15
PHINO_VERSION=0.0.43

JVM := $(shell head -1 jvm.txt | xargs)
JVM_SUFFIX := $(shell head -2 jvm.txt | tail -1 | xargs)
JVM_OLD := $(shell head -3 jvm.txt | tail -1 | xargs)
JVM_NEW := $(shell head -4 jvm.txt | tail -1 | xargs)
JVMS := $(JVM_OLD) $(JVM_NEW)

OUTS=$(foreach run,$(RUNS),$(foreach jvm,$(JVMS),outs/$(run)+$(jvm).out))
HONES=$(foreach run,$(RUNS),$(foreach jvm,$(JVMS),hones/$(run)+$(jvm).hone))

export JVM JVM_OLD JVM_NEW STREAMLINER_DIR JVM_SUFFIX HONE_VERSION JEO_VERSION PHINO_VERSION NUMBERS VENDORS ITERATIONS WARMUPS PRINTF FIND GREP SED

all: table.tex

.SILENT:
table.tex: join.csv Makefile ../functions.sh ./make-table.sh
	./make-table.sh "$@" >>../../log.txt 2>&1
	n=$$(basename "$@")
	n=$${n%.*}
	COMPACT=1 ./make-table.sh "$${n}-compact.tex" >>../../log.txt 2>&1
	cat "$@"

.SILENT:
join.csv: old.csv new.csv Makefile ./make-join.sh
	./make-join.sh "$@" >>../../log.txt 2>&1
	echo "Created $@"

.SILENT:
%.csv: $(OUTS) $(HONES) Makefile ../functions.sh ./make-csv.sh
	./make-csv.sh "$@" >>../../log.txt 2>&1
	echo "Created $@"

.SILENT:
$(OUTS): %: Makefile ./make-out.sh pom.xml
	./make-out.sh "$@" >>../../log.txt 2>&1
	echo "Generated $@ with numbers=$(NUMBERS), iterations=$(ITERATIONS), warmups=$(WARMUPS)"

.SILENT:
$(HONES): %: Makefile ./make-hone.sh pom.xml
	./make-hone.sh "$@" >>../../log.txt 2>&1
	echo "Generated $@ with numbers=$(NUMBERS), iterations=$(ITERATIONS), warmups=$(WARMUPS)"

clean:
	$(MAKE) -C "$${STREAMLINER_DIR}" clean
	rm -f ./*.csv ./table.tex
	rm -rf target/ benches/ hones/ outs/
