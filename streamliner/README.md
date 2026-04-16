# Reduced Version of Streamliner

This is a reduced version of [Streamliner], stream fusion/unrolling software that optimizes Java Stream pipelines into procedural loops.

To run it, simply do:

```bash
make
```

It should work on Java 8 through 24 (any version in between should also work).
The summary will be generated in the `out.csv` file.

Changes in this fork:

* The Bash `jmh.sh` script was replaced with a `Makefile`
* All unit tests were removed (some of them didn't work)
* All benchmarks except one (`TestStream`) were removed
* JMH and ASM versions were upgraded in `pom.xml`
* The build was fixed for JDK 9+ (it didn't work)

[Streamliner]: https://github.com/cs-au-dk/streamliner
