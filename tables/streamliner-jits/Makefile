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
NUMBERS=1

MAKE := $(shell which gmake 2>/dev/null || echo make)
PRINTF := $(shell which gprintf 2>/dev/null || echo printf)
FIND := $(shell which gfind 2>/dev/null || echo find)
GREP := $(shell which ggrep 2>/dev/null || echo grep)
SED := $(shell which gsed 2>/dev/null || echo sed)

SDK := $(shell head -1 versions.txt)
VERSIONS := $(shell tail -3 versions.txt)
CSVS := $(addsuffix .csv,$(VERSIONS))

OUTS=$(foreach run,$(RUNS),$(foreach version,$(VERSIONS),outs/$(run)+$(version).out))

export SDK VERSIONS NUMBERS VENDORS ITERATIONS WARMUPS PRINTF FIND GREP SED MAKE STREAMLINER_DIR

all: table.tex

table.tex: $(CSVS) Makefile ../functions.sh ./make-table.sh
	./make-table.sh $@
	n=$$(basename "$@")
	n=$${n%.*}
	COMPACT=1 ./make-table.sh "$${n}-compact.tex"
	cat $@

$(CSVS): $(OUTS) Makefile ../functions.sh ./make-csv.sh
	./make-csv.sh $@ >>../../log.txt 2>&1
	echo "Generated CSV: $@"

$(OUTS): $(STREAMLINER_DIR)/Makefile $(STREAMLINER_DIR)/pom.xml
	./make-out.sh $@ >>../../log.txt 2>&1
	echo "Generated out CSV: $@"

clean:
	$(MAKE) -e -C "$(STREAMLINER_DIR)" clean
	git clean -fdX
