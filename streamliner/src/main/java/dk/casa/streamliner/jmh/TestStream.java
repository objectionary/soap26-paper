package dk.casa.streamliner.jmh;

import org.openjdk.jmh.annotations.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.IntStream;

@OutputTimeUnit(TimeUnit.MILLISECONDS)
@BenchmarkMode(Mode.AverageTime)
@State(Scope.Thread)
@Fork(1)
public class TestStream extends TestBase {
	@Benchmark
	public static int sum() {
		return IntStream.of(NN).sum();
	}

	@Benchmark
	public static int sumOfSquares() {
		return IntStream.of(NN)
			.map(d -> d * d)
			.sum();
	}

	@Benchmark
	public static int sumOfSquaresEven() {
		return IntStream.of(NN)
			.filter(x -> x % 2 == 0)
			.map(x -> x * x)
			.sum();
	}

	@Benchmark
	public static int megamorphicMaps() {
		return IntStream.of(NN)
			.map(d -> d * 1)
			.map(d -> d * 2)
			.map(d -> d * 3)
			.map(d -> d * 4)
			.map(d -> d * 5)
			.map(d -> d * 6)
			.map(d -> d * 7)
			.sum();
	}

	@Benchmark
	public static int megamorphicFilters() {
		return IntStream.of(NN)
			.filter(d -> d > 1)
			.filter(d -> d > 2)
			.filter(d -> d > 3)
			.filter(d -> d > 4)
			.filter(d -> d > 5)
			.filter(d -> d > 6)
			.filter(d -> d > 7)
			.sum();
	}

	@Benchmark
	public static boolean allMatch() {
		return IntStream.of(NN).allMatch(x -> x < 10);
	}

	@Benchmark
	public static long count() {
		return IntStream.of(NN).count();
	}

	@Benchmark
	public static long filterCount() {
		return IntStream.of(NN)
			.filter(x -> x % 2 == 0)
			.count();
	}

	@Benchmark
	public static long filterMapCount() {
		return IntStream.of(NN)
			.filter(x -> x % 2 == 0)
			.map(x -> x * x)
			.count();
	}
}
