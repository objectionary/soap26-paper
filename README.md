# Java Stream Fusion via 𝜑-Calculus (LaTeX Paper)

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/objectionary/soap26-paper/blob/master/LICENSE.txt)

This repository contains the experimental artifacts
  and the research paper in LaTeX.
The research explores a bytecode-to-bytecode optimization technique
  for the [Java Stream API] that replaces consecutive
  `map()` and `filter()` operations with a single `mapMulti()` call
  introduced in Java 16.
The optimization is implemented declaratively through [φ-calculus] rewriting
  rules rather than imperative bytecode manipulation.
Experiments on nine benchmarks introduced by [Biboudis et al.] and
  used by [Møller et al.] showed that the transformation
  preserved all program behavior and caused no performance regressions;
  in several cases it improved execution time.
All tools, benchmarks, and data in this repository
  reproduce the results reported in the paper.

The study uses the following open source tools:

* [Streamliner] to unroll stream pipelines into loops
* [hone-maven-plugin] to fuse stream operations using [φ-calculus] rewriting rules
* [Phino] to rewrite [φ-calculus] expressions
* [jeo-maven-plugin] to convert bytecode to [φ-calculus] and backward
* [JMH] to benchmark

In order to reproduce the experiments and then compile the paper,
  you need to run:

```bash
git clone --recurse-submodules https://github.com/objectionary/soap26-paper.git
make REPEAT=2 NUMBERS=15
```

If issues occur, check the `log.txt` file.

You can provide the following variables:

* `REPEAT=5` requests five repetitive test runs
(recommended: 10)
* `NUMBERS=7` makes our tests use seven million numbers in test arrays
(recommended: 100)
* `VENDORS=3` makes our tests use no more than three JVM vendors
(recommended: 10)
* `ITERATIONS=3` requests JMH to do three measuring iterations
(recommended: 10)
* `WARMUPS=2` requests JMH to do two warming-up iterations
(recommended: 10)

By default, all these parameters are set to their minimums.

Run `make clean ultimate` to use all recommended values.

> [!WARNING]
> The entire build, if you use recommended values,
> may take around **three hours**.

## Prerequisites

You need to have these ingredients installed:

* [GNU Make] 4+
* [Docker] (even if you run it with `make`, not `docker`)
* LaTeX with packages (see [DEPENDS.txt](/DEPENDS.txt) for their full list)
* [Poppler]
* [SdkMan]
* Ruby 3.3+
* [GNU Bash] 5+ (not the bash installed by default!)
* [GNU coreutils], esp. `print`, `awk`, `sed`, `grep`, and `find`
* [Vale]
* [GNU Aspell]
* [texsc]
* [texqc]

The build is not supported on Windows.
You need either Ubuntu or macOS.

## Docker

You can run all experiments and then render the paper using Docker.
However, benchmark accuracy may be reduced.
Run it like this:

```bash
make docker REPEAT=2 NUMBERS=15
```

When finished, you will have `paper.pdf` built in your current directory.

The `make docker ultimate` command is not supported.
Instead, manually specify all parameters
  with their recommended values.

## Repository Structure

The subdirectories contain:

* `tex/` contains sections of the paper, in TeX.
* `tables/` contains a few directories with standalone Make projects
that run benchmarks and collect their results, producing TeX tables.
* `tikz/` contains TikZ diagrams for the paper.
* `streamliner/` contains [Streamliner] source code, without tests and
some other files irrelevant to this experiment.

[Poppler]: https://poppler.freedesktop.org/
[SdkMan]: https://sdkman.io/
[Vale]: https://vale.sh/docs/install
[GNU Aspell]: http://aspell.net/
[texqc]: https://rubygems.org/gems/texqc
[texsc]: https://rubygems.org/gems/texsc
[GNU Make]: https://www.gnu.org/software/make/
[Streamliner]: https://github.com/cs-au-dk/streamliner
[GNU Bash]: https://www.gnu.org/software/bash/
[φ-calculus]: https://arxiv.org/abs/2111.13384
[Java Stream API]: https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html
[Biboudis et al.]: https://arxiv.org/abs/1406.6631
[Møller et al.]: https://dl.acm.org/doi/abs/10.1145/3428236
[CI workflow]: https://github.com/objectionary/soap26-paper/actions/workflows/make.yml
[hone-maven-plugin]: https://github.com/objectionary/hone-maven-plugin
[jeo-maven-plugin]: https://github.com/objectionary/jeo-maven-plugin
[Phino]: https://github.com/objectionary/phino
[JMH]: https://github.com/openjdk/jmh
[Docker]: https://www.docker.com/
[GNU coreutils]: https://www.gnu.org/software/coreutils/
