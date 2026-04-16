package dk.casa.streamliner.jmh;

import paper.Misc;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.State;

@State(Scope.Thread)
public abstract class TestBase {

	public static int[] NN = Misc.makeArray();

}
