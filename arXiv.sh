#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2025-2026 Objectionary.com
# SPDX-License-Identifier: MIT

set -e -o pipefail

dir=.arXiv
zip=arXiv.zip

rm -rf "${dir}"
rm -rf "${zip}"

files=(paper.tex bibliography/main.bib plainnat-ext.bst)
while IFS= read -r f; do
    files+=( "${f}" )
done < <(find tables/ \( -name 'table.tex' -o -name 'seconds.tex' \) -type f)
for d in tex tikz _env; do
    while IFS= read -r f; do
        files+=( "${f}" )
    done < <(find "${d}/" -name '*.tex' -type f)
done

mkdir "${dir}"
for f in "${files[@]}"; do
    mkdir -p "${dir}/$(dirname "${f}")"
    cp "${f}" "${dir}/${f}"
done

sed -i '1s;^;\\def\\arXiv{}\n;' "${dir}/paper.tex"

TLROOT=$(kpsewhich -var-value TEXMFDIST)
for p in ffcode href-ul eolang iexec; do
    cp "${TLROOT}/tex/latex/${p}/${p}.sty" "${dir}"
done

cd "${dir}" || exit 1
pdflatex -interaction=nonstopmode -halt-on-error -shell-escape paper.tex
bibtex paper
pdflatex -interaction=nonstopmode -halt-on-error paper.tex
pdflatex -interaction=nonstopmode -halt-on-error paper.tex

rm -rf ./*.aux ./*.bcf ./*.blg ./*.fdb_latexmk ./*.fls ./*.log ./*.run.xml ./*.out ./*.exc ./*.vtc ./*.ret
rm -rf bibliography

rm -f "${dir}.zip"
zip -x paper.pdf -qr "../${zip}" . .*
