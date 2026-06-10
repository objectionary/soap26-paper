# SPDX-FileCopyrightText: Copyright (c) 2025-2026 Objectionary.com
# SPDX-License-Identifier: MIT
$pdflatex = 'pdflatex %O -interaction=errorstopmode -halt-on-error -shell-escape %S';
add_cus_dep('tex', 'pdf', 0, 'standalone');
sub standalone {
  return system("latexmk -pdf -cd -shell-escape \"$_[0].tex\"");
}
