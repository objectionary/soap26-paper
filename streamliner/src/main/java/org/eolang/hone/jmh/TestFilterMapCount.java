package org.eolang.hone.jmh;

import paper.Misc;
import org.openjdk.jmh.annotations.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.IntStream;

@OutputTimeUnit(TimeUnit.MILLISECONDS)
@BenchmarkMode(Mode.AverageTime)
@State(Scope.Thread)
@Fork(1)
public class TestFilterMapCount {
    public static int[] NN = Misc.makeArray();

    @Benchmark
    public static long filterMapCount() {
        return IntStream.of(NN)
            .filter(x -> x % 2 == 0)
            .map(x -> x * x)
            .count();
    }
}
