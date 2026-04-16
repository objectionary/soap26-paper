# SPDX-FileCopyrightText: Copyright (c) 2025-2026 Objectionary.com
# SPDX-License-Identifier: MIT

ifeq ($(firstword $(MAKE_VERSION)),4.0)
  $(error You need GNU make 4.0 or higher, now it's $(MAKE_VERSION))
endif

MAKEFLAGS += --no-print-directory

SHELL := $(shell env bash -c 'command -v bash')

.ONESHELL:
.SHELLFLAGS := -e -o pipefail -c
.SECONDARY:

# Local override for $(PRINTF)
# Then use $(PRINTF) instead of $(PRINTF).
PRINTF := $(shell which gprintf 2>/dev/null || echo printf)
# Local override for GNU find on macOS
FIND := $(shell which gfind 2>/dev/null || echo find)
# Local override for GNU grep on macOS
GREP := $(shell which ggrep 2>/dev/null || echo grep)
# Local override for GNU sed on macOS
SED := $(shell which gsed 2>/dev/null || echo sed)

TEXS := $(wildcard tex/*.tex)
TIKZ := $(wildcard tikz/*.tex)
SCRIPTS:= $(shell $(FIND) . -name '*.sh' -type f)

HONE_VERSION=0.20.3
JEO_VERSION=0.14.15
PHINO_VERSION=0.0.45

# How many million items to keep in test arrays:
NUMBERS=1
# How many times to repeat the tests (to show RSD):
REPEAT=1
# How many JVMs to test:
VENDORS=1
# How many JMH iterations:
ITERATIONS=1
# How many JMH warmup iterations:
WARMUPS=1
# Set it to "true" in order to see duplicate vendors in tables
DUP_VENDORS=false

# Skip recalculation of TeX tables, use existing files
BYPASS=false

SUBDIRS := $(shell $(FIND) tables -maxdepth 1 -mindepth 1 -type d)
TABLES := $(addsuffix /table.tex,$(SUBDIRS))

STAMP=.stamp_$(NUMBERS)_$(REPEAT)_$(VENDORS)_$(ITERATIONS)_$(WARMUPS)
RUNS=$(foreach n,$(shell seq -f "%02g" 1 $(REPEAT)),$(n))

export RUNS NUMBERS VENDORS ITERATIONS WARMUPS HONE_VERSION JEO_VERSION PHINO_VERSION DUP_VENDORS PRINTF FIND GREP SED

.PHONY: all env clean test create-fake-tables texqc ultimate docker push

all: env paper.pdf arXiv.zip zenodo.zip texqc premises

ultimate:
	start=$$(date '+%s.%N')
	$(MAKE) paper.pdf soap26.pdf NUMBERS=100 VENDORS=10 ITERATIONS=10 WARMUPS=10 REPEAT=10
	sec=$$(perl -E "say int($$(date '+%s.%N') - $${start})")
	$(PRINTF) '🍒 The ultimate set of experiments was done in %ds\n' "$${sec}"

arXiv.zip: paper.pdf arXiv.sh
	$(PRINTF) "\n👉🏻 Packaging %s...\n" "$@"
	./arXiv.sh >>log.txt 2>&1
	$(PRINTF) '👇🏻 ZIP archive for arXiv saved to %s (%s)\n' "$@" "$$(du -sh "$@" | cut -f1)"

zenodo.zip: arXiv.zip zenodo.sh
	$(PRINTF) '\n👉🏻 Packaging %s...\n' "$@"
	./zenodo.sh >>log.txt 2>&1
	$(PRINTF) '👇🏻 ZIP archive for Zenodo saved to %s (%s)\n' "$@" "$$(du -sh "$@" | cut -f1)"

.SILENT:
env:
	bash=$${BASH_VERSINFO:-0}
	if [ "$${bash}" -lt 5 ]; then
	    "$${SHELL}" --version
	    ps -p $$
	    echo "$${SHELL} version must be 5 or higher; current $${SHELL} version: $${bash}"
	    exit 1
	fi
	if ! docker ps -a >/dev/null 2>&1; then
		echo 'You must install Docker to let Hone plugin do its optimizations'
		exit 1
	fi
	if ! echo 'foo' | $(GREP) -F 'foo' >/dev/null; then
		echo 'Your $(GREP) does not work as expected'
		exit 1
	fi
	if ! $(PRINTF) '%.2f' '0.00' >/dev/null 2>&1; then
		echo 'You must install GNU coreutils to enable floating point number printing'
		exit 1
	fi
	if ! pdftotext -v >/dev/null 2>&1; then
		echo 'You must install Poppler to enable PDF to text conversion'
		exit 1
	fi
	if ! aspell -v >/dev/null 2>&1; then
		echo 'You must install GNU Aspell to enable spell checking'
		exit 1
	fi
	if ! pdflatex --version >/dev/null 2>&1; then
		echo 'You must install LaTeX to enable PDF rendering'
		exit 1
	fi
	if ! $(FIND) --version >/dev/null 2>&1; then
		echo 'You must install GNU $(FIND)utils to enable file system traversing'
		exit 1
	fi
	if ! $(SED) --version >/dev/null 2>&1; then
		echo 'You must install GNU sed to enable gsed'
		exit 1
	fi
	if ! ruby --version >/dev/null 2>&1; then
		echo 'You must have Ruby installed to run quality checkers'
		exit 1
	fi
	if ! zip --version >/dev/null 2>&1; then
		echo 'You must have zip installed'
		exit 1
	fi
	if ! unzip -hh >/dev/null 2>&1; then
		echo 'You must have unzip installed'
		exit 1
	fi
	sh="$$(echo ~)/.sdkman/bin/sdkman-init.sh"
	if ! sdk version > /dev/null 2>&1 && [ ! -e "$${sh}" ]; then
		echo "Probably 'sdk' is not installed; we couldn't run 'sdk' and didn't $(FIND) its init file at $${sh}"
		exit 1
	fi
	echo "👌🏻 Your environment is good enough!"

.SILENT:
%.pdf: env paper.tex $(TEXS) $(TIKZ) $(TABLES) main.bib _env/os.tex _env/cores.tex _env/ram.tex _env/ghz.tex _env/arch.tex _env/numbers.tex _env/repeat.tex _env/iterations.tex _env/warmups.tex _env/hone-version.tex _env/jeo-version.tex _env/phino-version.tex _env/mistake.tex
	n=$$(basename "$@")
	n=$${n%.*}
	latexmk -pdf "$${n}" >>log.txt 2>&1
	if [ -e "$${HOME}/.sdkman/bin/sdkman-init.sh" ]; then
		source ./tables/sdk-use.sh 24.0.2-zulu
	fi
	echo "👇🏻 The PDF paper was successfully built and saved to $@ ($$(du -sh "$@" | cut -f1))"

premises: $(TABLES) premises.sh Makefile paper.pdf
	./premises.sh

texqc: paper.pdf Makefile
	texqc paper

.SILENT:
%/table.tex: %/Makefile $(SCRIPTS) Makefile $(STAMP)
	if [ "$(BYPASS)" == 'true' ]; then
		touch $@
		cat $@
		echo "👍🏻 TeX table recalculation bypassed"
	else
		start=$$(date '+%s.%N')
		$(PRINTF) "\n👉🏻 Making TeX table: %s...\n" "$@"
		$(MAKE) -e -C "$$(dirname $@)" table.tex
		sec=$$(perl -E "say int($$(date '+%s.%N') - $${start})")
		$(PRINTF) '👍🏻 TeX table was built for \e[1m%s\e[0m in %ds\n\n' "$@" "$${sec}"
		$(PRINTF) '%'\''d\\endinput' "$${sec}" > "$$(dirname $@)/seconds.tex"
	fi

create-fake-tables: _env/numbers.tex _env/repeat.tex _env/iterations.tex _env/warmups.tex _env/os.tex _env/cores.tex _env/ram.tex _env/ghz.tex _env/arch.tex
	for t in $(TABLES); do
		$(PRINTF) '\\tbd{table skipped}' > "$${t}"
		$(PRINTF) '0\\endinput' > "$$(dirname $${t})/time.tex"
	done
	mkdir -p _env
	$(PRINTF) '0.0.0' > _env/jeo-version.tex
	$(PRINTF) '0.0.0' > _env/hone-version.tex
	$(PRINTF) '0.0.0' > _env/phino-version.tex
	$(PRINTF) '0.00' > _env/mistake.tex

.SILENT:
_env/mistake.tex: Makefile ./tables/count-mistake.sh $(TABLES)
	mkdir -p "$$(dirname "$@")"
	./tables/count-mistake.sh $@
	echo "The maximum mistake is $$(cat $@)"

.SILENT:
_env/hone-version.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	$(PRINTF) '%s\\endinput' "$(HONE_VERSION)" > $@
	echo "HONE version: $$(cat $@)"

.SILENT:
_env/phino-version.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	$(PRINTF) '%s\\endinput' "$(PHINO_VERSION)" > $@
	echo "PHINO version: $$(cat $@)"

.SILENT:
_env/jeo-version.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	$(PRINTF) '%s\\endinput' "$(JEO_VERSION)" > $@
	echo "JEO version: $$(cat $@)"

.SILENT:
_env/numbers.tex: Makefile $(STAMP)
	source tables/functions.sh
	mkdir -p "$$(dirname "$@")"
	$(PRINTF) '%s\\endinput' "$$(numeral "$(NUMBERS)")" > $@
	echo "Numbers: $$(cat $@)"

.SILENT:
_env/repeat.tex: Makefile $(STAMP)
	source tables/functions.sh
	mkdir -p "$$(dirname "$@")"
	$(PRINTF) '%s\\endinput' "$$(numeral "$(REPEAT)")" > $@
	echo "Repeat: $$(cat $@)"

.SILENT:
_env/iterations.tex: Makefile $(STAMP)
	source tables/functions.sh
	mkdir -p "$$(dirname "$@")"
	$(PRINTF) '%s\\endinput' "$$(numeral "$(ITERATIONS)")" > $@
	echo "Iterations: $$(cat $@)"

.SILENT:
_env/warmups.tex: Makefile $(STAMP)
	source tables/functions.sh
	mkdir -p "$$(dirname "$@")"
	$(PRINTF) '%s\\endinput' "$$(numeral "$(WARMUPS)")" > $@
	echo "Warmup iterations: $$(cat $@)"

.SILENT:
_env/os.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	(
		if [ "$$(uname)" == 'Darwin' ]; then
			$(PRINTF) '%s %s' \
				"$$(sw_vers -productName | xargs)" \
				"$$(sw_vers -productVersion | xargs)"
		elif [ "$$(uname)" == 'Linux' ]; then
			name=$($(GREP) '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
			version=$($(GREP) '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
			if [ -z "$${name}" ]; then
				$(PRINTF) 'Ubuntu %s' "$$(lsb_release -r -s)"
			else
				$(PRINTF) '%s %s' "$${name}" "$${version}"
			fi
		else
			echo "Unknown OS, can't get its name"
			exit 1
		fi
		$(PRINTF) '\\endinput\n'
	) > $@
	echo "OS: $$(cat $@)"

.SILENT:
_env/cores.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	(
		if [ "$$(uname)" == 'Darwin' ]; then
			$(PRINTF) '%d' "$$(sysctl -n hw.ncpu | xargs)"
		elif [ "$$(uname)" == 'Linux' ]; then
			$(PRINTF) '%d' "$$(nproc | xargs)"
		else
			echo "Unknown OS, can't count cores"
			exit 1
		fi
		$(PRINTF) '\\endinput\n'
	) > $@
	echo "Cores: $$(cat $@)"

.SILENT:
_env/ram.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	(
		if [ "$$(uname)" == 'Darwin' ]; then
			$(PRINTF) '%d' "$$(( $$(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))"
		elif [ "$$(uname)" == 'Linux' ]; then
			$(PRINTF) '%d' "$$(( $$($(GREP) MemTotal /proc/meminfo | awk '{print $$2}') / 1024 / 1024 ))"
		else
			echo "Unknown OS, can't get memory size"
			exit 1
		fi
		$(PRINTF) '\\endinput\n'
	) > $@
	echo "RAM: $$(cat $@)"

.SILENT:
_env/ghz.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	(
		if [ "$$(uname)" == 'Darwin' ]; then
			cpu=$$(sysctl -n machdep.cpu.brand_string)
			case "$${cpu}" in
			  *M1*) $(PRINTF) '3.2' ;;
			  *M2*) $(PRINTF) '3.5' ;;
			  *M3*) $(PRINTF) '4.0' ;;
			  *) $(PRINTF) "$${cpu}" ;;
			esac
		elif [ "$$(uname)" == 'Linux' ]; then
			$(PRINTF) '%s' "$$(awk '/MHz/ {$(PRINTF) "%.2f\n", $$4/1000}' /proc/cpuinfo | head -1 | xargs)"
		else
			echo "Unknown OS, can't get GHz"
			exit 1
		fi
		$(PRINTF) '\\endinput\n'
	) > $@
	echo "GHz: $$(cat $@)"

.SILENT:
_env/arch.tex: Makefile
	mkdir -p "$$(dirname "$@")"
	(
		$(PRINTF) '%s' "$$(uname -m | sed 's/_/\\_/g')"
		$(PRINTF) '\\endinput\n'
	) > $@
	echo "Arch: $$(cat $@)"

.SILENT:
$(STAMP):
	touch $@

.SILENT:
clean:
	rm -rf ./paper.pdf ./arXiv.zip ./zenodo.zip ./*.dvi ./*.xcp ./*.bbl ./*.blg ./*.out ./*.fls ./*.log ./*.fdb_latexmk ./*.aux ./*.ret ./*.svg ./_eolang ./svg-inkscape
	rm -rf ./.stamp_*
	rm -rf ./.eloquence
	rm -rf ./.arXiv ./.zenodo
	rm -rf ./_env
	rm -f log.txt
	for d in $(SUBDIRS); do
		$(MAKE) -C "$${d}" clean
	done
