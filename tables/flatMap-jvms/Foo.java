/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
 * SPDX-License-Identifier: MIT
 */

package benchmarks;

import paper.Misc;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;
import java.util.function.IntConsumer;
import java.util.stream.IntStream;
import java.util.stream.Stream;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.State;

/**
 * Compare mapMulti vs flatMap.
 *
 * <p>This example was taken from
 * <a href="https://dl.acm.org/doi/abs/10.1145/3428236">this paper</a>.</p>
 *
 * @since 0.1
 */
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@State(Scope.Benchmark)
@Fork(1)
public class Foo {

    public static int[] NN = Misc.makeArray();

    @Benchmark
    public int map() {
        return IntStream.of(NN)
            .flatMap((int d) -> IntStream.of(d * d))
            .sum();
    }

    @Benchmark
    public int loop() {
        return IntStream.of(NN)
            .mapMulti((int d, IntConsumer consumer) -> {
                consumer.accept(d * d);
            })
            .sum();
    }

}
