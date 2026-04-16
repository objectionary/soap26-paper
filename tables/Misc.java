/*
 * SPDX-FileCopyrightText: Copyright (c) 2025 Objectionary.com
 * SPDX-License-Identifier: MIT
 */

package paper;

public class Misc {

    public static int[] makeArray() {
        String env = System.getenv("NUMBERS");
        if (env == null || env.isEmpty()) {
            env = "1";
        }
        int len = Integer.parseInt(env) * 1_000_000;
        int[] array = new int[len];
        for (int i = 0; i < array.length; i++) {
            array[i] = i % 99;
        }
        return array;
    }

}
