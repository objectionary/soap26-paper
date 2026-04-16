/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
 * SPDX-License-Identifier: MIT
 */

package benchmarks;

import paper.Misc;
import java.util.concurrent.TimeUnit;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
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
 * Compare map vs loop.
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

    private static final int[] NN = Misc.makeArray();

    @Benchmark
    public long map() {
        return IntStream.of(NN)
            .filter(x -> x % 2 == 0)
            .map(x -> x * x)
            .sum();
    }

    @Benchmark
    public long loop() {
        long sum = 0L;
        for (int i = 0; i < NN.length; ++i) {
            if (NN[i] % 2 == 0) {
                sum += NN[i] * NN[i];
            }
        }
        return sum;
    }

}
